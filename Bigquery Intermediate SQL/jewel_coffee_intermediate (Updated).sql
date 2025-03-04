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

CREATE OR REPLACE TABLE `specialitycoffee.intermediate_files.jewel_coffee_intermediate` AS

WITH CTE AS (
SELECT
  REGEXP_EXTRACT(title, r'^(.*)\s+\S+$') AS Title,
  REGEXP_EXTRACT(title, r'(\S+)$') AS grams,
  "Jewel Coffee" as Vendor,
  `Variant Price` as Price,
  `Cup Characteristics` as `Flavour Notes`,
  "Unknown" AS Region,
  CASE
    WHEN REGEXP_CONTAINS(origins, r'(?i)Brazil.*Sumatra|Sumatra.*Brazil') THEN "Brazil, Indonesia"
    WHEN REGEXP_CONTAINS(origins, r'(?i)El Salvador\s*\+\s*Ethiopia\s*\+\s*Indonesia') THEN 'El Salvador, Ethiopia, Indonesia'
    WHEN REGEXP_CONTAINS(origins, r'(?i)Ethiopia\s*\+\s*Indonesia') THEN 'Ethiopia, Indonesia'
    WHEN REGEXP_CONTAINS(origins, r'(?i)Central America\s*\+\s*East Africa') THEN 'Central America, East Africa'
    WHEN REGEXP_CONTAINS(origins, r'(?i)Brazil\s*\+\s*Ethiopia\s*\+\s*Sumatra') THEN 'Brazil, Ethiopia, Indonesia'
    WHEN REGEXP_CONTAINS(origins, r'(?i)Brazil,\s*Peru') THEN 'Brazil, Peru'
    WHEN lower(title) LIKE "%brazil%" THEN 'Brazil'
    WHEN lower(title) LIKE "%ethiopia%" THEN 'Ethiopia'
    WHEN lower(title) LIKE "%colombia%" THEN 'Colombia'
    WHEN lower(title) LIKE "%el salvador%" THEN 'El Salvador'
    WHEN lower(title) LIKE "%sumatra%" THEN 'Indonesia'
    WHEN lower(title) LIKE "%tanzania%" THEN 'Tanzania'
    ELSE origins
  END AS Country,
  Varietal as Variety,
  Process,
  `Primary Image URL` as `Image URL`
FROM 
`specialitycoffee.raw_files.jewel_coffee_raw`
)

SELECT 
*,
CASE 
    WHEN LOWER(grams) LIKE '%kg%' THEN SAFE_CAST(REGEXP_EXTRACT(grams, r'(\d+)') AS INT64) * 1000
    WHEN LOWER(grams) LIKE '%g%' THEN SAFE_CAST(REGEXP_EXTRACT(grams, r'(\d+)') AS INT64)
    ELSE NULL
END AS Weight
FROM CTE