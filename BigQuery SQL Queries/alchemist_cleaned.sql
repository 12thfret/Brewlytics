CREATE OR REPLACE TABLE `specialitycoffee.cleaned_files.alchemist_cleaned` AS

WITH CTE AS (
SELECT 
  c.title as Title,
  "Alchemist" as Vendor,
  v.price as Price,
  v.weight as Weight,
  c.region as Country,
  c.processing as Process,
  c.`Flavour Notes` as `Flavour Notes`,
  v.brewing as Brewing
FROM specialitycoffee.intermediate_files.alchemist_card_intermediate c
LEFT JOIN specialitycoffee.intermediate_files.alchemist_variant_intermediate v
  ON v.title = c.title
)

SELECT * FROM CTE;