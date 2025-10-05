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
CREATE OR REPLACE TABLE `specialitycoffee.intermediate_files.parchmen_intermediate` AS 

SELECT  
Title,
  CASE 
    WHEN LOWER(`Variant Part 1`) LIKE '%kg%' THEN CAST(REGEXP_EXTRACT(`Variant Part 1`, r'(\d+\.?\d*)') AS INT64) * 1000
    WHEN LOWER(`Variant Part 1`) LIKE '%g%' THEN CAST(REGEXP_EXTRACT(`Variant Part 1`, r'(\d+\.?\d*)') AS INT64)
    ELSE NULL
  END AS Weight,
"Parchmen & Co" as Vendor,
`Variant Price` as Price,
`Flavour Notes`,
"Unknown" as Region,
  CASE 
    WHEN LOWER(Title) LIKE '%ethiopia%' THEN 'Ethiopia'
    WHEN LOWER(Title) LIKE '%brazil%' THEN 'Brazil'
    WHEN LOWER(Title) LIKE '%colombia%' THEN 'Colombia'
    WHEN LOWER(Title) LIKE '%sidama%' THEN 'Ethiopia'
    WHEN LOWER(Title) LIKE '%mogiana%' THEN 'Brazil'
    WHEN LOWER(Title) LIKE '%popayán%' THEN 'Colombia'
    WHEN LOWER(Title) LIKE '%cofinet%' THEN 'Colombia'
    WHEN LOWER(Title) LIKE '%diofanor ruiz%' THEN 'Colombia'
    WHEN LOWER(Title) LIKE '%edwin noreña%' THEN 'Colombia'
    WHEN LOWER(Title) LIKE '%jairo arcila%' THEN 'Colombia'
    ELSE 'Unknown'
  END AS Country,
"Unknown" as Variety,
"Unknown" as Process,
`Primary Image URL` as `Image URL`,
Availability,
`Roast Type`,
FROM `specialitycoffee.raw_files.parchmen_raw` LIMIT 1000