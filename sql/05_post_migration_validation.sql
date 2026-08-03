-- =========================================================
-- POST-MIGRATION VALIDATION
-- =========================================================

-- =========================================================
-- 1. TABLE STRUCTURE
-- =========================================================

-- Confirm that all expected final tables exist and that
-- out-of-scope tables are no longer present.

SELECT
    table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;


-- =========================================================
-- 2. COLUMN NAMES AND DATA TYPES
-- =========================================================

-- Confirm final column names, data types, sizes, precision,
-- scale, and nullability across the complete public schema.

SELECT
    table_name,
    ordinal_position,
    column_name,
    data_type,
    character_maximum_length,
    numeric_precision,
    numeric_scale,
    datetime_precision,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY
    table_name,
    ordinal_position;

-- Confirm that the corrected product column names exist
-- and that the misspelled source names are no longer present.

SELECT
    column_name
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'products'
  AND column_name IN (
      'product_name_length',
      'product_description_length',
      'product_name_lenght',
      'product_description_lenght'
  )
ORDER BY column_name;


-- =========================================================
-- 3. ROW COUNT VALIDATION
-- =========================================================

-- Expected source row count: 99441
-- Current row count: 99441
SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM public.customers

UNION ALL

-- Expected source row count: 99441
-- Current row count: 99441
SELECT 'orders', COUNT(*)
FROM public.orders

UNION ALL

-- Expected source row count: 103886
-- Current row count: 103886
SELECT 'order_payments', COUNT(*)
FROM public.order_payments

UNION ALL

-- Expected source row count: 112650
-- Current row count: 112650
SELECT 'order_items', COUNT(*)
FROM public.order_items

UNION ALL

-- Expected source row count: 99224
-- Current row count: 99224
SELECT 'order_reviews', COUNT(*)
FROM public.order_reviews

UNION ALL

-- Expected source row count: 32951
-- Current row count: 32951
SELECT 'products', COUNT(*)
FROM public.products

UNION ALL

-- Original source row count: 71
-- Two missing translations were added during schema setup.
-- Expected final row count: 73
SELECT 'product_category_name_translation', COUNT(*)
FROM public.product_category_name_translation

UNION ALL

-- Expected source row count: 3095
-- Current row count: 3095
SELECT 'sellers', COUNT(*)
FROM public.sellers

ORDER BY table_name;


-- =========================================================
-- 4. ZIP-CODE LOOKUP VALIDATION
-- =========================================================

-- Validate the cleaned ZIP-code lookup by checking for duplicate ZIP-code prefixes,
-- confirming full coverage of customer and seller ZIP codes,
-- and reviewing the completeness and consistency of latitude and longitude values.

SELECT COUNT(*) AS duplicate_zip_codes
FROM (
    SELECT zip_code_prefix
    FROM public.zip_code_geolocation
    GROUP BY zip_code_prefix
    HAVING COUNT(*) > 1
) AS duplicates;

SELECT COUNT(*) AS missing_customer_zip_codes
FROM public.customers AS c
LEFT JOIN public.zip_code_geolocation AS z
    ON c.customer_zip_code_prefix = z.zip_code_prefix
WHERE z.zip_code_prefix IS NULL;

SELECT COUNT(*) AS missing_seller_zip_codes
FROM public.sellers AS s
LEFT JOIN public.zip_code_geolocation AS z
    ON s.seller_zip_code_prefix = z.zip_code_prefix
WHERE z.zip_code_prefix IS NULL;

SELECT COUNT(*) AS zip_codes_without_coordinates
FROM public.zip_code_geolocation
WHERE latitude IS NULL
   OR longitude IS NULL;

SELECT COUNT(*) AS incomplete_coordinate_pairs
FROM public.zip_code_geolocation
WHERE (latitude IS NULL AND longitude IS NOT NULL)
   OR (latitude IS NOT NULL AND longitude IS NULL);


-- =========================================================
-- 5. PRIMARY AND UNIQUE KEY VALIDATION
-- =========================================================

