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





