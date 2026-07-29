-- =========================================================
-- 1. KEY VALIDATION
-- =========================================================

-- Customers: customer_id must be unique and non-null.
SELECT
    COUNT(*) AS total_rows_customers,
	COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS null_customer_id,
    COUNT(DISTINCT customer_id) AS unique_ids
FROM public.customers;

-- Orders: order_id must be unique and non-null.
SELECT
    COUNT(*) AS total_rows_orders,
    COUNT(*) FILTER (
        WHERE order_id IS NULL
    ) AS null_order_id,
    COUNT(DISTINCT order_id) AS unique_ids
FROM public.orders;

-- Order payments: (order_id, payment_sequential) must be unique and non-null.
SELECT
    COUNT(*) AS total_rows,
	COUNT(*) FILTER (
        WHERE order_id IS NULL
           OR payment_sequential IS NULL
    ) AS number_of_null_values,
    COUNT(DISTINCT (order_id, payment_sequential)) AS unique_pairs
FROM public.order_payments;

-- Order items: (order_id, order_item_id) must be unique and non-null.
SELECT
    COUNT(*) AS total_rows,
	COUNT(*) FILTER (
        WHERE order_id IS NULL
           OR order_item_id IS NULL
    ) AS number_of_null_values,
    COUNT(DISTINCT (order_id, order_item_id)) AS unique_pairs
FROM public.order_items;

-- Order reviews: (review_id, order_id) must be unique and non-null.
SELECT
    COUNT(*) AS total_rows,
	COUNT(*) FILTER (
        WHERE review_id IS NULL
           OR order_id IS NULL
    ) AS number_of_null_values,
    COUNT(DISTINCT (review_id, order_id)) AS unique_pairs
FROM public.order_reviews;

-- Products: product_id must be unique and non-null.
SELECT
    COUNT(*) AS total_rows_products,
    COUNT(*) FILTER (
        WHERE product_id IS NULL
    ) AS null_product_id,
    COUNT(DISTINCT product_id) AS unique_ids
FROM public.products;

-- Product category translation: product_category_name must be unique and non-null.
SELECT
    COUNT(*) AS total_rows_product_category,
    COUNT(*) FILTER (
        WHERE product_category_name IS NULL
    ) AS null_product_category_name,
    COUNT(DISTINCT product_category_name) AS unique_ids
FROM public.product_category_name_translation;

-- Sellers: seller_id must be unique and non-null.
SELECT
    COUNT(*) AS total_rows_sellers,
    COUNT(*) FILTER (
        WHERE seller_id IS NULL
    ) AS null_seller_id,
    COUNT(DISTINCT seller_id) AS unique_ids
FROM public.sellers;


-- =========================================================
-- 2. NULL PROFILE
-- =========================================================

-- Customers NULL profile.
SELECT
    -- All customer attributes are required for customer identification
    -- and geographic analysis.
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE customer_unique_id IS NULL) AS null_customer_unique_id,
    COUNT(*) FILTER (WHERE customer_zip_code_prefix IS NULL) AS null_customer_zip_code_prefix,
    COUNT(*) FILTER (WHERE customer_city IS NULL) AS null_customer_city,
    COUNT(*) FILTER (WHERE customer_state IS NULL) AS null_customer_state
FROM public.customers;

-- Orders NULL profile.
SELECT
    -- Required order attributes.
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
    COUNT(*) FILTER (WHERE order_status IS NULL) AS null_order_status,
    COUNT(*) FILTER (WHERE order_purchase_timestamp IS NULL) AS null_purchase_timestamp,
    COUNT(*) FILTER (WHERE order_estimated_delivery_date IS NULL) AS null_estimated_delivery_date,
    -- Nullable lifecycle timestamps.
   -- Missing values may be valid for cancelled or unfinished orders.
    COUNT(*) FILTER (WHERE order_approved_at IS NULL) AS null_approved_at,
    COUNT(*) FILTER (WHERE order_delivered_carrier_date IS NULL) AS null_carrier_date,
    COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL) AS null_customer_delivery_date
