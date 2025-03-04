CREATE OR REPLACE TABLE `specialitycoffee.intermediate_files.nylon_intermediate` AS

With CTE AS (
SELECT
  INITCAP(REPLACE(Handle, '-', ' ')) AS Title,
  CASE
    WHEN LOWER(`Variant Name`) = 'base product' THEN 250
    WHEN REGEXP_CONTAINS(`Variant Name`, r'(\d+)\s*(g|kg)') THEN 
      CASE 
        WHEN REGEXP_CONTAINS(`Variant Name`, r'(\d+)\s*kg') THEN CAST(REGEXP_EXTRACT(`Variant Name`, r'(\d+)\s*kg') AS INT64) * 1000
        ELSE CAST(REGEXP_EXTRACT(`Variant Name`, r'(\d+)\s*g') AS INT64)
      END
    ELSE NULL
  END AS Weight,
  "Nylon Coffee Roasters" as Vendor,
  `Variant Price` AS Price,
  `Tasting Notes` as `Flavour Notes`,
  Region,
  REGEXP_EXTRACT(Region, r',\s*([^,]+)$') AS Country,
  Variety,
  Processing as Process,
  `Primary Image URL` as `Image URL`,
  CASE
    -- For ranges like "1700 - 1900 masl"
    WHEN REGEXP_CONTAINS(Altitude, r'^\d{1,4}(,\d{3})?\s*-\s*\d{1,4}(,\d{3})?\s*masl$') THEN 
      CAST(REGEXP_REPLACE(SPLIT(Altitude, '-')[OFFSET(0)], r'[^\d]', '') AS INT64)
    -- For single values like "2150 masl"
    WHEN REGEXP_CONTAINS(Altitude, r'^\d{1,4}(,\d{3})?\s*masl$') THEN 
      CAST(REGEXP_REPLACE(Altitude, r'[^\d]', '') AS INT64)
    ELSE NULL
  END AS Min_Elevation,
  CASE
    -- For ranges like "1700 - 1900 masl"
    WHEN REGEXP_CONTAINS(Altitude, r'^\d{1,4}(,\d{3})?\s*-\s*\d{1,4}(,\d{3})?\s*masl$') THEN 
      CAST(REGEXP_REPLACE(SPLIT(Altitude, '-')[OFFSET(1)], r'[^\d]', '') AS INT64)
    -- For single values like "2150 masl"
    WHEN REGEXP_CONTAINS(Altitude, r'^\d{1,4}(,\d{3})?\s*masl$') THEN 
      CAST(REGEXP_REPLACE(Altitude, r'[^\d]', '') AS INT64)
    ELSE NULL
  END AS Max_Elevation,
  Availability,
  Harvest,
  Brewing,
  Producer,
FROM `specialitycoffee.raw_files.nylon_raw`
)


SELECT * FROM CTE