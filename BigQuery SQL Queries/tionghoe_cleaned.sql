CREATE OR REPLACE TABLE `specialitycoffee.cleaned_files.tionghoe_cleaned` AS

SELECT 
p.Title,
"Tiong Hoe Speciality Coffee" as Vendor,
ROUND(CAST(REGEXP_REPLACE(v.price, r'^S\$', '') AS FLOAT64),1) AS Price,
v.Weight,
p.`Roast Profile`,
p.Acidity,
p.Region,
    CASE 
        WHEN p.Region LIKE '%Kayanza%' THEN 'Burundi'
        WHEN p.Region LIKE '%Oromia, Guji%' THEN 'Ethiopia'
        WHEN p.Region LIKE '%Minas Gerais%' THEN 'Brazil'
        WHEN p.Region LIKE '%Karnataka, Western Ghats%' THEN 'India'
        WHEN p.Region LIKE '%North Sumatra Province, Aceh%' THEN 'Indonesia'
        WHEN p.Region LIKE '%Embu County%' THEN 'Kenya'
        WHEN p.Region LIKE '%Antioquia, Urrao%' THEN 'Colombia'
        WHEN p.Region LIKE '%Esquipulas, Chiquimula%' THEN 'Guatemala'
        WHEN p.Region LIKE '%Turrialba, Aquiares%' THEN 'Costa Rica'
        WHEN p.Region LIKE '%Bensa, Sidama%' THEN 'Ethiopia'
        WHEN p.Region LIKE '%Popayan Cauca%' THEN 'Colombia'
        ELSE 'Unknown' -- Handle cases where the region is not mapped
    END AS Country,
p.Process,
p.`Flavour Notes`,
p.`Blend Origin`,
p.Variety,
    CASE 
        WHEN p.Variety LIKE '%Bourbon%' THEN 'Bourbon'
        WHEN p.Variety LIKE '%Typica%' THEN 'Typica'
        WHEN p.Variety LIKE '%Gesha%' THEN 'Gesha'
        WHEN p.Variety LIKE '%Caturra%' THEN 'Caturra'
        WHEN p.Variety LIKE '%SL28%' OR p.Variety LIKE '%SL34%' THEN 'SL28/SL34'
        WHEN p.Variety LIKE '%Catimor%' THEN 'Catimor'
        WHEN p.Variety LIKE '%Mundo Novo%' THEN 'Mundo Novo'
        WHEN p.Variety LIKE '%Ruiru%' THEN 'Ruiru 11'
        WHEN p.Variety LIKE '%Chiroso%' THEN 'Chiroso'
        WHEN p.Variety LIKE '%Esperanza%' THEN 'Esperanza'
        WHEN p.Variety LIKE '%74158%' THEN '74158'
        WHEN p.Variety LIKE '%74110%' OR p.Variety LIKE '%74112%' THEN 'Gibirinna/Serto'
        WHEN p.Variety LIKE '%Castillo%' THEN 'Castillo'
        ELSE 'Unknown' -- Handle unmatched varieties
    END AS `Variety Category`,
p.Body,
p.Aftertaste,
v.Brewing,
FROM
specialitycoffee.intermediate_files.tionghoe_product_intermediate p
LEFT JOIN   
specialitycoffee.intermediate_files.tionghoe_variant_intermediate v
ON p.title = v.title


