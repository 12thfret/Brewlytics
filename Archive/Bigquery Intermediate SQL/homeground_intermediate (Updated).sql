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