FROM public.orders;

-- Order payments NULL profile.
SELECT
    -- Payment attributes are required for every payment record.
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE payment_type IS NULL) AS null_payment_type,
    COUNT(*) FILTER (WHERE payment_installments IS NULL) AS null_payment_installments,
    COUNT(*) FILTER (WHERE payment_value IS NULL) AS null_payment_value
FROM public.order_payments;

-- Order items NULL profile.
SELECT
    -- All order item attributes are required to identify the product,
    -- seller, shipping deadline, and monetary values.
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE product_id IS NULL) AS null_product_id,
    COUNT(*) FILTER (WHERE seller_id IS NULL) AS null_seller_id,
    COUNT(*) FILTER (WHERE shipping_limit_date IS NULL) AS null_shipping_limit_date,
    COUNT(*) FILTER (WHERE price IS NULL) AS null_price,
    COUNT(*) FILTER (WHERE freight_value IS NULL) AS null_freight_value
FROM public.order_items;

-- Order reviews NULL profile.
SELECT
-- Required review attributes.
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE review_score IS NULL) AS null_review_score,
    COUNT(*) FILTER (WHERE review_creation_date IS NULL) AS null_review_creation_date,
    COUNT(*) FILTER (WHERE review_answer_timestamp IS NULL) AS null_review_answer_timestamp,
    -- Optional review text.
    -- Customers may submit a score without a title or written comment.
    COUNT(*) FILTER (WHERE review_comment_title IS NULL) AS null_review_comment_title,
    COUNT(*) FILTER (WHERE review_comment_message IS NULL) AS null_review_comment_message
FROM public.order_reviews;

-- Products NULL profile.
SELECT
    -- Product catalog attributes may be missing because some product
    -- records were not fully completed in the source system.
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE product_category_name IS NULL) AS null_product_category_name,
    COUNT(*) FILTER (WHERE product_name_length IS NULL) AS null_product_name_length,
    COUNT(*) FILTER (WHERE product_description_length IS NULL) AS null_product_description_length,
    COUNT(*) FILTER (WHERE product_photos_qty IS NULL) AS null_product_photos_qty,
    COUNT(*) FILTER (WHERE product_weight_g IS NULL) AS null_product_weight_g,
    COUNT(*) FILTER (WHERE product_length_cm IS NULL) AS null_product_length_cm,
    COUNT(*) FILTER (WHERE product_height_cm IS NULL) AS null_product_height_cm,
    COUNT(*) FILTER (WHERE product_width_cm IS NULL) AS null_product_width_cm
FROM public.products;

-- Product category translation NULL profile.
SELECT
    -- Every category in the translation lookup should have
    -- a corresponding English category name.
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE product_category_name_english IS NULL) AS null_product_category_name_english
FROM public.product_category_name_translation;

-- Sellers NULL profile.
SELECT
    -- Seller geographic attributes are required for location-based analysis.
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE seller_zip_code_prefix IS NULL) AS null_seller_zip_code_prefix,
    COUNT(*) FILTER (WHERE seller_city IS NULL) AS null_seller_city,
    COUNT(*) FILTER (WHERE seller_state IS NULL) AS null_seller_state
FROM public.sellers;

-- Geolocation NULL profile.
SELECT
    -- All geolocation attributes are required to identify
    -- the postal area and its coordinates.
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE geolocation_zip_code_prefix IS NULL) AS null_geolocation_zip_code_prefix,
    COUNT(*) FILTER (WHERE geolocation_lat IS NULL) AS null_geolocation_lat,
    COUNT(*) FILTER (WHERE geolocation_lng IS NULL) AS null_geolocation_lng,
    COUNT(*) FILTER (WHERE geolocation_city IS NULL) AS null_geolocation_city,
    COUNT(*) FILTER (WHERE geolocation_state IS NULL) AS null_geolocation_state
FROM public.geolocation;


-- =========================================================
-- 3. FOREIGN KEY INTEGRITY
-- =========================================================

