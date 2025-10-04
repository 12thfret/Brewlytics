import os
import json
import logging
import tempfile
from datetime import datetime, timezone
from typing import Any, Dict, Optional

import requests
from flask import Request, make_response
from google.cloud import storage


def _extract_dataset_id(payload: Dict[str, Any], query_args: Dict[str, Any]) -> Optional[str]:
    """Try to find an Apify dataset ID in common payload shapes.

    Supports:
    - { "datasetId": "xyz" }
    - { "dataset_id": "xyz" }
    - { "resource": { "defaultDatasetId": "xyz" } }
    - Query params datasetId, dataset_id, defaultDatasetId
    """
    if not payload:
        payload = {}

    keys = [
        "datasetId",
        "dataset_id",
        "defaultDatasetId",
    ]
    for key in keys:
        if key in payload and isinstance(payload[key], str) and payload[key].strip():
            return payload[key].strip()

    resource = payload.get("resource") if isinstance(payload, dict) else None
    if isinstance(resource, dict):
        for key in keys:
            value = resource.get(key)
            if isinstance(value, str) and value.strip():
                return value.strip()

    # Fallback to query params
    for key in keys:
        value = query_args.get(key)
        if isinstance(value, str) and value.strip():
            return value.strip()

    return None


def _require_secret(request: Request) -> Optional[str]:
    """Validate a shared secret if WEBHOOK_SECRET is set.

    Accept secret via header X-Webhook-Secret, Authorization: Bearer <secret>,
    or query param `secret`. Returns error string if invalid, None if ok.
    """
    expected = os.getenv("WEBHOOK_SECRET")
    if not expected:
        return None  # No secret configured

    supplied = (
        request.headers.get("X-Webhook-Secret")
        or (request.headers.get("Authorization") or "").removeprefix("Bearer ").strip()
        or request.args.get("secret")
    )

    if supplied != expected:
        return "Unauthorized: invalid webhook secret"

    return None


def _build_items_url(dataset_id: str, apify_token: Optional[str]) -> str:
    base = f"https://api.apify.com/v2/datasets/{dataset_id}/items"
    params = ["format=jsonl", "clean=true"]
    if apify_token:
        params.append(f"token={apify_token}")
    return base + "?" + "&".join(params)


def ingest_apify_to_gcs(request: Request):
    """HTTP Cloud Function (2nd gen) to mirror Apify dataset items to GCS.

    Request bodies supported:
    - Apify webhook for actor run finished (uses resource.defaultDatasetId)
    - Manual JSON: { "datasetId": "xxx", "gcsBucket": "bucket", "gcsPath": "path/file.jsonl" }
    - Query params may also include datasetId, gcsBucket, gcsPath

    Environment variables:
    - APIFY_TOKEN: Token to access private datasets (optional if dataset is public)
    - GCS_BUCKET: Default destination bucket
    - GCS_PREFIX: Optional prefix under the bucket (default "apify/")
    - WEBHOOK_SECRET: Optional shared secret required from caller
    """
    # Validate secret if configured
    err = _require_secret(request)
    if err:
        return make_response({"error": err}, 401)

    try:
        payload = request.get_json(silent=True) or {}
    except Exception:
        payload = {}

    dataset_id = _extract_dataset_id(payload, request.args or {})
    if not dataset_id:
        return make_response({"error": "Missing Apify datasetId"}, 400)

    apify_token = (
        (request.headers.get("X-Apify-Token") or request.args.get("apifyToken") or "").strip()
        or os.getenv("APIFY_TOKEN", "").strip()
    ) or None

    # Resolve destination
    bucket_name = (
        (payload.get("gcsBucket") if isinstance(payload, dict) else None)
        or request.args.get("gcsBucket")
        or os.getenv("GCS_BUCKET")
    )
    if not bucket_name:
        return make_response({"error": "GCS bucket not configured; set GCS_BUCKET or pass gcsBucket"}, 400)

    gcs_path = (
        (payload.get("gcsPath") if isinstance(payload, dict) else None)
        or request.args.get("gcsPath")
    )

    # Default path if not provided
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    prefix = os.getenv("GCS_PREFIX", "apify/")
    if not gcs_path:
        gcs_path = f"{prefix.rstrip('/')}/{dataset_id}/{timestamp}.jsonl"

    items_url = _build_items_url(dataset_id, apify_token)
    logging.info("Fetching dataset %s from %s", dataset_id, items_url)

    try:
        with requests.get(items_url, stream=True, timeout=(10, 300)) as resp:
            resp.raise_for_status()
            with tempfile.NamedTemporaryFile(suffix=".jsonl", delete=False) as tmp:
                for chunk in resp.iter_content(chunk_size=1024 * 512):  # 512 KiB
                    if chunk:
                        tmp.write(chunk)
                tmp.flush()
                temp_path = tmp.name

        storage_client = storage.Client()
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(gcs_path)
        blob.content_type = "application/x-ndjson"
        blob.upload_from_filename(temp_path)

        gcs_uri = f"gs://{bucket_name}/{gcs_path}"
        logging.info("Uploaded dataset %s to %s", dataset_id, gcs_uri)
        return make_response({
            "status": "ok",
            "datasetId": dataset_id,
            "destination": gcs_uri,
        }, 200)
    except requests.HTTPError as http_err:
        logging.exception("Failed to fetch dataset: %s", http_err)
        return make_response({"error": f"Failed to fetch dataset: {http_err}"}, 502)
    except Exception as exc:
        logging.exception("Unexpected error")
        return make_response({"error": f"Unexpected error: {exc}"}, 500)
