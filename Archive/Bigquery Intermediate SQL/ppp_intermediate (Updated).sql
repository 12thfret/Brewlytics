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
CREATE OR REPLACE TABLE `specialitycoffee.intermediate_files.ppp_beans_intermediate` AS
SELECT  
`Product Title` as Title,
  CASE 
    WHEN LOWER(`Variant Weight`) LIKE '%kg%' THEN CAST(REGEXP_EXTRACT(`Variant Weight`, r'(\d+\.?\d*)') AS INT64) * 1000
    WHEN LOWER(`Variant Weight`) LIKE '%g%' THEN CAST(REGEXP_EXTRACT(`Variant Weight`, r'(\d+\.?\d*)') AS INT64)
    ELSE NULL
  END AS Weight,
  "PPP Coffee" as Vendor,
Price as Price,
  `Flavour Notes`,
  TRIM(SPLIT(REGEXP_REPLACE(Country, '[,/]', '/'), '/')[SAFE_OFFSET(0)]) AS Country,
  TRIM(SPLIT(REGEXP_REPLACE(Country, '[,/]', '/'), '/')[SAFE_OFFSET(1)]) AS Region,
  Processing as Process,
  Varietal as Variety,
  `Image URL`


FROM `specialitycoffee.raw_files.ppp_beans_raw` LIMIT 1000