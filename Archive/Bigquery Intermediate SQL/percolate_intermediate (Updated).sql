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

CREATE OR REPLACE TABLE `specialitycoffee.intermediate_files.percolate_intermediate` AS
SELECT 
  -- Extract Title before the first comma
  SPLIT(string_field_4, ', ')[SAFE_OFFSET(0)] AS Title,

  -- Extract Weight from string_field_4 (primary source) or string_field_5 (fallback)
  COALESCE(
    REGEXP_EXTRACT(string_field_4, r'(\d+)g'),
    CASE 
      WHEN REGEXP_CONTAINS(string_field_5, r'(?i)\b1000g\b|\b1000\s*Gram\b') THEN '1000'
      WHEN REGEXP_CONTAINS(string_field_5, r'(?i)\b500g\b|\b500\s*Gram\b') THEN '500'
      WHEN REGEXP_CONTAINS(string_field_5, r'(?i)\b250g\b|\b250\s*Gram\b') THEN '250'
      WHEN REGEXP_CONTAINS(string_field_5, r'(?i)\b125g\b|\b125\s*Gram\b') THEN '125'
      WHEN REGEXP_CONTAINS(string_field_5, r'(?i)\b100g\b|\b100\s*Gram\b') THEN '100'
      ELSE NULL 
    END
  ) AS Weight,

  string_field_1 AS Vendor,

  -- Extract numeric value from Price field
  SAFE_CAST(REGEXP_EXTRACT(string_field_6, r'(\d+)') AS INT64) AS Price,

  string_field_7 AS `Flavour Notes`,

  "Unknown" AS Region,

  -- Extract Country but remove weight if present
  REGEXP_REPLACE(SPLIT(string_field_4, ', ')[SAFE_OFFSET(1)], r'\s*\d+g\s*', '') AS Country,

  "Unknown" AS Variety,
  "Unknown" AS Process,
  string_field_8 AS `Image URL`,
  string_field_2 AS Brewing

FROM `specialitycoffee.raw_files.percolate_raw`
