Apify to GCS Cloud Function

- HTTP function `ingest_apify_to_gcs` (2nd gen)
- Accepts JSON body or query params containing `datasetId` or an Apify webhook payload with `resource.defaultDatasetId`
- Uploads dataset items as JSONL to `gs://$GCS_BUCKET/$GCS_PREFIX/<datasetId>/<timestamp>.jsonl`

Environment variables
- GCS_BUCKET (required unless passed per-request as gcsBucket)
- GCS_PREFIX (optional, default `apify/`)
- APIFY_TOKEN (optional if dataset private)
- WEBHOOK_SECRET (optional shared secret)

Local test
```bash
curl -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Secret: $WEBHOOK_SECRET" \
  -d '{"datasetId":"abc123"}'
```
