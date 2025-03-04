-- Creating 20grams Intermediate Table

CREATE OR REPLACE TABLE `specialitycoffee.intermediate_files.20grams_intermediate` AS

SELECT
    TRIM(
        REGEXP_REPLACE(`Product Title`, r'\s*-\s*(Filter|Espresso)\b', '')
    ) AS Title,
    CAST(SPLIT(SPLIT(`Variant Title`, '/')[SAFE_OFFSET(1)], 'g')[SAFE_OFFSET(0)] AS INT64) AS Weight,
    Vendor AS Vendor,
    SAFE_MULTIPLY(Price, 100) as Price,
    `Flavour Notes`,
    Location AS Region,
    Origin AS Country,
    Varietal AS Variety,
    Processed AS Process,
    `Image URL`,

    Producer,
    Farm AS Farm,
    CAST(REGEXP_EXTRACT(`Growing Altitude`, r'(\d+)') AS INT64) AS `Min Elevation`,
    CAST(REGEXP_EXTRACT(`Growing Altitude`, r'(\d+)') AS INT64) AS `Max Elevation`,
    Harvest,
    CASE
        WHEN CAST(REGEXP_EXTRACT(REPLACE(`Agtron Level`, ',', '.'), r'(\d+\.\d)') AS FLOAT64) >= 85 THEN "Very Light"
        WHEN CAST(REGEXP_EXTRACT(REPLACE(`Agtron Level`, ',', '.'), r'(\d+\.\d)') AS FLOAT64) BETWEEN 75 AND 84 THEN "Light"
        WHEN CAST(REGEXP_EXTRACT(REPLACE(`Agtron Level`, ',', '.'), r'(\d+\.\d)') AS FLOAT64) BETWEEN 65 AND 74 THEN "Medium"
        WHEN CAST(REGEXP_EXTRACT(REPLACE(`Agtron Level`, ',', '.'), r'(\d+\.\d)') AS FLOAT64) BETWEEN 55 AND 64 THEN "Medium-Dark"
        WHEN CAST(REGEXP_EXTRACT(REPLACE(`Agtron Level`, ',', '.'), r'(\d+\.\d)') AS FLOAT64) BETWEEN 45 AND 54 THEN "Dark"
        WHEN CAST(REGEXP_EXTRACT(REPLACE(`Agtron Level`, ',', '.'), r'(\d+\.\d)') AS FLOAT64) < 45 THEN "Very Dark"
        ELSE "Unknown"
    END AS `Roast Profile`,
    CASE
        WHEN `Product Title` LIKE '%Filter%' THEN 'Filter'
        WHEN `Product Title` LIKE '%Espresso%' THEN 'Espresso'
        ELSE 'Unknown'
    END AS Brewing,
    Available as Availability,
    `Roasted Density`
FROM `specialitycoffee.raw_files.20grams_raw`;


-- Creating Alchemist Intermediate Table

CREATE OR REPLACE TABLE `specialitycoffee.intermediate_files.alchemist_intermediate` AS

WITH cleaned_data AS (
  SELECT 
    string_field_0 AS Title,
  CASE 
    WHEN LOWER(string_field_1) LIKE '%kg%' THEN CAST(REGEXP_EXTRACT(string_field_1, r'(\d+\.?\d*)') AS INT64) * 1000
    WHEN LOWER(string_field_1) LIKE '%g%' THEN CAST(REGEXP_EXTRACT(string_field_1, r'(\d+\.?\d*)') AS INT64)
    ELSE NULL
  END AS Weight,
  "Alchemist" as Vendor,
    SAFE_CAST(REGEXP_REPLACE(string_field_3, r'S\$', '') AS FLOAT64) AS Price,
    string_field_7 AS `Flavour Notes`,
    -- Extracting Region: Everything before the first " - "
    "Unknown" as Region,
    TRIM(REGEXP_REPLACE(string_field_5, r' - .*$', '')) AS Country,
    "Unknown" as Variety,
    -- Extracting Processing: Everything after the first " - "
    TRIM(REGEXP_REPLACE(string_field_5, r'^.*? - ', '')) AS Process,
    string_field_8 AS `Image URL`,
    string_field_2 AS Brewing,
    string_field_6 AS Description,
  FROM specialitycoffee.raw_files.alchemist_raw
)
SELECT *
FROM cleaned_data;


