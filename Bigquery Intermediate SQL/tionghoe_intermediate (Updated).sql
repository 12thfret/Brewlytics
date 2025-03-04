CREATE OR REPLACE TABLE `specialitycoffee.intermediate_files.tionghoe_intermediate` AS
WITH cleaned_data AS (
  SELECT 

    string_field_2 AS Title,
  CASE 
    WHEN LOWER(string_field_1) LIKE '%kg%' THEN CAST(REGEXP_EXTRACT(string_field_1, r'(\d+\.?\d*)') AS INT64) * 1000
    WHEN LOWER(string_field_1) LIKE '%g%' THEN CAST(REGEXP_EXTRACT(string_field_1, r'(\d+\.?\d*)') AS INT64)
    ELSE NULL
  END AS Weight,
  "Tionghoe" as Vendor,
    -- Clean price: Remove "S$" and cast to FLOAT
    SAFE_CAST(REGEXP_REPLACE(string_field_4, r'S\$', '') AS FLOAT64) AS Price,
    
    -- Flavor, Body, Aftertaste
    string_field_5 AS  `Flavour Notes`,
    string_field_6 AS Body,
    string_field_7 AS Aftertaste,

    REGEXP_EXTRACT(string_field_8, r'^(.*?)\s+Varietal') AS Region,
    CASE 
    WHEN LOWER(string_field_8) LIKE '%antioquia%' THEN 'Colombia'
    WHEN LOWER(string_field_8) LIKE '%quindio%' THEN 'Colombia'
    WHEN LOWER(string_field_8) LIKE '%popayan%' THEN 'Colombia'
    WHEN LOWER(string_field_8) LIKE '%cauca%' THEN 'Colombia'
    WHEN LOWER(string_field_8) LIKE '%turrialba%' THEN 'Costa Rica'
    WHEN LOWER(string_field_8) LIKE '%aquiares%' THEN 'Costa Rica'
    WHEN LOWER(string_field_8) LIKE '%embu%' THEN 'Kenya'
    WHEN LOWER(string_field_8) LIKE '%sumatra%' THEN 'Indonesia'
    WHEN LOWER(string_field_8) LIKE '%aceh%' THEN 'Indonesia'
    WHEN LOWER(string_field_8) LIKE '%guji%' THEN 'Ethiopia'
    WHEN LOWER(string_field_8) LIKE '%oromia%' THEN 'Ethiopia'
    WHEN LOWER(string_field_8) LIKE '%kayanza%' THEN 'Burundi'
    WHEN LOWER(string_field_8) LIKE '%karntaka%' THEN 'India'
    WHEN LOWER(string_field_8) LIKE '%western ghats%' THEN 'India'
    WHEN LOWER(string_field_8) LIKE '%esquipulas%' THEN 'Guatemala'
    WHEN LOWER(string_field_8) LIKE '%chiquimula%' THEN 'Guatemala'
    WHEN LOWER(string_field_8) LIKE '%minas gerais%' THEN 'Brazil'
    WHEN LOWER(string_field_8) LIKE '%north sumatra%' THEN 'Indonesia'
    WHEN LOWER(string_field_8) LIKE '%armenian%' THEN 'Colombia'
    WHEN LOWER(string_field_8) LIKE '%santa monica%' THEN 'Colombia'
    ELSE 'Unknown'
  END AS Country,

    -- Extract Varietal from string_field_9 or from string_field_8 if concatenated
    COALESCE(
      REGEXP_EXTRACT(string_field_8, r'Varietal\s+(.*?)\s+Process'),
      REGEXP_EXTRACT(string_field_9, r'^(.*?)\s+Process'),
      string_field_9
    ) AS Variety,

    -- Extract Process from string_field_10 or from concatenated fields
    COALESCE(
      REGEXP_EXTRACT(string_field_8, r'Process\s+(.*)'),
      REGEXP_EXTRACT(string_field_9, r'Process\s+(.*)'),
      string_field_10
    ) AS Process,

    string_field_11 as `Image URL`

  FROM specialitycoffee.raw_files.tionghoe_raw
)

SELECT *
FROM cleaned_data;