-- Every order must reference an existing customer.
SELECT COUNT(*) AS missing_customers
FROM public.orders AS o
LEFT JOIN public.customers AS c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Every order item must reference an existing product.
SELECT COUNT(*) AS missing_products
FROM public.order_items AS oi
LEFT JOIN public.products AS p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Every payment must reference an existing order.
SELECT COUNT(*) AS missing_orders_for_payments
FROM public.order_payments AS op
LEFT JOIN public.orders AS o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Every order item must reference an existing seller.
SELECT COUNT(*) AS missing_sellers
FROM public.order_items AS oi
LEFT JOIN public.sellers AS s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- Every order item must reference an existing order.
SELECT COUNT(*) AS missing_orders_for_items
FROM public.order_items AS oi
LEFT JOIN public.orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Every review must reference an existing order.
SELECT COUNT(*) AS missing_orders_for_reviews
FROM public.order_reviews AS r
LEFT JOIN public.orders AS o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Every non-null product category must have a corresponding English translation.
SELECT COUNT(*) AS missing_product_categories
FROM public.products AS p
LEFT JOIN public.product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL;

-- Observation:
-- Two product categories are missing from the English translation lookup:
-- pc_gamer (3 products)
-- portateis_cozinha_e_preparadores_de_alimentos (10 products)
-- These values should be added to the translation table before
-- enforcing the foreign key from products.product_category_name.

-- Additional completeness check: every customer record should be associated with an order.
SELECT COUNT(*) AS customers_without_orders
FROM public.customers AS c
LEFT JOIN public.orders AS o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- =========================================================
-- 4. TYPE CONVERSION SAFETY
-- =========================================================

-- ---------------------------------------------------------
-- 4.1 Date and timestamp conversions
-- ---------------------------------------------------------

-- Check that order date columns follow the expected
-- YYYY-MM-DD HH:MM:SS format before conversion.
SELECT
    COUNT(*) FILTER (
        WHERE order_purchase_timestamp IS NOT NULL
          AND order_purchase_timestamp !~
              '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'
    ) AS invalid_purchase_timestamp_format,

    COUNT(*) FILTER (
        WHERE order_approved_at IS NOT NULL
          AND order_approved_at !~
              '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'
    ) AS invalid_approved_timestamp_format,

    COUNT(*) FILTER (
        WHERE order_delivered_carrier_date IS NOT NULL
          AND order_delivered_carrier_date !~
              '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'
    ) AS invalid_carrier_timestamp_format,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date IS NOT NULL
          AND order_delivered_customer_date !~
              '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'
    ) AS invalid_customer_delivery_timestamp_format,

    COUNT(*) FILTER (
        WHERE order_estimated_delivery_date IS NOT NULL
          AND order_estimated_delivery_date !~
              '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'
    ) AS invalid_estimated_delivery_format
FROM public.orders;

-- Check that shipping_limit_date follows the expected format.
SELECT
    COUNT(*) AS invalid_shipping_limit_date_format
FROM public.order_items
WHERE shipping_limit_date IS NOT NULL
  AND shipping_limit_date !~
      '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$';

-- Check that review date columns follow the expected format.
SELECT
    COUNT(*) FILTER (
        WHERE review_creation_date IS NOT NULL
          AND review_creation_date !~
              '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'
    ) AS invalid_review_creation_format,

    COUNT(*) FILTER (
        WHERE review_answer_timestamp IS NOT NULL
          AND review_answer_timestamp !~
              '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'
    ) AS invalid_review_answer_format
FROM public.order_reviews;

-- Check whether review_creation_date contains meaningful time information.
SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE review_creation_date::timestamp::time = TIME '00:00:00'
    ) AS rows_midnight,

    COUNT(*) FILTER (
        WHERE review_creation_date::timestamp::time = TIME '01:00:00'
    ) AS rows_at_one_am,

    COUNT(*) FILTER (
        WHERE review_creation_date::timestamp::time NOT IN (
            TIME '00:00:00',
            TIME '01:00:00'
        )
    ) AS rows_other_times
