CREATE TABLE `specialitycoffee.cleaned_files.dutchcolonyco_cleaned` AS

SELECT 
Title,
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
  CASE WHEN `Flavour Notes` LIKE "%numero undici%" THEN "Persimmon. Yuzu. Dulce De Leche. Butter Cookie."
  ELSE `Flavour Notes`
  END AS `Flavour Notes`,
    CASE
    WHEN variety LIKE '%Arara%' THEN 'Arara'
    WHEN variety LIKE '%Catuai 99%' THEN 'Catuai'
    WHEN variety LIKE '%Catucai%' OR variety LIKE '%Catuai & Acaia%' THEN 'Catuai'
    WHEN variety LIKE '%Typica, Catimor%' THEN 'Typica/Catimor'
    WHEN variety LIKE '%Catuai, Chandragiri%' THEN 'Catuai'
    WHEN variety LIKE '%Local Landraces%' OR variety LIKE '%JARC 74%' THEN 'Local Landrace'
    WHEN variety LIKE '%74110%' THEN 'Ethiopian Landrace'
    WHEN variety LIKE '%Typica, Marsellesa, Bourbon%' THEN 'Bourbon'
    WHEN variety LIKE '%Ruiru 11%' OR variety LIKE '%SL 28%' OR variety LIKE '%Batian%' THEN 'Kenyan Varieties'
    WHEN variety LIKE '%Chiroso%' THEN 'Chiroso'
    WHEN variety LIKE '%Rio Brilhante Arara%' THEN 'Arara'
    WHEN variety LIKE '%Colombia & Caturra%' OR variety LIKE '%Caturra%' THEN 'Caturra'
    WHEN variety LIKE '%Centroamericano%' THEN 'Central American'
    ELSE 'Other'
  END AS Variety,
  `Min Elevation`,
  `Max Elevation`,
  `Product Type`

 FROM `specialitycoffee.intermediate_files.dutchcolonyco_intermediate` 
 WHERE Title NOT LIKE "%Coffee Taster's Pack%"