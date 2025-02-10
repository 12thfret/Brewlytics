-- Title, Vendor, Price, Weight, Roast Profile, Acidity, Country, Process, Flavour Notes, Variety, Min Elevation, Max Elevation
CREATE TABLE `specialitycoffee.intermediate_files.tionghoe_variant_intermediate` AS

SELECT 
    REGEXP_EXTRACT(string_field_0, r'Tiong Hoe Specialty Coffee - ([^-]+) -') AS Title,
    string_field_3 AS Price,
    -- Extract Brewing based on the presence of "Espresso" in the title
    CASE 
        WHEN string_field_0 LIKE '%Espresso%' THEN 'Espresso'
        ELSE 'Filter'
    END AS Brewing,
    -- Extract Weight by finding the numeric value before 'g' in the title
    CAST(REGEXP_EXTRACT(string_field_0, r'(\d+)g') AS INT64) AS Weight
FROM 
    `specialitycoffee.raw_files.tionghoe_variant_raw`
