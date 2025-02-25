# About The Project

This project focuses on building a web scraper to gather data from Singapore Coffee Roasters. It extracts detailed product information such as titles, prices, and attributes like region, variety, and elevation. The primary goal is to streamline data extraction and produce structured outputs for analysis or business insights. The creation of an App that will list these scraped products for viewing is also in the pipeline.

<p align="right"></p>

### Data Flow & Tech Stack

The project’s data flow and tech stack are as follows:

- **Data Extraction**

The scraper uses the requests library to make HTTP calls to the Coffee Roasters website.
Pagination is handled to ensure comprehensive coverage of all products.
Data Parsing

The HTML content is parsed using BeautifulSoup, extracting relevant details embedded within product pages.
Data Cleaning & Formatting

Regular expressions (re) help identify and extract product attributes like Region, Variety, and Elevation from textual descriptions.
Extracted data is structured with consistent keys (Title, Price, Region, Variety, Elevation).
Data Storage & Automation

Google Cloud Functions (2nd Gen) automates the entire scraping process.
The scraper outputs a CSV in memory, which is then uploaded to Google Cloud Storage (GCS).
The CSV file is loaded into Google BigQuery for downstream analysis.
Pub/Sub and Cloud Scheduler can be configured to trigger this function on a defined schedule (e.g., monthly).
Further Data Processing

SQL queries in BigQuery handle advanced data transformations.
Data is organized into raw, intermediate, and cleaned datasets—creating data marts that support streamlined querying and reporting.

### Architecture Overview
<img width="1042" alt="image" src="https://github.com/user-attachments/assets/4b589326-105a-402d-b558-2464b1d6da32" />

- **Cloud Scheduler (Optional)**
Triggers a Pub/Sub message on a fixed schedule (e.g., monthly).

- **Pub/Sub**
Passes the message to the Cloud Function.

- **Cloud Function (2nd Gen)**
Scrapes the website with requests and BeautifulSoup.
Cleans and structures the data.
Generates a CSV in memory.
Uploads the CSV to Cloud Storage.
Loads data from Cloud Storage into BigQuery.

- **BigQuery**
Stores and processes the scraped data for further analysis or business insights.

### Tech Stack Summary
- **Python**: Core programming language.
- **Requests**: Fetch HTML from the Coffee Roasters website.
- **BeautifulSoup**: Parse and extract HTML elements.
- **re** (Regular Expressions): Dynamically locate key attributes (e.g., Region, Variety, Elevation).
- **CSV**: Store structured data before uploading to GCS.
- **Google Cloud Storage**: Temporary holding of CSV files for ingestion.
- **Google BigQuery**: Central data warehouse for large-scale storage and analysis.
- **Cloud Functions (2nd Gen)**: Serverless environment for automating the scraping and ingestion.
- **Pub/Sub**: Messaging service for triggering the function.
- **Cloud Scheduler**: Optional scheduling service to run the function at intervals (e.g., monthly).

<p align="right">(<a href="#readme-top">back to top</a>)</p>


### Example
This code is a Google Cloud Function that scrapes product data from a website (in this case, "nylon.coffee"), generates a CSV file in memory, uploads it to Google Cloud Storage, and then loads it into BigQuery.

### Step-by-Step Breakdown

#### 1. **Importing Libraries**
   ```python
   import csv
   import io
   import json
   import datetime
   import requests
   from bs4 import BeautifulSoup
   import base64

   from google.cloud import storage
   from google.cloud import bigquery
   import functions_framework  
   ```

   These are all the necessary libraries:
   - `csv` and `io` are used for handling CSV creation and in-memory writing.
   - `json` is used for parsing JSON responses from the website.
   - `datetime` is for creating timestamps for file names.
   - `requests` and `BeautifulSoup` are for scraping the website.
   - `base64` is for handling Pub/Sub encoded data.
   - `google.cloud` libraries are for interacting with Cloud Storage and BigQuery.
   - `functions_framework` is used to define the Cloud Function.

#### 2. **Configuration Variables**
   ```python
   bucket_name = 'brewlytics_raw'
   project_name = 'specialitycoffee'
   dataset_name = 'raw_files'
   table_name = 'nylon_raw'
   ```
   These are the configuration variables for Cloud Storage and BigQuery.