FROM public.order_reviews;
-- Observation:
-- 85 rows contain 01:00:00 and all remaining rows contain 00:00:00.
-- The time component is not analytically meaningful for this project,
-- so review_creation_date will be converted to DATE.

-- Check whether order_estimated_delivery_date contains
-- meaningful time information.
SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE order_estimated_delivery_date::timestamp::time =
              TIME '00:00:00'
    ) AS rows_midnight,

    COUNT(*) FILTER (
        WHERE order_estimated_delivery_date::timestamp::time <>
              TIME '00:00:00'
    ) AS rows_other_times
FROM public.orders;
-- Observation:
-- All values contain 00:00:00.
-- The column represents an estimated calendar date,
-- so it will be converted to DATE.

-- ---------------------------------------------------------
-- 4.2 Integer conversions
-- ---------------------------------------------------------

-- 1)
-- Verify that product attributes contain only whole numbers
-- before converting from double precision to integer.

SELECT
    COUNT(*) FILTER (
        WHERE product_name_length IS NOT NULL
          AND product_name_length <> TRUNC(product_name_length)
    ) AS fractional_product_name_length,

    COUNT(*) FILTER (
        WHERE product_description_length IS NOT NULL
          AND product_description_length <> TRUNC(product_description_length)
    ) AS fractional_product_description_length,

    COUNT(*) FILTER (
        WHERE product_photos_qty IS NOT NULL
          AND product_photos_qty <> TRUNC(product_photos_qty)
    ) AS fractional_product_photos_qty,

    COUNT(*) FILTER (
        WHERE product_weight_g IS NOT NULL
          AND product_weight_g <> TRUNC(product_weight_g)
    ) AS fractional_product_weight_g,

    COUNT(*) FILTER (
        WHERE product_length_cm IS NOT NULL
          AND product_length_cm <> TRUNC(product_length_cm)
    ) AS fractional_product_length_cm,

    COUNT(*) FILTER (
        WHERE product_height_cm IS NOT NULL
          AND product_height_cm <> TRUNC(product_height_cm)
    ) AS fractional_product_height_cm,

    COUNT(*) FILTER (
        WHERE product_width_cm IS NOT NULL
          AND product_width_cm <> TRUNC(product_width_cm)
    ) AS fractional_product_width_cm
FROM public.products;

-- 2)
-- Integers in PostgreSQL have a limited range.
-- Therefore, before reducing the type, we check the min/max.
SELECT
    MIN(order_item_id) AS min_order_item_id,
    MAX(order_item_id) AS max_order_item_id
FROM public.order_items;

SELECT
    MIN(payment_sequential) AS min_payment_sequential,
    MAX(payment_sequential) AS max_payment_sequential,
    MIN(payment_installments) AS min_payment_installments,
    MAX(payment_installments) AS max_payment_installments
FROM public.order_payments;

SELECT
    MIN(review_score) AS min_review_score,
    MAX(review_score) AS max_review_score
FROM public.order_reviews;

SELECT
    MIN(customer_zip_code_prefix) AS min_customer_zip,
    MAX(customer_zip_code_prefix) AS max_customer_zip
FROM public.customers;

SELECT
    MIN(seller_zip_code_prefix) AS min_seller_zip,
    MAX(seller_zip_code_prefix) AS max_seller_zip
FROM public.sellers;

SELECT
    MIN(geolocation_zip_code_prefix) AS min_geolocation_zip,
    MAX(geolocation_zip_code_prefix) AS max_geolocation_zip
FROM public.geolocation;

-- ---------------------------------------------------------
-- 4.3 Monetary numeric conversions
-- ---------------------------------------------------------

-- Verify that price and freight values can be converted
-- to NUMERIC(12,2) without unexpected precision loss.
SELECT
    COUNT(*) FILTER (
        WHERE price IS NOT NULL
          AND price::numeric <> ROUND(price::numeric, 2)
    ) AS price_more_than_two_decimals,

    COUNT(*) FILTER (
        WHERE freight_value IS NOT NULL
          AND freight_value::numeric <>
              ROUND(freight_value::numeric, 2)
    ) AS freight_more_than_two_decimals,

    MAX(ABS(price)) AS max_price,
    MAX(ABS(freight_value)) AS max_freight_value
