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

SELECT * FROM CTE