#### 3. **generate_data Function** (Main function)
   This function handles the scraping, CSV generation, upload to Cloud Storage, and loading into BigQuery.

   ##### a. **Base URLs & Headers for Scraping**
   ```python
   collection_url = "https://nylon.coffee/collections/coffee"
   product_base_url = "https://nylon.coffee/products/"

   headers = {
       "User-Agent": (
           "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
           "AppleWebKit/537.36 (KHTML, like Gecko) "
           "Chrome/89.0.4389.82 Safari/537.36"
       )
   }
   ```
   - `collection_url` is the page listing the products.
   - `product_base_url` is used to get detailed information for each product.
   - The `headers` section mimics a browser request to avoid being blocked by the website.

   ##### b. **Scraping the Collection Page**
   ```python
   response = requests.get(collection_url, headers=headers)
   collection_soup = BeautifulSoup(response.text, "html.parser")
   product_cards = collection_soup.find_all("product-card")
   ```
   - The collection page is fetched and parsed using BeautifulSoup. The `product-cards` are the elements representing individual products.

   ##### c. **Scraping Product Data**
   ```python
   for card in product_cards:
       handle = card.get("handle", "N/A")
       primary_image = card.find("img", class_="product-card__image--primary")
       primary_image_url = f"https:{primary_image['src']}" if primary_image else "N/A"
       sold_out_badge = card.find("sold-out-badge")
       is_sold_out = sold_out_badge.text.strip() if sold_out_badge else "In Stock"
       tasting_notes_element = card.find("div", class_="product-tasting")
       tasting_notes = tasting_notes_element.text.strip() if tasting_notes_element else "N/A"
   ```
   - For each product card, several pieces of information are scraped: `handle`, `primary_image_url`, `is_sold_out`, and `tasting_notes`.
   - It uses BeautifulSoup to find the respective HTML elements and extracts the required information.

   ##### d. **Visit Product Pages for More Details**
   ```python
   product_url = f"{product_base_url}{handle}"
   product_response = requests.get(product_url, headers=headers)
   product_soup = BeautifulSoup(product_response.text, "html.parser")
   ```
   - For each product, a request is made to the individual product page to gather more detailed data.

   ##### e. **Extract Feature Chart Details**
   ```python
   feature_chart = product_soup.find("div", class_="feature-chart__table")
   features = {}
   if feature_chart:
       rows = feature_chart.find_all("div", class_="feature-chart__table-row")
       for row in rows:
           heading = row.find("div", class_="feature-chart__heading")
           value = row.find("div", class_="feature-chart__value")
           if heading and value:
               features[heading.text.strip()] = value.text.strip()
   ```
   - Scrapes additional product details from a feature chart (if available).

   ##### f. **Extract Product Variants Using JSON-LD**
   ```python
   script_tag = product_soup.find("script", type="application/ld+json")
   variants = []
   if script_tag:
       try:
           product_data_json = json.loads(script_tag.string)
           if "hasVariant" in product_data_json:
               for variant in product_data_json["hasVariant"]:
                   variant_data = {
                       "Variant Name": variant.get("name", "N/A"),
                       "Variant Price": variant.get("offers", {}).get("price", "N/A"),
                       "Variant Availability": variant.get("offers", {}).get("availability", "N/A"),
                   }
                   variants.append(variant_data)
       except Exception as e:
           print(f"Error parsing JSON: {e}")
   ```
   - Scrapes the product variants from the JSON-LD embedded in the page (if available).

   ##### g. **Prepare Data for CSV**
   If variants are available, it includes the variant details. If no variants exist, the base product data (with price) is used.
   ```python
   if variants:
       for variant in variants:
           variant_data = {
               "Handle": handle,
               "Primary Image URL": primary_image_url,
               "Availability": is_sold_out,
               "Tasting Notes": tasting_notes,
           }
           variant_data.update(features)
           variant_data.update(variant)
           products_data.append(variant_data)
   else:
       price_element = product_soup.find("meta", {"property": "product:price:amount"})
       base_price = price_element["content"] if price_element else "N/A"
       base_product_data = {
           "Handle": handle,
           "Primary Image URL": primary_image_url,
           "Availability": is_sold_out,
           "Tasting Notes": tasting_notes,
           "Variant Name": "Base Product",
           "Variant Price": base_price,
           "Variant Availability": is_sold_out,
       }
       base_product_data.update(features)
       products_data.append(base_product_data)
   ```

#### 4. **Generate CSV in Memory**
   ```python
   output = io.StringIO()
   if products_data:
       fieldnames = list(products_data[0].keys())
       writer = csv.DictWriter(output, fieldnames=fieldnames)
       writer.writeheader()
       writer.writerows(products_data)
   else:
       output.write("No data found.")
   ```
   - A CSV file is generated in memory from the scraped product data.

#### 5. **Upload CSV to Google Cloud Storage**
   ```python
   today = datetime.datetime.now().strftime('%Y-%m-%d')
   blob_name = f'cloud_function_data/coffee_products_{today}.csv'

   storage_client = storage.Client()
   bucket = storage_client.bucket(bucket_name)
   blob = bucket.blob(blob_name)
   blob.upload_from_string(csv_content, content_type="text/csv")
   print(f"Uploaded CSV to gs://{bucket_name}/{blob_name}")
   ```
   - The generated CSV is uploaded to Google Cloud Storage using the storage client.

#### 6. **Load CSV into BigQuery**
   ```python
   bigquery_client = bigquery.Client()
   table_id = f"{project_name}.{dataset_name}.{table_name}"
   job_config = bigquery.LoadJobConfig(
       autodetect=True,
       source_format=bigquery.SourceFormat.CSV,
       write_disposition='WRITE_TRUNCATE',
       skip_leading_rows=1  # skip the header row
   )
   uri = f"gs://{bucket_name}/{blob_name}"
   load_job = bigquery_client.load_table_from_uri(uri, table_id, job_config=job_config)
   load_job.result()  # Wait for the load job to complete

   destination_table = bigquery_client.get_table(table_id)
   print(f"Loaded {destination_table.num_rows} rows into {table_id}.")
   ```
   - The CSV is loaded into BigQuery after being uploaded to Cloud Storage.

#### 7. **Cloud Event Function (Pub/Sub Trigger)**
   ```python
   @functions_framework.cloud_event
   def hello_pubsub(cloud_event):
       event_data = cloud_event.data
       message = event_data.get("message", {})
       if "data" in message:
           decoded_data = base64.b64decode(message["data"]).decode("utf-8")
           print(f"Received message: {decoded_data}")
       else:
           print("No data in Pub/Sub message.")

       # Run the scraping + CSV + BigQuery process
       generate_data()
   ```
   - This function is triggered by a Pub/Sub event and invokes the `generate_data` function





