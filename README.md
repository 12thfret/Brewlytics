# About The Project

This project focuses on building a web scraper to gather data from Singapore Coffee Roasters. It extracts detailed product information such as titles, prices, and attributes like region, variety, and elevation. The primary goal is to streamline data extraction and produce structured outputs for analysis or business insights. The creation of an App that will list these scraped products for viewing is also in the pipeline.

<p align="right"></p>

### Data Flow & Tech Stack

The data flow for the project is as follows:

1. **Data Extraction**: Fetch data from the Coffee Roasters website's using the `requests` library. Handle pagination to ensure comprehensive data coverage.
2. **Data Parsing**: Parse HTML content using `BeautifulSoup` to extract relevant details embedded within the product descriptions.
3. **Data Cleaning**: Use regular expressions to dynamically extract specific attributes such as "Region," "Variety," and "Elevation" from the textual content.
4. **Data Formatting**: Structure the extracted data into a consistent format with keys like Title, Price, Region, Variety, and Elevation.
5. **Data Storage**: Export the cleaned and structured data to a CSV file for further analysis using Google Big Query as the cloud data warehouse.
6. **Further Data Processing**: Utilize SQL within Google Big Query to conduct further cleaning, transformation, and analysis. Implement a tiered data warehousing strategy with raw, intermediate, and cleaned datasets organized into data marts for streamlined querying and reporting.

The tech stack includes:
- **Python**: Core programming language used for the scraper.
- **Requests**: Fetch API data from the website.
- **BeautifulSoup**: Parse and extract HTML content.
- **re (Regular Expressions)**: Dynamically identify and extract specific product attributes.
- **CSV Module**: Save structured data into a CSV format for downstream processes.
- **Google Big Query**: Cloud data warehouse for storing and processing large-scale data.
- **SQL**: Perform advanced data cleaning and create data marts for efficient analysis.


<p align="right">(<a href="#readme-top">back to top</a>)</p>