-- Creating commonman Intermediate Table

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
-- Creating cowpresso Intermediate Table

CREATE OR REPLACE TABLE `specialitycoffee.intermediate_files.cowpresso_intermediate` AS
WITH CTE AS (
  SELECT
  Title,
    CASE 
      WHEN REGEXP_CONTAINS(`Variant Title`, r'(?i)\b500g\b|\b500\s*Gram\b') THEN '500'
      WHEN REGEXP_CONTAINS(`Variant Title`, r'(?i)\b250g\b|\b250\s*Gram\b') THEN '250'
      WHEN REGEXP_CONTAINS(`Variant Title`, r'(?i)\b1000g\b|\b1000\s*Gram\b') THEN '1000'
      ELSE NULL 
    END AS Weight,
  Vendor,
  `Variant Price` as Price,
  `Flavour notes` as `Flavour Notes`,
  Region,
    CASE 
        -- Indonesia
        WHEN Region LIKE '%Batukaang%' THEN 'Indonesia'
        WHEN Region LIKE '%West Java%' THEN 'Indonesia'
        WHEN Region LIKE '%East Java%' THEN 'Indonesia'
        WHEN Region LIKE '%Angkola, Siripok%' THEN 'Indonesia'
        WHEN Region LIKE '%Lintong%' THEN 'Indonesia'

        -- Colombia
        WHEN Region LIKE '%Huila%' THEN 'Colombia'
        WHEN Region LIKE '%Colombia%' THEN 'Colombia'
        WHEN Region LIKE '%Andean, Paisaje Cultural Cafetero%' THEN 'Colombia'

        -- Ethiopia
        WHEN Region LIKE '%Yirgacheffe%' THEN 'Ethiopia'
        WHEN Region LIKE '%Guji%' THEN 'Ethiopia'

        -- Uganda
        WHEN Region LIKE '%Uganda%' THEN 'Uganda'

        -- Guatemala
        WHEN Region LIKE '%Guatemala%' THEN 'Guatemala'
        WHEN Region LIKE '%San Pedro Yepocapa%' THEN 'Guatemala'
        WHEN Region LIKE '%Villa Canales%' THEN 'Guatemala'
        WHEN Region LIKE '%Finca Pacaya%' THEN 'Guatemala'

        -- Papua New Guinea
        WHEN Region LIKE '%Jiwaka Province%' THEN 'Papua New Guinea'
        WHEN Region LIKE '%Waghi Valley%' THEN 'Papua New Guinea'

        -- Brazil
        WHEN Region LIKE '%Santos, Sao Paulo%' THEN 'Brazil'
        WHEN Region LIKE '%Fazenda Rancho Grande%' THEN 'Brazil'

        -- Mexico
        WHEN Region LIKE '%Soconusco%' THEN 'Mexico'

        -- Panama
        WHEN Region LIKE '%Boquete, Chiriqui Province%' THEN 'Panama'

        -- Congo
        WHEN Region LIKE '%Congo%' THEN 'Congo'

        -- Myanmar
        WHEN Region LIKE '%Kayah%' THEN 'Myanmar'

        -- Default if no match
        ELSE 'Unknown'
    END AS Country,
    Variety,
    Processing as Process,
    `Image URL`,
    Elevation,
    `Roast profile`,
    Acidity
  FROM `specialitycoffee.raw_files.cowpresso_raw`
)

SELECT * FROM CTE;

-- Creating dutchcolony Intermediate Table

CREATE OR REPLACE TABLE `specialitycoffee.intermediate_files.dutchcolony_intermediate` AS
SELECT 
  Title,
      CASE 
      WHEN REGEXP_CONTAINS(`Variant Part 1`, r'(?i)\b500g\b|\b500\s*Gram\b') THEN '500'
      WHEN REGEXP_CONTAINS(`Variant Part 1`, r'(?i)\b250g\b|\b250\s*Gram\b') THEN '250'
      WHEN REGEXP_CONTAINS(`Variant Part 1`, r'(?i)\b1000g\b|\b1000\s*Gram\b') THEN '1000'
      ELSE NULL 
  END AS Weight,
  Vendor,
  `Variant Price` as Price,
      CASE WHEN `Flavour Notes` = "Espresso" THEN "Blend"
      ELSE `Flavour Notes`
  END AS `Flavour Notes`,
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
  Varietal as Variety,
  Process,
  `Primary Image URL` as `Image URL`,
