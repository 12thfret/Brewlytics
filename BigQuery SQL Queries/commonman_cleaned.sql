CREATE TABLE `specialitycoffee.cleaned_files.commonman_cleaned` AS

SELECT 
CASE WHEN Title = "22 Martin Blend 1" THEN "22 Martin Blend"
ELSE Title
END AS Title,
Vendor,
Price,
CASE
    WHEN LOWER(weight) LIKE '%kg%' THEN 
      CAST(REGEXP_REPLACE(weight, r'[^0-9\.]', '') AS FLOAT64) * 1000
    WHEN LOWER(weight) LIKE '%g%' THEN 
      CAST(REGEXP_REPLACE(weight, r'[^0-9]', '') AS INT64)
    ELSE NULL
  END AS Weight,
  `Roast Type`,
  country as Country,
  Region,
  Process,
  `Flavour Notes`,
    CASE
    -- Values containing specific landrace codes indicate Ethiopian landraces.
    WHEN variety LIKE '%74110%' OR variety LIKE '%74112%' OR variety LIKE '%74165%' THEN 'Ethiopian Landrace'
    -- If it is "Wush Wush" then consider it an Ethiopian traditional variety.
    WHEN LOWER(variety) = 'wush wush' THEN 'Ethiopian'
    -- If it contains "Red Bourbon", we map it to Bourbon (typically Latin American).
    WHEN variety LIKE '%Red Bourbon%' THEN 'Bourbon'
    -- If it contains both "Catuai" and "Typica" (with or without extra information like Chiang Mai or SJ133)
    WHEN variety LIKE '%Catuai%' AND variety LIKE '%Typica%' THEN 'Catuai/Typica'
    -- If it contains "Caturra"
    WHEN variety LIKE '%Caturra%' THEN 'Caturra'
    -- If it is "Mixed"
    WHEN LOWER(variety) LIKE '%mixed%' THEN 'Mixed'
    ELSE 'Other'
  END AS Variety,
  min_elevation as `Min Elevation`,
  max_elevation as `Max Elevation`
 FROM `specialitycoffee.intermediate_files.commonman_intermediate` 