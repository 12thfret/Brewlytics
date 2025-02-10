CREATE TABLE `specialitycoffee.intermediate_files.alchemist_variant_intermediate` AS

SELECT 
  TRIM(SPLIT(SPLIT(string_field_0, ' - ')[OFFSET(1)], ' / ')[OFFSET(0)]) as Title,
  TRIM(SPLIT(SPLIT(string_field_0, ' / ')[OFFSET(0)], ' - ')[OFFSET(2)]) as Brewing,
  TRIM(REGEXP_EXTRACT(string_field_0, r'(\d+)g$')) as Weight
FROM specialitycoffee.raw_files.alchemist_variant_raw