CASE 
WHEN `Roast Type` = "espresso" THEN "Espresso"
WHEN `Roast Type` = "filter" THEN "Filter"
WHEN `Roast Type` = "omni" THEN "Omni"
ELSE "Unknown"
END AS `Roast Type`,
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
  `Product Type`,
  Availability

FROM
`specialitycoffee.raw_files.dutchcolony_raw`;

-- Creating homeground_coffee Intermediate Table

CREATE OR REPLACE TABLE `specialitycoffee.intermediate_files.homeground_coffee_intermediate` AS

WITH split_titles AS (
  SELECT
    Title,
    Vendor,
    `Variant Price` AS Price,
    Grams as Weight,
    `Product Type` as `Roast Type`,
    `Tasting Notes` as `Flavour Notes`,
    SPLIT(title, ',') AS tokens,
    ARRAY_LENGTH(SPLIT(title, ',')) AS token_count,
    `Primary Image URL` as `Image URL`
  FROM `specialitycoffee.raw_files.homeground_coffee_raw`
)
SELECT
  TRIM(tokens[SAFE_OFFSET(0)]) AS Title,
  Weight,
  Vendor,
  Price,
  `Flavour Notes`,
  "Unknown" as Region,
  CASE WHEN Title = 'Vanta' THEN "Blend"
  WHEN Title = 'Glow In The Dark' THEN "Blend"
  ELSE TRIM(tokens[SAFE_OFFSET(token_count - 1)])
  END AS Country,
  CASE 
    WHEN token_count >= 4 THEN TRIM(tokens[SAFE_OFFSET(1)])
    ELSE NULL
  END AS Variety,
  CASE 
    WHEN token_count = 3 THEN TRIM(tokens[SAFE_OFFSET(1)])
    WHEN token_count >= 4 THEN TRIM(tokens[SAFE_OFFSET(2)])
    ELSE NULL
  END AS Process,
  `Image URL`,
  `Roast Type` as Brewing,
FROM split_titles;

-- Creating jewel_coffee Intermediate Table

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
FROM CTE;


-- Creating Nylon Intermediate Table

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
SELECT * FROM CTE;

-- Creating parchmen Intermediate Table
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
FROM `specialitycoffee.raw_files.parchmen_raw`;

-- Creating percolate Intermediate Table

CREATE OR REPLACE TABLE `specialitycoffee.intermediate_files.percolate_intermediate` AS
SELECT 
  -- Extract Title before the first comma
  SPLIT(string_field_4, ', ')[SAFE_OFFSET(0)] AS Title,

  -- Extract Weight from string_field_4 (primary source) or string_field_5 (fallback)
  COALESCE(
    REGEXP_EXTRACT(string_field_4, r'(\d+)g'),
    CASE 
      WHEN REGEXP_CONTAINS(string_field_5, r'(?i)\b1000g\b|\b1000\s*Gram\b') THEN '1000'
      WHEN REGEXP_CONTAINS(string_field_5, r'(?i)\b500g\b|\b500\s*Gram\b') THEN '500'
      WHEN REGEXP_CONTAINS(string_field_5, r'(?i)\b250g\b|\b250\s*Gram\b') THEN '250'
      WHEN REGEXP_CONTAINS(string_field_5, r'(?i)\b125g\b|\b125\s*Gram\b') THEN '125'
      WHEN REGEXP_CONTAINS(string_field_5, r'(?i)\b100g\b|\b100\s*Gram\b') THEN '100'
      ELSE NULL 
    END
  ) AS Weight,

  string_field_1 AS Vendor,

  -- Extract numeric value from Price field
  SAFE_CAST(REGEXP_EXTRACT(string_field_6, r'(\d+)') AS INT64) AS Price,

  string_field_7 AS `Flavour Notes`,

  "Unknown" AS Region,

  -- Extract Country but remove weight if present
  REGEXP_REPLACE(SPLIT(string_field_4, ', ')[SAFE_OFFSET(1)], r'\s*\d+g\s*', '') AS Country,

  "Unknown" AS Variety,
  "Unknown" AS Process,
  string_field_8 AS `Image URL`,
  string_field_2 AS Brewing

FROM `specialitycoffee.raw_files.percolate_raw`;


