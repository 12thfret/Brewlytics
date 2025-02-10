-- Title, Vendor, Price, Weight, Roast Profile, Acidity, Country, Process, Flavour Notes, Variety, Min Altitude, Max Altitude
CREATE TABLE `specialitycoffee.intermediate_files.dutchcolonyco_intermediate` AS

SELECT 
Title,
Vendor,
`Variant Price` as Price,
`Variant Part 1` as Weight,
CASE 
WHEN `Roast Type` = "espresso" THEN "Espresso"
WHEN `Roast Type` = "filter" THEN "Filter"
WHEN `Roast Type` = "omni" THEN "Omni"
ELSE "Unknown"
END AS `Roast Type`,
region as Region,
  CASE
    -- Map Brazilian regions
    WHEN region LIKE '%Cerrado%' OR region LIKE '%Sul De Minas%' THEN 'Brazil'
    
    -- Map Indonesian blends (e.g., Aceh Gayo is in Indonesia)
    WHEN region LIKE '%Hutapung%' OR region LIKE '%Aceh Gayo%' THEN 'Indonesia'
    
    -- Map Indian regions (e.g., Chikmagalur, Giris)
    WHEN region LIKE '%Chikmagalur%' OR region LIKE '%Giris%' THEN 'India'
    
    -- Map Ethiopian regions (check for common Ethiopian terms)
    WHEN region LIKE '%Southern Nations%' 
      OR region LIKE '%Gedeo%' 
      OR region LIKE '%Yirgacheffe%' 
      OR region LIKE '%SNNPR%' 
      OR region LIKE '%Gediyo%' 
      OR region LIKE '%Worka%' THEN 'Ethiopia'
    
    -- Map Mexican regions
    WHEN region LIKE '%Mexico%' THEN 'Mexico'
    
    -- Map Kenyan regions (e.g., Embu Town)
    WHEN region LIKE '%Embu Town%' THEN 'Kenya'
    
    -- Map Colombian regions
    WHEN region LIKE '%Cauca%' THEN 'Colombia'
    
    -- Map Costa Rican regions (e.g., Turrialba, Aquiares)
    WHEN region LIKE '%Turrialba%' OR region LIKE '%Aquiares%' THEN 'Costa Rica'
    
    ELSE 'Unknown'
  END AS Country,
  Process,
  CASE WHEN `Flavour Notes` = "Espresso" THEN "Blend"
  ELSE `Flavour Notes`
  END AS `Flavour Notes`,
  Varietal as Variety,
    CASE
    WHEN REGEXP_CONTAINS(Altitude, r'-') THEN CAST(TRIM(REGEXP_EXTRACT(Altitude, r'^(\d+)')) AS INT64)
    WHEN REGEXP_CONTAINS(Altitude, r'\d+') THEN CAST(REGEXP_EXTRACT(Altitude, r'(\d+)') AS INT64)
    ELSE NULL
  END AS `Min Elevation`,
  CASE
    WHEN REGEXP_CONTAINS(Altitude, r'-') THEN CAST(TRIM(REGEXP_EXTRACT(Altitude, r'-\s*(\d+)')) AS INT64)
    WHEN REGEXP_CONTAINS(Altitude, r'\d+') THEN CAST(REGEXP_EXTRACT(Altitude, r'(\d+)') AS INT64)
    ELSE NULL
  END AS `Max Elevation`,
  `Product Type`

FROM
`specialitycoffee.raw_files.dutchcolonyco_raw`