FROM public.order_items;

-- Verify that payment values can be converted to NUMERIC(12,2).
SELECT
    COUNT(*) FILTER (
        WHERE payment_value IS NOT NULL
          AND payment_value::numeric <>
              ROUND(payment_value::numeric, 2)
    ) AS payment_more_than_two_decimals,

    MAX(ABS(payment_value)) AS max_payment_value
FROM public.order_payments;


-- =========================================================
-- 5. DOMAIN AND BUSINESS-RULE VALIDATION
-- =========================================================

-- ---------------------------------------------------------
-- 5.1 Monetary values
-- ---------------------------------------------------------

-- Negative monetary values are invalid.
-- Zero values are reported separately because they may be suspicious,
-- but they are not automatically treated as data errors.
SELECT
    COUNT(*) FILTER (WHERE price < 0) AS negative_price,
    COUNT(*) FILTER (WHERE price = 0) AS zero_price,
    COUNT(*) FILTER (WHERE freight_value < 0) AS negative_freight_value,
    COUNT(*) FILTER (WHERE freight_value = 0) AS zero_freight_value
FROM public.order_items;

SELECT
    COUNT(*) FILTER (WHERE payment_value < 0) AS negative_payment_value,
    COUNT(*) FILTER (WHERE payment_value = 0) AS zero_payment_value
FROM public.order_payments;
-- Observation:
-- Zero-value payments are treated as suspicious rather than invalid
-- and should be investigated before any cleaning decision.

-- ---------------------------------------------------------
-- 5.2 Reviews
-- ---------------------------------------------------------

-- Review score must be between 1 and 5.
SELECT COUNT(*) AS invalid_review_score
FROM public.order_reviews
WHERE review_score < 1
   OR review_score > 5;

-- Review creation must not occur after the answer timestamp.
SELECT COUNT(*) AS invalid_review_timestamps
FROM public.order_reviews
WHERE review_creation_date IS NOT NULL
  AND review_answer_timestamp IS NOT NULL
  AND review_creation_date::timestamp > review_answer_timestamp::timestamp;

-- ---------------------------------------------------------
-- 5.3 Product attributes
-- ---------------------------------------------------------

-- Physical dimensions, weight, text lengths and photo count must not be negative.
SELECT
    COUNT(*) FILTER (WHERE product_name_length < 0) AS negative_product_name_length,
    COUNT(*) FILTER (WHERE product_description_length < 0) AS negative_product_description_length,
    COUNT(*) FILTER (WHERE product_photos_qty < 0) AS negative_product_photos_qty,
    COUNT(*) FILTER (WHERE product_weight_g < 0) AS negative_product_weight_g,
    COUNT(*) FILTER (WHERE product_length_cm < 0) AS negative_product_length_cm,
    COUNT(*) FILTER (WHERE product_height_cm < 0) AS negative_product_height_cm,
    COUNT(*) FILTER (WHERE product_width_cm < 0) AS negative_product_width_cm
FROM public.products;

-- Zero values may be suspicious for physical measurements.
SELECT
    COUNT(*) FILTER (WHERE product_weight_g = 0) AS zero_weight,
    COUNT(*) FILTER (WHERE product_length_cm = 0) AS zero_length,
    COUNT(*) FILTER (WHERE product_height_cm = 0) AS zero_height,
    COUNT(*) FILTER (WHERE product_width_cm = 0) AS zero_width
FROM public.products;
-- Observation:
-- Four products have product_weight_g = 0.
-- The source values are retained, but zero weight should be treated
-- as potentially missing or invalid in weight-based analysis.

-- ---------------------------------------------------------
-- 5.4 Order timeline and business-rule checks
-- ---------------------------------------------------------