-- Creating ppp_coffee Intermediate Table

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


FROM `specialitycoffee.raw_files.ppp_beans_raw`;

-- Creating splendour_coffee Intermediate Table

CREATE OR REPLACE TABLE `specialitycoffee.intermediate_files.splendourcoffee_intermediate` AS
WITH CTE AS (
SELECT 
REGEXP_EXTRACT(title, r'^(.*?)(?:\s*\(500g\)|\s500g)$') AS Title,
Grams as Weight,
"Splendour Coffee" as Vendor,
`Variant Price` as Price,
    CASE 
    WHEN LOWER(`Flavour Note`) LIKE '%berry%' OR LOWER(`Flavour Note`) LIKE '%fruit%' OR LOWER(`Flavour Note`) LIKE '%citrus%' 
         OR LOWER(`Flavour Note`) LIKE '%honey%' OR LOWER(`Flavour Note`) LIKE '%mocha%' OR LOWER(`Flavour Note`) LIKE '%rice-wine%' THEN 'Fruity'
    WHEN LOWER(`Flavour Note`) LIKE '%floral%' THEN 'Floral'
    WHEN LOWER(`Flavour Note`) LIKE '%citrus%' THEN 'Citrus'
    WHEN LOWER(`Flavour Note`) LIKE '%nutty%' OR LOWER(`Flavour Note`) LIKE '%nut%' OR LOWER(`Flavour Note`) LIKE '%creamy nutty%' THEN 'Nutty'
    WHEN LOWER(`Flavour Note`) LIKE '%chocolate%' OR LOWER(`Flavour Note`) LIKE '%cocoa%' OR LOWER(`Flavour Note`) LIKE '%mocha%' THEN 'Chocolatey'
    WHEN LOWER(`Flavour Note`) LIKE '%cinnamon%' OR LOWER(`Flavour Note`) LIKE '%spice%' THEN 'Spicy'
    WHEN LOWER(`Flavour Note`) LIKE '%milky%' OR LOWER(`Flavour Note`) LIKE '%cream%' OR LOWER(`Flavour Note`) LIKE '%smooth%' 
         OR LOWER(`Flavour Note`) LIKE '%herbal%' OR LOWER(`Flavour Note`) LIKE '%balanced%' OR LOWER(`Flavour Note`) LIKE '%complex%' 
         OR LOWER(`Flavour Note`) LIKE '%full-body%' OR LOWER(`Flavour Note`) LIKE '%bright%' OR LOWER(`Flavour Note`) LIKE '%sweetness%' 
         OR LOWER(`Flavour Note`) LIKE '%acidity%' OR LOWER(`Flavour Note`) LIKE '%brisk%' THEN 'Other'
    ELSE 'Uncategorized'
  END AS `Flavour Notes`,
  Region,
  CASE 
    WHEN LOWER(Region) LIKE '%ethiopia%' OR LOWER(Region) LIKE '%sidamo%' THEN 'Ethiopia'
    WHEN LOWER(Region) LIKE '%brazil%' OR LOWER(Region) LIKE '%siera do salitre%' THEN 'Brazil'
    WHEN LOWER(Region) LIKE '%colombia%' OR LOWER(Region) LIKE '%tolima%' OR LOWER(Region) LIKE '%casablanca%' THEN 'Colombia'
    WHEN LOWER(Region) LIKE '%indonesia%' OR LOWER(Region) LIKE '%toraja%' THEN 'Indonesia'
    WHEN LOWER(Region) LIKE '%tanzania%' OR LOWER(Region) LIKE '%arusha%' THEN 'Tanzania'
    WHEN LOWER(Region) LIKE '%panama%' OR LOWER(Region) LIKE '%volcan region%' THEN 'Panama'
    WHEN LOWER(Region) LIKE '%narok county%' OR LOWER(Region) LIKE '%lolgorian%' THEN 'Kenya'
    WHEN LOWER(Region) LIKE '%la paz%' OR LOWER(Region) LIKE '%intibuca%' OR LOWER(Region) LIKE '%comayagua%' THEN 'Honduras'
    ELSE 'Unknown'
  END AS Country,
  "Unknown" as Variety,
  "Unknown" as Process,
  `Primary Image URL` as `Image URL`,
  CAST(REGEXP_EXTRACT(Altitude, r'(\d{3,4})') AS INT64) AS  `Min Elevation`,
  CAST(REGEXP_EXTRACT(Altitude, r'-(\d{3,4})') AS INT64) AS `Max Elevation`,
 FROM `specialitycoffee.raw_files.splendourcoffee_raw`
)

