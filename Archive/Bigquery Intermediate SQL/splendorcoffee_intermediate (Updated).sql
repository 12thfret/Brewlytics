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

SELECT * FROM CTE