-- Confirm that primary keys exist for all final relational tables.
-- The raw geolocation table intentionally has no
-- primary key because ZIP-code prefixes are duplicated there.

SELECT
    table_name,
    constraint_name,
    constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'public'
  AND constraint_type = 'PRIMARY KEY'
ORDER BY table_name;

-- Confirm additional UNIQUE constraints that are not already
-- provided by primary keys.

SELECT
    table_name,
    constraint_name
FROM information_schema.table_constraints
WHERE table_schema = 'public'
  AND constraint_type = 'UNIQUE'
ORDER BY table_name, constraint_name;


-- =========================================================
-- 6. FOREIGN KEY VALIDATION
-- =========================================================

-- Confirm that all foreign key constraints defined for the final
-- relational schema were created successfully.

SELECT
    table_name,
    constraint_name,
    constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'public'
  AND constraint_type = 'FOREIGN KEY'
ORDER BY table_name, constraint_name;


-- =========================================================
-- 7. NOT NULL VALIDATION
-- =========================================================

-- Confirm nullability rules across all final relational tables.
-- The raw geolocation table is excluded because it
-- remains an unmodified source-level table.

SELECT
    table_name,
    column_name,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN (
      'customers',
      'orders',
      'order_payments',
      'order_items',
      'order_reviews',
	  'products',
	  'product_category_name_translation',
	  'sellers',
	  'zip_code_geolocation'
  )
ORDER BY table_name, ordinal_position;


-- =========================================================
-- 8. CHECK CONSTRAINT VALIDATION
-- =========================================================

-- Confirm that all domain and row-level integrity rules
-- defined in 04_constraints_and_indexes.sql exist.

SELECT
    conrelid::regclass AS table_name,
    conname AS constraint_name,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE contype = 'c'
  AND connamespace = 'public'::regnamespace
ORDER BY table_name, constraint_name;


-- =========================================================
-- 9. INDEX VALIDATION
-- =========================================================

-- Display both automatically created indexes for PRIMARY KEY
-- and UNIQUE constraints and manually created analytical indexes.

SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;


-- =========================================================
-- 10. FINAL DATA INTEGRITY CHECKS
-- =========================================================

-- Confirm that no orphan records remain across any final
-- foreign-key relationship.

SELECT
    'orders_without_customer' AS integrity_check,
    COUNT(*) AS invalid_rows
FROM public.orders AS o
LEFT JOIN public.customers AS c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT
    'payments_without_order',
    COUNT(*)
FROM public.order_payments AS p
LEFT JOIN public.orders AS o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT
    'items_without_order',
    COUNT(*)
FROM public.order_items AS i
LEFT JOIN public.orders AS o
    ON i.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT
    'items_without_product',
    COUNT(*)
FROM public.order_items AS i
LEFT JOIN public.products AS p
    ON i.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

SELECT
    'items_without_seller',
    COUNT(*)
FROM public.order_items AS i
LEFT JOIN public.sellers AS s
    ON i.seller_id = s.seller_id
WHERE s.seller_id IS NULL

UNION ALL

SELECT
    'reviews_without_order',
    COUNT(*)
FROM public.order_reviews AS r
LEFT JOIN public.orders AS o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT
    'products_without_translation',
    COUNT(*)
FROM public.products AS p
LEFT JOIN public.product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL

UNION ALL

SELECT
    'customers_without_zip_lookup',
    COUNT(*)
FROM public.customers AS c
LEFT JOIN public.zip_code_geolocation AS z
    ON c.customer_zip_code_prefix = z.zip_code_prefix
WHERE z.zip_code_prefix IS NULL

UNION ALL

SELECT
    'sellers_without_zip_lookup',
    COUNT(*)
FROM public.sellers AS s
LEFT JOIN public.zip_code_geolocation AS z
    ON s.seller_zip_code_prefix = z.zip_code_prefix
WHERE z.zip_code_prefix IS NULL

ORDER BY integrity_check;