SELECT * FROM CTE;

-- Creating Tionghoe Intermediate Table

CREATE OR REPLACE TABLE `specialitycoffee.intermediate_files.tionghoe_intermediate` AS
WITH cleaned_data AS (
  SELECT 

    string_field_2 AS Title,
  CASE 
    WHEN LOWER(string_field_1) LIKE '%kg%' THEN CAST(REGEXP_EXTRACT(string_field_1, r'(\d+\.?\d*)') AS INT64) * 1000
    WHEN LOWER(string_field_1) LIKE '%g%' THEN CAST(REGEXP_EXTRACT(string_field_1, r'(\d+\.?\d*)') AS INT64)
    ELSE NULL
  END AS Weight,
  "Tionghoe" as Vendor,
    -- Clean price: Remove "S$" and cast to FLOAT
    SAFE_CAST(REGEXP_REPLACE(string_field_4, r'S\$', '') AS FLOAT64) AS Price,
    
    -- Flavor, Body, Aftertaste
    string_field_5 AS  `Flavour Notes`,
    string_field_6 AS Body,
    string_field_7 AS Aftertaste,

    REGEXP_EXTRACT(string_field_8, r'^(.*?)\s+Varietal') AS Region,
    CASE 
    WHEN LOWER(string_field_8) LIKE '%antioquia%' THEN 'Colombia'
    WHEN LOWER(string_field_8) LIKE '%quindio%' THEN 'Colombia'
    WHEN LOWER(string_field_8) LIKE '%popayan%' THEN 'Colombia'
    WHEN LOWER(string_field_8) LIKE '%cauca%' THEN 'Colombia'
    WHEN LOWER(string_field_8) LIKE '%turrialba%' THEN 'Costa Rica'
    WHEN LOWER(string_field_8) LIKE '%aquiares%' THEN 'Costa Rica'
    WHEN LOWER(string_field_8) LIKE '%embu%' THEN 'Kenya'
    WHEN LOWER(string_field_8) LIKE '%sumatra%' THEN 'Indonesia'
    WHEN LOWER(string_field_8) LIKE '%aceh%' THEN 'Indonesia'
    WHEN LOWER(string_field_8) LIKE '%guji%' THEN 'Ethiopia'
    WHEN LOWER(string_field_8) LIKE '%oromia%' THEN 'Ethiopia'
    WHEN LOWER(string_field_8) LIKE '%kayanza%' THEN 'Burundi'
    WHEN LOWER(string_field_8) LIKE '%karntaka%' THEN 'India'
    WHEN LOWER(string_field_8) LIKE '%western ghats%' THEN 'India'
    WHEN LOWER(string_field_8) LIKE '%esquipulas%' THEN 'Guatemala'
    WHEN LOWER(string_field_8) LIKE '%chiquimula%' THEN 'Guatemala'
    WHEN LOWER(string_field_8) LIKE '%minas gerais%' THEN 'Brazil'
    WHEN LOWER(string_field_8) LIKE '%north sumatra%' THEN 'Indonesia'
    WHEN LOWER(string_field_8) LIKE '%armenian%' THEN 'Colombia'
    WHEN LOWER(string_field_8) LIKE '%santa monica%' THEN 'Colombia'
    ELSE 'Unknown'
  END AS Country,

    -- Extract Varietal from string_field_9 or from string_field_8 if concatenated
    COALESCE(
      REGEXP_EXTRACT(string_field_8, r'Varietal\s+(.*?)\s+Process'),
      REGEXP_EXTRACT(string_field_9, r'^(.*?)\s+Process'),
      string_field_9
    ) AS Variety,

    -- Extract Process from string_field_10 or from concatenated fields
    COALESCE(
      REGEXP_EXTRACT(string_field_8, r'Process\s+(.*)'),
      REGEXP_EXTRACT(string_field_9, r'Process\s+(.*)'),
      string_field_10
    ) AS Process,

    string_field_11 as `Image URL`

  FROM specialitycoffee.raw_files.tionghoe_raw
)
SELECT *
FROM cleaned_data;
