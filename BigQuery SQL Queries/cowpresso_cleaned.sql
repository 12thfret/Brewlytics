CREATE TABLE `specialitycoffee.cleaned_files.cowpresso_cleaned` AS
WITH cte AS (
  SELECT 
    *,
    CASE 
      WHEN REGEXP_CONTAINS(`Variant Title`, r'(?i)\b500g\b|\b500\s*Gram\b') THEN '500'
      WHEN REGEXP_CONTAINS(`Variant Title`, r'(?i)\b250g\b|\b250\s*Gram\b') THEN '250'
      WHEN REGEXP_CONTAINS(`Variant Title`, r'(?i)\b1000g\b|\b1000\s*Gram\b') THEN '1000'
      ELSE NULL  -- Set to NULL if no match found
    END AS Weight
  FROM `specialitycoffee.raw_files.cowpresso_raw`
),

cte2 AS (
SELECT
  `Title`,
  `Vendor`,
  `Variant Price`,
  `Weight`,
  `Roast Profile`,
  `Flavour notes`,
  `Region`,
  `Variety`,
  `Elevation`,
  `Processing`,
  `Acidity`,
  `Image URL`,
  `Updated At`
FROM cte
WHERE Weight IS NOT NULL
GROUP BY ALL
),



CTE3 AS (
SELECT
  *,
  CASE
    WHEN LOWER(`Roast Profile`) LIKE '%dark%' THEN 'Dark'
    WHEN LOWER(`Roast Profile`) LIKE '%light%' THEN 'Light'
    WHEN LOWER(`Roast Profile`) LIKE '%medium%' THEN 'Medium'
    ELSE 'Unknown'
  END AS `Roast Category`,
  CASE
    WHEN LOWER(`Acidity`) LIKE '%low%' THEN 'Low'
    WHEN LOWER(`Acidity`) LIKE '%mild%' OR LOWER(`Acidity`) LIKE '%pleasant%' OR LOWER(`Acidity`) LIKE '%balanced%' OR LOWER(`Acidity`) LIKE '%sweet and clear%' THEN 'Mild'
    WHEN LOWER(`Acidity`) LIKE '%medium%' OR LOWER(`Acidity`) LIKE '%medium acidity%' THEN 'Medium'
    WHEN LOWER(`Acidity`) LIKE '%bright%' OR LOWER(`Acidity`) LIKE '%crisp%' OR LOWER(`Acidity`) LIKE '%winey%' OR LOWER(`Acidity`) LIKE '%citric%' OR LOWER(`Acidity`) LIKE '%champagne%' THEN 'Bright/High'
    WHEN LOWER(`Acidity`) LIKE '%apple%' OR LOWER(`Acidity`) LIKE '%pear%' OR LOWER(`Acidity`) LIKE '%black-forest%' THEN 'Fruity'
    ELSE 'Unknown'
  END AS `Acidity Category`,
  CASE
    WHEN LOWER(`Region`) LIKE '%ethiopia%' THEN 'Ethiopia'
    WHEN LOWER(`Region`) LIKE '%colombia%' THEN 'Colombia'
    WHEN LOWER(`Region`) LIKE '%guatemala%' THEN 'Guatemala'
    WHEN LOWER(`Region`) LIKE '%java%' THEN 'Indonesia'
    WHEN LOWER(`Region`) LIKE '%sumatra%' OR LOWER(`Region`) LIKE '%indonesia%' THEN 'Indonesia'
    WHEN LOWER(`Region`) LIKE '%laos%' THEN 'Laos'
    WHEN LOWER(`Region`) LIKE '%uganda%' THEN 'Uganda'
    WHEN LOWER(`Region`) LIKE '%papua new guinea%' THEN 'Papua New Guinea'
    WHEN LOWER(`Region`) LIKE '%congo%' THEN 'Congo'
    WHEN LOWER(`Region`) LIKE '%guji%' OR LOWER(`Region`) LIKE '%yirgacheffe%' THEN 'Ethiopia'
    WHEN LOWER(`Region`) LIKE '%brazil%' OR LOWER(`Region`) LIKE '%santos%' THEN 'Brazil'
    WHEN LOWER(`Region`) LIKE '%kintamani%' OR LOWER(`Region`) LIKE '%bali%' THEN 'Indonesia'
    WHEN LOWER(`Region`) LIKE '%myanmar%' THEN 'Myanmar'
    WHEN LOWER(`Region`) LIKE '%village%' OR LOWER(`Region`) LIKE '%mixed%' THEN 'Mixed Blend'
    ELSE 'Other'
  END AS `Country`,
  CASE
    WHEN LOWER(`Processing`) LIKE '%fully washed%' OR LOWER(`Processing`) LIKE '%washed%' THEN 'Washed'
    WHEN LOWER(`Processing`) LIKE '%natural%' OR LOWER(`Processing`) LIKE '%sun dried%' THEN 'Natural (Dry Processed)'
    WHEN LOWER(`Processing`) LIKE '%honey%' OR LOWER(`Processing`) LIKE '%pulped%' THEN 'Honey Processed'
    WHEN LOWER(`Processing`) LIKE '%anaerobic%' THEN 'Anaerobic'
    WHEN LOWER(`Processing`) LIKE '%giling basah%' THEN 'Wet Hulled (Giling Basah)'
    WHEN LOWER(`Processing`) LIKE '%mixed%' OR LOWER(`Processing`) LIKE '%&%' THEN 'Mixed or Multiple Methods'
    WHEN LOWER(`Processing`) LIKE '%s.water%' OR LOWER(`Processing`) LIKE '%swiss water%' THEN 'Decaf'
    ELSE 'Other or Infused'
  END AS `Processing Category`,
  CASE
    WHEN REGEXP_CONTAINS(`Elevation`, r'^\d{1,4},?\d{0,3}\s*-\s*\d{1,4},?\d{0,3}') THEN 
      CAST(REPLACE(SPLIT(`Elevation`, '-')[OFFSET(0)], ',', '') AS INT64)
    WHEN REGEXP_CONTAINS(`Elevation`, r'^\d{1,4},?\d{0,3}$') THEN 
      CAST(REPLACE(`Elevation`, ',', '') AS INT64)
    ELSE NULL
  END AS `Min Elevation`,
  CASE
    WHEN REGEXP_CONTAINS(`Elevation`, r'^\d{1,4},?\d{0,3}\s*-\s*\d{1,4},?\d{0,3}') THEN 
      CAST(REPLACE(SPLIT(`Elevation`, '-')[OFFSET(1)], ',', '') AS INT64)
    WHEN REGEXP_CONTAINS(`Elevation`, r'^\d{1,4},?\d{0,3}$') THEN 
      CAST(REPLACE(`Elevation`, ',', '') AS INT64)
    ELSE NULL
  END AS `Max Elevation`,
  CASE
    WHEN LOWER(`Variety`) LIKE '%heirloom%' THEN 'Heirloom'
    WHEN LOWER(`Variety`) LIKE '%typica%' THEN 'Typica-based'
    WHEN LOWER(`Variety`) LIKE '%bourbon%' THEN 'Bourbon-based'
    WHEN LOWER(`Variety`) LIKE '%geisha%' THEN 'Geisha'
    WHEN LOWER(`Variety`) LIKE '%catimor%' OR LOWER(`Variety`) LIKE '%marsellesa%' OR LOWER(`Variety`) LIKE '%starmaya%' OR LOWER(`Variety`) LIKE '%catuai%' OR LOWER(`Variety`) LIKE '%hybrid%' THEN 'Hybrid or Modern Varieties'
    ELSE 'Other'
  END AS `Variety Category`,
  -- CASE
  --   WHEN LOWER(`Flavour notes`) LIKE '%berries%' OR LOWER(`Flavour notes`) LIKE '%citrus%' 
  --        OR LOWER(`Flavour notes`) LIKE '%mango%' OR LOWER(`Flavour notes`) LIKE '%grapes%' 
  --        OR LOWER(`Flavour notes`) LIKE '%oranges%' OR LOWER(`Flavour notes`) LIKE '%plums%' 
  --        OR LOWER(`Flavour notes`) LIKE '%lychee%' OR LOWER(`Flavour notes`) LIKE '%tropical%' THEN 'Fruity'
  --   WHEN LOWER(`Flavour notes`) LIKE '%hazelnuts%' OR LOWER(`Flavour notes`) LIKE '%chestnuts%' THEN 'Nutty'
  --   WHEN LOWER(`Flavour notes`) LIKE '%chocolate%' OR LOWER(`Flavour notes`) LIKE '%caramel%' 
  --        OR LOWER(`Flavour notes`) LIKE '%brownies%' OR LOWER(`Flavour notes`) LIKE '%candy%' THEN 'Sweet'
  --   WHEN LOWER(`Flavour notes`) LIKE '%spice%' OR LOWER(`Flavour notes`) LIKE '%cedar%' 
  --        OR LOWER(`Flavour notes`) LIKE '%tobacco%' THEN 'Spicy'
  --   WHEN LOWER(`Flavour notes`) LIKE '%jasmine%' OR LOWER(`Flavour notes`) LIKE '%blossom%' 
  --        OR LOWER(`Flavour notes`) LIKE '%floral%' THEN 'Floral'
  --   WHEN LOWER(`Flavour notes`) LIKE '%tea%' THEN 'Tea-like'
  --   ELSE 'Other'
  -- END AS `Flavour Category`
  -- FROM cte2
  FROM cte2
)

SELECT 
  `Title`,
  "Cowpresso Coffee Roasters Singapore" AS `Vendor`,
  `Variant Price` as `Price`,
  `Weight`,
  `Roast Category` as `Roast Profile`,
  `Acidity Category` as `Acidity`,
  `Country`,
  `Processing Category` as `Process`,
  `Flavour notes`,
  `Variety Category` as `Variety`,
  `Min Elevation`,
  `Max Elevation`
FROM CTE3;

