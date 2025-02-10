-- Title, Vendor, Price, Weight, Roast Profile, Acidity, Country, Process, Flavour Notes, Variety, Min Elevation, Max Elevation

CREATE TABLE `specialitycoffee.cleaned_files.percolate_cleaned` AS

SELECT  
Title,
`Product Name` as Vendor,
Price,
CASE
    WHEN LOWER(weight) LIKE '%kg%' THEN 
      CAST(REGEXP_REPLACE(weight, r'[^0-9\.]', '') AS FLOAT64) * 1000
    WHEN LOWER(weight) LIKE '%g%' THEN 
      CAST(REGEXP_REPLACE(weight, r'[^0-9]', '') AS INT64)
    ELSE NULL
  END AS Weight,
  Country,
  `Flavour Notes`
FROM `specialitycoffee.raw_files.percolate_raw` 