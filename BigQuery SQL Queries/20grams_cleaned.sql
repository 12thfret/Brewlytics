CREATE TABLE `specialitycoffee.cleaned_files.20grams_cleaned` AS

SELECT
    TRIM(
        REGEXP_REPLACE(`Product Title`, r'\s*-\s*(Filter|Espresso)\b', '')
    ) AS Title,
    Vendor AS Vendor,
    SAFE_MULTIPLY(Price, 100) as Price, 
    CAST(SPLIT(SPLIT(`Variant Title`, '/')[SAFE_OFFSET(1)], 'g')[SAFE_OFFSET(0)] AS INT64) AS Weight,
    Origin AS Country,
    Farm AS Farm,
    Producer,
    Location AS Region,
    Varietal AS Variety,
    Processed AS Process,
    CAST(REGEXP_EXTRACT(`Growing Altitude`, r'(\d+)') AS INT64) AS `Min Elevation`,
    CAST(REGEXP_EXTRACT(`Growing Altitude`, r'(\d+)') AS INT64) AS `Max Elevation`,
    Harvest,
    `Flavour Notes`,
    CASE
        WHEN CAST(REGEXP_EXTRACT(REPLACE(`Agtron Level`, ',', '.'), r'(\d+\.\d)') AS FLOAT64) >= 85 THEN "Very Light"
        WHEN CAST(REGEXP_EXTRACT(REPLACE(`Agtron Level`, ',', '.'), r'(\d+\.\d)') AS FLOAT64) BETWEEN 75 AND 84 THEN "Light"
        WHEN CAST(REGEXP_EXTRACT(REPLACE(`Agtron Level`, ',', '.'), r'(\d+\.\d)') AS FLOAT64) BETWEEN 65 AND 74 THEN "Medium"
        WHEN CAST(REGEXP_EXTRACT(REPLACE(`Agtron Level`, ',', '.'), r'(\d+\.\d)') AS FLOAT64) BETWEEN 55 AND 64 THEN "Medium-Dark"
        WHEN CAST(REGEXP_EXTRACT(REPLACE(`Agtron Level`, ',', '.'), r'(\d+\.\d)') AS FLOAT64) BETWEEN 45 AND 54 THEN "Dark"
        WHEN CAST(REGEXP_EXTRACT(REPLACE(`Agtron Level`, ',', '.'), r'(\d+\.\d)') AS FLOAT64) < 45 THEN "Very Dark"
        ELSE "Unknown"
    END AS `Roast Profile`,
    CASE
        WHEN `Product Title` LIKE '%Filter%' THEN 'Filter'
        WHEN `Product Title` LIKE '%Espresso%' THEN 'Espresso'
        ELSE 'Unknown'
    END AS Brewing,
    Available as Availability
FROM `specialitycoffee.raw_files.20grams_raw`
