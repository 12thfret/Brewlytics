#!/usr/bin/env python3
"""
Simple CSV splitter by roaster name
"""

import csv
import os
from collections import defaultdict

def get_roaster_name(url):
    """Extract roaster name from URL"""
    if not url or '://' not in url:
        return 'unknown'
    
    # Get domain from URL
    domain = url.split('://')[1].split('/')[0]
    
    # Remove www and get first part
    if domain.startswith('www.'):
        domain = domain[4:]
    
    # Get the roaster name (first part before dot)
    roaster = domain.split('.')[0]
    return roaster.capitalize()

def main():
    # File paths
    input_file = "Apify-raw-data/apify-raw-data.csv"
    output_dir = "Roaster-data"
    
    print("Splitting CSV by roaster...")
    
    # Create output directory
    os.makedirs(output_dir, exist_ok=True)
    
    # Read and split data
    roaster_data = defaultdict(list)
    
    with open(input_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        headers = reader.fieldnames
        
        for row in reader:
            url = row.get('url', '')
            roaster = get_roaster_name(url)
            roaster_data[roaster].append(row)
    
    # Write separate files
    for roaster, rows in roaster_data.items():
        filename = f"{roaster.lower()}_products.csv"
        filepath = os.path.join(output_dir, filename)
        
        with open(filepath, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=headers)
            writer.writeheader()
            writer.writerows(rows)
        
        print(f"{roaster}: {len(rows)} products -> {filename}")
    
    print(f"\nDone! Files saved to {output_dir}/")

if __name__ == "__main__":
    main()
