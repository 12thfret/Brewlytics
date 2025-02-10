CREATE TABLE `specialitycoffee.intermediate_files.alchemist_card_intermediate` AS


SELECT 
string_field_0 as Title,
string_field_1 as `Product URL`,
TRIM(SPLIT(string_field_2, ' - ')[OFFSET(0)]) as Region,
TRIM(SPLIT(string_field_2, ' - ')[OFFSET(1)]) as Processing,
string_field_3 as Description,
string_field_4 as `Flavour Notes`,
TRIM(REGEXP_REPLACE(REGEXP_REPLACE(string_field_5, r'From ', ''), r'S\$', '')) as Price,
string_field_6 as `Image URL`

FROM specialitycoffee.raw_files.alchemist_card_raw