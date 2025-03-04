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

CREATE OR REPLACE TABLE `specialitycoffee.intermediate_files.commonman_intermediate` AS

WITH CTE AS (
SELECT
  ARRAY_TO_STRING(
    ARRAY(
      SELECT CONCAT(UPPER(SUBSTR(word, 1, 1)), LOWER(SUBSTR(word, 2)))
      FROM UNNEST(SPLIT(REPLACE(handle, '-', ' '), ' ')) AS word
    ),
    ' '
  ) AS Title,
  CASE 
    WHEN REGEXP_CONTAINS(`Variant Part 1`, r'(?i)\b500g\b|\b500\s*Gram\b') THEN '500'
    WHEN REGEXP_CONTAINS(`Variant Part 1`, r'(?i)\b250g\b|\b250\s*Gram\b') THEN '250'
    WHEN REGEXP_CONTAINS(`Variant Part 1`, r'(?i)\b1000g\b|\b1000\s*Gram\b') THEN '1000'
    ELSE NULL 
  END AS Weight,
  "Common Man Coffee Roasters" AS Vendor,
  `Variant Price` AS Price,
  `Tasting Notes` AS `Flavour Notes`,
  Region,
  REGEXP_EXTRACT(`Variant Part 2`, r'^(\w+)') AS `Roast Type`,
  Variety,
  Processing AS Process,
  `Primary Image URL` AS `Image URL`,
  CASE 
    WHEN Altitude LIKE '%-%' THEN CAST(TRIM(SPLIT(Altitude, '-')[OFFSET(0)]) AS INT64)
    ELSE CAST(REGEXP_EXTRACT(Altitude, r'(\d+)') AS INT64)
  END AS `Min Elevation`,
  CASE 
    WHEN Altitude LIKE '%-%' THEN CAST(TRIM(REGEXP_REPLACE(SPLIT(Altitude, '-')[OFFSET(1)], r'\D', '')) AS INT64)
    ELSE CAST(REGEXP_EXTRACT(Altitude, r'(\d+)') AS INT64)
  END AS `Max Elevation`,
  `Variant Part 2` AS Brewing,
  Producer,
  `Variant Availability` AS Availability,
  Harvest
FROM `specialitycoffee.raw_files.commonman_raw`
WHERE handle != "crowds-favourites"
) 

SELECT *,
  -- Extract Country from Title first, and if NULL, fall back on Region-based logic
  COALESCE(
    CASE 
      WHEN Title LIKE '%Guatemala%' THEN 'Guatemala'
      WHEN Title LIKE '%Ethiopia%' THEN 'Ethiopia'
      WHEN Title LIKE '%El Salvador%' THEN 'El Salvador'
      WHEN Title LIKE '%Colombia%' THEN 'Colombia'
      WHEN Title LIKE '%Thailand%' THEN 'Thailand'
      WHEN Title LIKE '%Rwanda%' THEN 'Rwanda'
      WHEN Title LIKE '%Brazil%' THEN 'Brazil'
      ELSE NULL
    END,
    CASE 
      WHEN Region LIKE '%Cauca%' THEN 'Colombia'
      WHEN Region LIKE '%Gedeo%' OR Region LIKE '%Yirgacheffe%' THEN 'Ethiopia'
      WHEN Region LIKE '%Mubuga%' OR Region LIKE '%Karongi%' THEN 'Rwanda'
      WHEN Region LIKE '%Chiang Rai%' THEN 'Thailand'
      WHEN Region LIKE '%Chimaltenango%' THEN 'Guatemala'
      WHEN Region LIKE '%Oromia%' THEN 'Ethiopia'
      ELSE 'Unknown'
    END
  ) AS Country
FROM CTE;

