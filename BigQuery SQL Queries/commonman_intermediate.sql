-- Title, Vendor, Price, Weight, Roast Profile, Acidity, Country, Process, Flavour Notes, Variety, Min Elevation, Max Elevation
CREATE TEMP FUNCTION toCap(s STRING) AS (
  ARRAY_TO_STRING(
    ARRAY(
      SELECT CONCAT(UPPER(SUBSTR(word, 1, 1)), LOWER(SUBSTR(word, 2)))
      FROM UNNEST(SPLIT(s, ' ')) AS word
    ),
    ' '
  )
);


CREATE TABLE `specialitycoffee.intermediate_files.commonman_intermediate` AS


SELECT
  InitCap(REPLACE(handle, '-', ' ')) AS Title,
  "Common Man Coffee Roasters" as Vendor,
  `Variant Price` as Price,
  `Variant Part 1` as Weight,
   REGEXP_EXTRACT(`Variant Part 2`, r'^(\w+)') AS `Roast Type`,
    CASE
    WHEN region LIKE '%Cauca%' THEN 'Colombia'
    WHEN region LIKE '%Gedeo%' OR region LIKE '%Yirgacheffe%' THEN 'Ethiopia'
    WHEN region LIKE '%Mubuga%' OR region LIKE '%Karongi%' THEN 'Rwanda'
    WHEN region LIKE '%Chiang Rai%' THEN 'Thailand'
    WHEN region LIKE '%Chimaltenango%' THEN 'Guatemala'
    WHEN region LIKE '%Oromia%' THEN 'Ethiopia'
    ELSE 'Unknown'
  END AS country,
  Region,
  Processing as Process,
  `Tasting Notes` as `Flavour Notes`,
  Variety,
    CASE 
    WHEN Altitude LIKE '%-%' THEN CAST(TRIM(SPLIT(Altitude, '-')[OFFSET(0)]) AS INT64)
    ELSE CAST(REGEXP_EXTRACT(Altitude, r'(\d+)') AS INT64)
  END AS min_elevation,
  CASE 
    WHEN Altitude LIKE '%-%' THEN CAST(TRIM(REGEXP_REPLACE(SPLIT(Altitude, '-')[OFFSET(1)], r'\D', '')) AS INT64)
    ELSE CAST(REGEXP_EXTRACT(Altitude, r'(\d+)') AS INT64)
  END AS max_elevation
FROM `specialitycoffee.raw_files.commonman_raw`
WHERE handle != "crowds-favourites"