-- Approval must not occur before purchase.
SELECT COUNT(*) AS approval_before_purchase
FROM public.orders
WHERE order_approved_at IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL
  AND order_approved_at::timestamp < order_purchase_timestamp::timestamp;

-- Carrier handoff must not occur before purchase.
SELECT COUNT(*) AS carrier_before_purchase
FROM public.orders
WHERE order_delivered_carrier_date IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL
  AND order_delivered_carrier_date::timestamp < order_purchase_timestamp::timestamp;

-- Customer delivery must not occur before carrier handoff.
SELECT COUNT(*) AS customer_delivery_before_carrier
FROM public.orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_delivered_carrier_date IS NOT NULL
  AND order_delivered_customer_date::timestamp < order_delivered_carrier_date::timestamp;

-- Direct sanity check: customer delivery must not occur before purchase.
SELECT COUNT(*) AS delivery_before_purchase
FROM public.orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date::timestamp < order_purchase_timestamp::timestamp;

-- Delivered orders should normally have an actual customer delivery timestamp.
SELECT COUNT(*) AS delivered_without_delivery_date
FROM public.orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;

-- Identify non-delivered statuses that still contain a customer delivery timestamp.
SELECT COUNT(*) AS delivery_date_for_non_delivered_status
FROM public.orders
WHERE order_status <> 'delivered'
  AND order_delivered_customer_date IS NOT NULL;

-- ---------------------------------------------------------
-- 5.5 Sequential identifiers
-- ---------------------------------------------------------

-- order_item_id must be positive.
SELECT
    COUNT(*) FILTER (
        WHERE order_item_id <= 0
    ) AS invalid_order_item_id
FROM public.order_items;

-- payment_sequential and payment_installments must be positive.
SELECT
    COUNT(*) FILTER (
        WHERE payment_sequential <= 0
    ) AS invalid_payment_sequential,
    COUNT(*) FILTER (
        WHERE payment_installments < 0
    ) AS negative_installments,
    COUNT(*) FILTER (
        WHERE payment_installments = 0
    ) AS zero_installments
FROM public.order_payments;

-- ---------------------------------------------------------
-- 5.6 Geography
-- ---------------------------------------------------------

-- Validate state-code length and ZIP-prefix domain.
SELECT
    (
        SELECT COUNT(*)
        FROM public.customers
        WHERE LENGTH(customer_state) <> 2
    ) AS invalid_customer_state,

    (
        SELECT COUNT(*)
        FROM public.sellers
        WHERE LENGTH(seller_state) <> 2
    ) AS invalid_seller_state,

    (
        SELECT COUNT(*)
        FROM public.geolocation
        WHERE LENGTH(geolocation_state) <> 2
    ) AS invalid_geolocation_state,

    (
        SELECT COUNT(*)
        FROM public.customers
        WHERE customer_zip_code_prefix < 0
    ) AS invalid_customer_zip_prefix,

    (
        SELECT COUNT(*)
        FROM public.sellers
        WHERE seller_zip_code_prefix < 0
    ) AS invalid_seller_zip_prefix,

    (
        SELECT COUNT(*)
        FROM public.geolocation
        WHERE geolocation_zip_code_prefix < 0
    ) AS invalid_geolocation_zip_prefix;

-- Validate geographic coordinate ranges.
SELECT
    COUNT(*) FILTER (
        WHERE geolocation_lat NOT BETWEEN -90 AND 90
    ) AS invalid_latitude,

    COUNT(*) FILTER (
        WHERE geolocation_lng NOT BETWEEN -180 AND 180
    ) AS invalid_longitude
FROM public.geolocation;

-- ---------------------------------------------------------
-- 5.7 Suspicious categorical values
-- ---------------------------------------------------------

-- Review distinct source categories before adding constraints.
SELECT DISTINCT payment_type
FROM public.order_payments
ORDER BY payment_type;

SELECT DISTINCT order_status
FROM public.orders
ORDER BY order_status;

-- Inspect records whose payment type was not defined
-- by the source system.
SELECT *
FROM public.order_payments
WHERE payment_type = 'not_defined';