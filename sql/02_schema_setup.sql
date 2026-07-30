-- Run once after migrating the original SQLite tables
-- to PostgreSQL and completing the data quality checks.

BEGIN;

-- =========================================================
-- REMOVE TABLES OUTSIDE PROJECT SCOPE
-- =========================================================

-- The marketing funnel tables are not required for the
-- Delivery Performance and Customer Satisfaction analysis.

DROP TABLE IF EXISTS public.leads_closed;
DROP TABLE IF EXISTS public.leads_qualified;


-- =========================================================
-- CORRECT COLUMN NAMES
-- =========================================================

-- Correct spelling errors inherited from the source database.
ALTER TABLE public.products
    RENAME COLUMN product_name_lenght TO product_name_length;

ALTER TABLE public.products
    RENAME COLUMN product_description_lenght
    TO product_description_length;


-- =========================================================
-- DATA CLEANING: CATEGORY TRANSLATION LOOKUP
-- =========================================================

-- Add missing English translations required for
-- category lookup completeness and future referential integrity.

INSERT INTO public.product_category_name_translation (
    product_category_name,
    product_category_name_english
)
SELECT
    source.product_category_name,
    source.product_category_name_english
FROM (
    VALUES
        (
            'pc_gamer',
            'pc_gamer'
        ),
        (
            'portateis_cozinha_e_preparadores_de_alimentos',
            'kitchen_portables_and_food_preparers'
        )
) AS source (
    product_category_name,
    product_category_name_english
)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.product_category_name_translation AS existing
    WHERE existing.product_category_name =
          source.product_category_name
);


-- =========================================================
-- CHANGE DATA TYPES
-- =========================================================

-- Convert source-imported columns to data types appropriate
-- for the PostgreSQL analytical schema.


-- ---------------------------------------------------------
-- 1. TABLE CUSTOMERS
-- ---------------------------------------------------------

ALTER TABLE public.customers
    ALTER COLUMN customer_zip_code_prefix
        TYPE INTEGER
        USING customer_zip_code_prefix::INTEGER,

    ALTER COLUMN customer_state
        TYPE VARCHAR(2);


-- ---------------------------------------------------------
-- 2. TABLE ORDERS
-- ---------------------------------------------------------

ALTER TABLE public.orders
    ALTER COLUMN order_purchase_timestamp
        TYPE TIMESTAMP
        USING order_purchase_timestamp::TIMESTAMP,

    ALTER COLUMN order_approved_at
        TYPE TIMESTAMP
        USING order_approved_at::TIMESTAMP,

    ALTER COLUMN order_delivered_carrier_date
        TYPE TIMESTAMP
        USING order_delivered_carrier_date::TIMESTAMP,

    ALTER COLUMN order_delivered_customer_date
        TYPE TIMESTAMP
        USING order_delivered_customer_date::TIMESTAMP,

    ALTER COLUMN order_estimated_delivery_date
        TYPE DATE
        USING order_estimated_delivery_date::DATE;


-- ---------------------------------------------------------
-- 3. TABLE ORDER PAYMENTS
-- ---------------------------------------------------------

ALTER TABLE public.order_payments
    ALTER COLUMN payment_sequential
        TYPE INTEGER,

    ALTER COLUMN payment_installments
        TYPE INTEGER,

    ALTER COLUMN payment_value
        TYPE NUMERIC(12,2)
        USING ROUND(payment_value::NUMERIC, 2);


-- ---------------------------------------------------------
-- 4. TABLE ORDER ITEMS
-- ---------------------------------------------------------

ALTER TABLE public.order_items
    ALTER COLUMN order_item_id
        TYPE INTEGER,

    ALTER COLUMN shipping_limit_date
        TYPE TIMESTAMP
        USING shipping_limit_date::TIMESTAMP,

    ALTER COLUMN price
        TYPE NUMERIC(12,2)
        USING ROUND(price::NUMERIC, 2),

    ALTER COLUMN freight_value
        TYPE NUMERIC(12,2)
        USING ROUND(freight_value::NUMERIC, 2);


-- ---------------------------------------------------------
-- 5. TABLE ORDER REVIEWS
-- ---------------------------------------------------------

ALTER TABLE public.order_reviews
    ALTER COLUMN review_score
        TYPE INTEGER,

    ALTER COLUMN review_creation_date
        TYPE DATE
        USING review_creation_date::DATE,

    ALTER COLUMN review_answer_timestamp
        TYPE TIMESTAMP
        USING review_answer_timestamp::TIMESTAMP;


-- ---------------------------------------------------------
-- 6. TABLE PRODUCTS
-- ---------------------------------------------------------

ALTER TABLE public.products
    ALTER COLUMN product_name_length
        TYPE INTEGER
        USING product_name_length::INTEGER,

    ALTER COLUMN product_description_length
        TYPE INTEGER
        USING product_description_length::INTEGER,

    ALTER COLUMN product_photos_qty
        TYPE INTEGER
        USING product_photos_qty::INTEGER,

    ALTER COLUMN product_weight_g
        TYPE INTEGER
        USING product_weight_g::INTEGER,

    ALTER COLUMN product_length_cm
        TYPE INTEGER
        USING product_length_cm::INTEGER,

    ALTER COLUMN product_height_cm
        TYPE INTEGER
        USING product_height_cm::INTEGER,

    ALTER COLUMN product_width_cm
        TYPE INTEGER
        USING product_width_cm::INTEGER;


-- ---------------------------------------------------------
-- 7. TABLE PRODUCT CATEGORY NAME TRANSLATION
-- ---------------------------------------------------------

-- Both category columns already use an appropriate text type.
-- No data type conversion is required.


-- ---------------------------------------------------------
-- 8. TABLE SELLERS
-- ---------------------------------------------------------

ALTER TABLE public.sellers
    ALTER COLUMN seller_zip_code_prefix
        TYPE INTEGER
        USING seller_zip_code_prefix::INTEGER,

    ALTER COLUMN seller_state
        TYPE VARCHAR(2);


-- ---------------------------------------------------------
-- 9. TABLE GEOLOCATION
-- ---------------------------------------------------------

ALTER TABLE public.geolocation
    ALTER COLUMN geolocation_zip_code_prefix
        TYPE INTEGER
        USING geolocation_zip_code_prefix::INTEGER,

    ALTER COLUMN geolocation_state
        TYPE VARCHAR(2);

-- Latitude and longitude remain DOUBLE PRECISION because
-- geographic coordinates require decimal precision.


COMMIT;