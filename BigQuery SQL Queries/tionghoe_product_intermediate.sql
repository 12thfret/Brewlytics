-- Title, Vendor, Price, Weight, Roast Profile, Acidity, Country, Process, Flavour Notes, Variety, Min Elevation, Max Elevation
CREATE TABLE `specialitycoffee.intermediate_files.tionghoe_product_intermediate` AS



SELECT 
    NULLIF(string_field_0, 'N/A') AS Title,
    NULLIF(string_field_1, 'N/A') AS `Product URL`,
    NULLIF(string_field_3, 'N/A') AS `Blend Origin`,
    NULLIF(string_field_4, 'N/A') AS Acidity,
    NULLIF(REGEXP_EXTRACT(string_field_5, r'^\s*(Medium|Dark|Light)\b'), 'N/A') AS `Roast Profile`,
    NULLIF(string_field_6, 'N/A') AS `Flavour Notes`,
    NULLIF(string_field_7, 'N/A') AS Body,
    NULLIF(string_field_8, 'N/A') AS Aftertaste,
    NULLIF(string_field_9, 'N/A') AS Region,
    NULLIF(string_field_10, 'N/A') AS Variety,
    NULLIF(REGEXP_EXTRACT(string_field_11, r'^\s*([\w\s-]+)(?:\s{2}|$)'), 'N/A') AS Process
FROM 
    `specialitycoffee.raw_files.tionghoe_product_raw`
