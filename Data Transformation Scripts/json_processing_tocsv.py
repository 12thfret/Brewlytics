#!/usr/bin/env python3
"""
Example of how JSON processing would be much cleaner than CSV
This shows the transformation pipeline for JSON data
"""

import json
import pandas as pd
from typing import Dict, List, Any
import re

def process_apify_json(json_file_path: str) -> pd.DataFrame:
    """
    Process Apify JSON data into a clean, structured format for BigQuery
    """
    
    print("Loading JSON data...")
    with open(json_file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    print(f"Loaded {len(data)} records")
    
    # Process each record
    processed_records = []
    
    for record in data:
        processed_record = extract_core_fields(record)
        processed_record.update(extract_additional_fields(record.get('additional', {})))
        processed_record.update(extract_images(record.get('images_urls', [])))
        processed_record.update(extract_tags(record.get('tags', [])))
        
        processed_records.append(processed_record)
    
    return pd.DataFrame(processed_records)
    

def extract_core_fields(record: Dict) -> Dict[str, Any]:
    """Extract the main product fields"""
    return {
        'product_id': record.get('id'),
        'brand': record.get('brand'),
        'roaster_name': extract_roaster_from_url(record.get('url')),
        'title': record.get('title'),
        'price': parse_price(record.get('price')),
        'currency': record.get('currency', 'USD'),
        'product_type': record.get('product_type'),
        'description': clean_description(record.get('description')),
        'availability': record.get('availability'),
        'sku': record.get('sku'),
        'url': record.get('url'),
        'material': record.get('material'),
        'size': record.get('size'),
        'color': record.get('color'),
        'created_at': record.get('created_at'),
        'updated_at': record.get('updated_at'),
        'published_at': record.get('published_at')
    }

def extract_additional_fields(additional: Dict) -> Dict[str, Any]:
    """Extract and standardize additional product attributes"""
    processed = {}
    
    # Coffee-specific fields
    coffee_fields = {
        'roast': extract_roast_level(additional),
        'grind_size': extract_grind_size(additional),
        'origin': extract_origin(additional),
        'weight': extract_weight(additional),
        'roast_date': additional.get('roast_date') or additional.get('roast _date')
    }
    
    # Equipment fields
    equipment_fields = {
        'model': additional.get('model'),
        'finish': additional.get('finish'),
        'material_type': additional.get('material _type')
    }
    
    # Subscription/plan fields
    subscription_fields = {
        'subscription_plan': additional.get('subscription _plans'),
        'quantity_per_month': additional.get('quantity _per _month')
    }
    
    processed.update({k: v for k, v in coffee_fields.items() if v})
    processed.update({k: v for k, v in equipment_fields.items() if v})
    processed.update({k: v for k, v in subscription_fields.items() if v})
    
    return processed

def extract_images(image_urls: List[str]) -> Dict[str, Any]:
    """Extract and organize image URLs"""
    if not image_urls:
        return {}
    
    return {
        'primary_image': image_urls[0] if image_urls else None,
        'secondary_images': json.dumps(image_urls[1:6]) if len(image_urls) > 1 else None,  # Store as JSON array
        'total_images': len(image_urls)
    }

def extract_tags(tags: List[str]) -> Dict[str, Any]:
    """Extract and categorize tags"""
    if not tags:
        return {}
    
    # Categorize tags
    coffee_tags = [tag for tag in tags if any(word in tag.lower() for word in ['coffee', 'roast', 'bean', 'blend'])]
    equipment_tags = [tag for tag in tags if any(word in tag.lower() for word in ['grinder', 'machine', 'equipment', 'tool'])]
    
    return {
        'all_tags': json.dumps(tags),  # Store as JSON array
        'coffee_tags': json.dumps(coffee_tags),
        'equipment_tags': json.dumps(equipment_tags),
        'tag_count': len(tags)
    }

def extract_roaster_from_url(url: str) -> str:
    """Extract roaster name from URL domain"""
    if not url:
        return None
    
    try:
        # Remove protocol if present
        if '://' in url:
            domain = url.split('://')[1]
        else:
            domain = url
        
        # Remove path and get domain
        domain = domain.split('/')[0]
        
        # Remove common TLDs and subdomains
        # Handle cases like www.parchmen.co, alchemist.global
        domain_parts = domain.split('.')
        
        # Remove 'www' if present
        if domain_parts[0] == 'www':
            domain_parts = domain_parts[1:]
        
        # Get the main domain name (usually the first part after www)
        if len(domain_parts) >= 2:
            roaster_name = domain_parts[0]
            # Capitalize first letter for consistency
            return roaster_name.capitalize()
        else:
            return domain_parts[0].capitalize() if domain_parts else None
            
    except Exception as e:
        print(f"Error extracting roaster from URL {url}: {e}")
        return None

def parse_price(price_str: str) -> float:
    """Parse price string to float"""
    if not price_str:
        return None
    
    # Remove currency symbols and parse
    price_clean = re.sub(r'[^\d.,]', '', str(price_str))
    try:
        return float(price_clean.replace(',', '.'))
    except:
        return None

def clean_description(desc: str) -> str:
    """Clean and truncate description"""
    if not desc:
        return None
    
    # Remove extra whitespace and newlines
    cleaned = re.sub(r'\s+', ' ', str(desc)).strip()
    
    # Truncate if too long (BigQuery STRING limit)
    return cleaned[:1000] if len(cleaned) > 1000 else cleaned

def extract_roast_level(additional: Dict) -> str:
    """Extract standardized roast level"""
    roast_fields = ['roast', 'roast _level', 'roast_level']
    for field in roast_fields:
        if additional.get(field):
            roast = str(additional[field]).lower()
            if 'light' in roast:
                return 'Light'
            elif 'medium' in roast:
                return 'Medium'
            elif 'dark' in roast:
                return 'Dark'
            elif 'espresso' in roast:
                return 'Espresso'
    return None

def extract_grind_size(additional: Dict) -> str:
    """Extract grind size information"""
    grind_fields = ['grind_size', 'grind _size', 'grind size']
    for field in grind_fields:
        if additional.get(field):
            return str(additional[field])
    return None

def extract_origin(additional: Dict) -> str:
    """Extract coffee origin"""
    origin_fields = ['origin', 'country', 'region']
    for field in origin_fields:
        if additional.get(field):
            return str(additional[field])
    return None

def extract_weight(additional: Dict) -> str:
    """Extract weight information"""
    weight_fields = ['weight', 'size', 'pack _size']
    for field in weight_fields:
        if additional.get(field):
            weight = str(additional[field])
            # Standardize weight format
            if 'kg' in weight.lower() or 'kilogram' in weight.lower():
                return weight
            elif 'g' in weight.lower() or 'gram' in weight.lower():
                return weight
    return None

def generate_bigquery_schema(df: pd.DataFrame) -> str:
    """Generate BigQuery table schema"""
    
    schema_fields = []
    
    # Define field types based on data
    type_mapping = {
        'product_id': 'STRING',
        'brand': 'STRING',
        'roaster_name': 'STRING', 
        'title': 'STRING',
        'price': 'FLOAT64',
        'currency': 'STRING',
        'product_type': 'STRING',
        'description': 'STRING',
        'availability': 'STRING',
        'sku': 'STRING',
        'url': 'STRING',
        'material': 'STRING',
        'size': 'STRING',
        'color': 'STRING',
        'created_at': 'TIMESTAMP',
        'updated_at': 'TIMESTAMP',
        'published_at': 'TIMESTAMP',
        'primary_image': 'STRING',
        'secondary_images': 'JSON',
        'total_images': 'INT64',
        'all_tags': 'JSON',
        'coffee_tags': 'JSON',
        'equipment_tags': 'JSON',
        'tag_count': 'INT64',
        'roast': 'STRING',
        'grind_size': 'STRING',
        'origin': 'STRING',
        'weight': 'STRING',
        'roast_date': 'STRING',
        'model': 'STRING',
        'finish': 'STRING',
        'material_type': 'STRING',
        'subscription_plan': 'STRING',
        'quantity_per_month': 'STRING'
    }
    
    for col in df.columns:
        if col in type_mapping:
            schema_fields.append(f"  {col}: {type_mapping[col]}")
    
    schema = "[\n" + ",\n".join(schema_fields) + "\n]"
    return schema

if __name__ == "__main__":
    # Example usage (replace with actual JSON file path)
    json_file = "Apify-raw-data/apify-raw-data.json"
    
    print("=== JSON vs CSV Processing Benefits ===")
    print("✅ Preserves nested structure")
    print("✅ No sparse columns (hundreds of empty additional/* fields)")
    print("✅ Better BigQuery integration")
    print("✅ More efficient storage")
    print("✅ Easier schema evolution")
    print("✅ Native support for arrays and objects")
    
    # If you have the JSON file, uncomment below:
    df = process_apify_json(json_file)
    schema = generate_bigquery_schema(df)
    df.to_csv('Apify-raw-data/apify-raw-data.csv', index=False)
    print(f"\nGenerated BigQuery schema:\n{schema}")
