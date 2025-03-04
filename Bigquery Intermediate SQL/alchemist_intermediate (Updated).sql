-- Title
-- Weight
-- Vendor
-- Price
-- Flavour Notes
-- Region
-- Country
-- Variety
-- Process
-- Image URL

CREATE OR REPLACE TABLE `specialitycoffee.intermediate_files.alchemist_intermediate` AS
WITH cleaned_data AS (
  SELECT 
    string_field_0 AS Title,
  CASE 
    WHEN LOWER(string_field_1) LIKE '%kg%' THEN CAST(REGEXP_EXTRACT(string_field_1, r'(\d+\.?\d*)') AS INT64) * 1000
    WHEN LOWER(string_field_1) LIKE '%g%' THEN CAST(REGEXP_EXTRACT(string_field_1, r'(\d+\.?\d*)') AS INT64)
    ELSE NULL
  END AS Weight,
  "Alchemist" as Vendor,
    SAFE_CAST(REGEXP_REPLACE(string_field_3, r'S\$', '') AS FLOAT64) AS Price,
    string_field_7 AS `Flavour Notes`,
    -- Extracting Region: Everything before the first " - "
    "Unknown" as Region,
    TRIM(REGEXP_REPLACE(string_field_5, r' - .*$', '')) AS Country,
    "Unknown" as Variety,
    -- Extracting Processing: Everything after the first " - "
    TRIM(REGEXP_REPLACE(string_field_5, r'^.*? - ', '')) AS Process,
    string_field_8 AS `Image URL`,
    string_field_2 AS Brewing,
    string_field_6 AS Description,
  FROM specialitycoffee.raw_files.alchemist_raw
)

SELECT *
FROM cleaned_data;

