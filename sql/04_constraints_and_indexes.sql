BEGIN;

-- =========================================================
-- CONSTRAINTS
-- =========================================================


-- =========================================================
-- 1. TABLE ZIP CODE GEOLOCATION
-- =========================================================

-- zip_code_prefix is already PRIMARY KEY because the table
-- was created with this constraint in 03_create_zip_geolocation.sql.

ALTER TABLE public.zip_code_geolocation
    ALTER COLUMN city SET NOT NULL,
    ALTER COLUMN state SET NOT NULL,

    ADD CONSTRAINT chk_zip_code_geolocation_latitude
        CHECK (latitude BETWEEN -90 AND 90),

    ADD CONSTRAINT chk_zip_code_geolocation_longitude
        CHECK (longitude BETWEEN -180 AND 180),

    ADD CONSTRAINT chk_zip_code_geolocation_state
        CHECK (CHAR_LENGTH(state) = 2);


-- =========================================================
-- 2. TABLE PRODUCT CATEGORY NAME TRANSLATION
-- =========================================================

ALTER TABLE public.product_category_name_translation
    ALTER COLUMN product_category_name_english SET NOT NULL,

    ADD CONSTRAINT pk_product_category_name_translation
        PRIMARY KEY (product_category_name),

    ADD CONSTRAINT uq_product_category_name_english
        UNIQUE (product_category_name_english);


-- =========================================================
-- 3. TABLE CUSTOMERS
-- =========================================================

ALTER TABLE public.customers
    ALTER COLUMN customer_unique_id SET NOT NULL,
    ALTER COLUMN customer_zip_code_prefix SET NOT NULL,
    ALTER COLUMN customer_city SET NOT NULL,
    ALTER COLUMN customer_state SET NOT NULL,

    ADD CONSTRAINT pk_customers
        PRIMARY KEY (customer_id),

    ADD CONSTRAINT fk_customers_zip_code
        FOREIGN KEY (customer_zip_code_prefix)
        REFERENCES public.zip_code_geolocation (zip_code_prefix),

    ADD CONSTRAINT chk_customers_state
        CHECK (CHAR_LENGTH(customer_state) = 2);


-- =========================================================
-- 4. TABLE PRODUCTS
-- =========================================================

-- Product attributes remain nullable because some source
-- product records are incomplete.

ALTER TABLE public.products
    ADD CONSTRAINT pk_products
        PRIMARY KEY (product_id),

    ADD CONSTRAINT fk_products_category
        FOREIGN KEY (product_category_name)
        REFERENCES public.product_category_name_translation (
            product_category_name
        ),

    ADD CONSTRAINT chk_products_name_length
        CHECK (
            product_name_length IS NULL
            OR product_name_length >= 0
        ),

    ADD CONSTRAINT chk_products_description_length
        CHECK (
            product_description_length IS NULL
            OR product_description_length >= 0
        ),

    ADD CONSTRAINT chk_products_photos_qty
        CHECK (
            product_photos_qty IS NULL
            OR product_photos_qty >= 0
        ),

    ADD CONSTRAINT chk_products_weight
        CHECK (
            product_weight_g IS NULL
            OR product_weight_g >= 0
        ),

    ADD CONSTRAINT chk_products_length
        CHECK (
            product_length_cm IS NULL
            OR product_length_cm >= 0
        ),

    ADD CONSTRAINT chk_products_height
        CHECK (
            product_height_cm IS NULL
            OR product_height_cm >= 0
        ),

    ADD CONSTRAINT chk_products_width
        CHECK (
            product_width_cm IS NULL
            OR product_width_cm >= 0
        );


-- =========================================================
-- 5. TABLE SELLERS
-- =========================================================

ALTER TABLE public.sellers
    ALTER COLUMN seller_zip_code_prefix SET NOT NULL,
    ALTER COLUMN seller_city SET NOT NULL,
    ALTER COLUMN seller_state SET NOT NULL,

    ADD CONSTRAINT pk_sellers
        PRIMARY KEY (seller_id),

    ADD CONSTRAINT fk_sellers_zip_code
        FOREIGN KEY (seller_zip_code_prefix)
        REFERENCES public.zip_code_geolocation (zip_code_prefix),

    ADD CONSTRAINT chk_sellers_state
        CHECK (CHAR_LENGTH(seller_state) = 2);


-- =========================================================
-- 6. TABLE ORDERS
-- =========================================================

-- Approval and delivery timestamps remain nullable because
-- canceled and unfinished orders may not have these events.

ALTER TABLE public.orders
    ALTER COLUMN customer_id SET NOT NULL,
    ALTER COLUMN order_status SET NOT NULL,
    ALTER COLUMN order_purchase_timestamp SET NOT NULL,
    ALTER COLUMN order_estimated_delivery_date SET NOT NULL,

    ADD CONSTRAINT pk_orders
        PRIMARY KEY (order_id),

    ADD CONSTRAINT uq_orders_customer_id
        UNIQUE (customer_id),

    ADD CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES public.customers (customer_id),

    ADD CONSTRAINT chk_orders_status
        CHECK (
            order_status IN (
                'approved',
                'canceled',
                'created',
                'delivered',
                'invoiced',
                'processing',
                'shipped',
                'unavailable'
            )
        );


-- =========================================================
-- 7. TABLE ORDER PAYMENTS
-- =========================================================

ALTER TABLE public.order_payments
    ALTER COLUMN payment_type SET NOT NULL,
    ALTER COLUMN payment_installments SET NOT NULL,
    ALTER COLUMN payment_value SET NOT NULL,

    ADD CONSTRAINT pk_order_payments
        PRIMARY KEY (
            order_id,
            payment_sequential
        ),

    ADD CONSTRAINT fk_order_payments_order
        FOREIGN KEY (order_id)
        REFERENCES public.orders (order_id),

    ADD CONSTRAINT chk_order_payments_sequential
        CHECK (payment_sequential > 0),

    ADD CONSTRAINT chk_order_payments_installments
        CHECK (payment_installments >= 0),

    ADD CONSTRAINT chk_order_payments_value
        CHECK (payment_value >= 0),

    ADD CONSTRAINT chk_order_payments_type
        CHECK (
            payment_type IN (
                'boleto',
                'credit_card',
                'debit_card',
                'voucher',
                'not_defined'
            )
        );


-- =========================================================
-- 8. TABLE ORDER ITEMS
-- =========================================================

ALTER TABLE public.order_items
    ALTER COLUMN product_id SET NOT NULL,
    ALTER COLUMN seller_id SET NOT NULL,
    ALTER COLUMN shipping_limit_date SET NOT NULL,
    ALTER COLUMN price SET NOT NULL,
    ALTER COLUMN freight_value SET NOT NULL,

    ADD CONSTRAINT pk_order_items
        PRIMARY KEY (
            order_id,
            order_item_id
        ),

    ADD CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES public.orders (order_id),

    ADD CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES public.products (product_id),

    ADD CONSTRAINT fk_order_items_seller
        FOREIGN KEY (seller_id)
        REFERENCES public.sellers (seller_id),

    ADD CONSTRAINT chk_order_items_item_id
        CHECK (order_item_id > 0),

    ADD CONSTRAINT chk_order_items_price
        CHECK (price >= 0),

    ADD CONSTRAINT chk_order_items_freight
        CHECK (freight_value >= 0);


-- =========================================================
-- 9. TABLE ORDER REVIEWS
-- =========================================================

-- Review title and message remain nullable because customers
-- are not required to provide written feedback.

ALTER TABLE public.order_reviews
    ALTER COLUMN review_score SET NOT NULL,
    ALTER COLUMN review_creation_date SET NOT NULL,
    ALTER COLUMN review_answer_timestamp SET NOT NULL,

    ADD CONSTRAINT pk_order_reviews
        PRIMARY KEY (
            review_id,
            order_id
        ),

    ADD CONSTRAINT fk_order_reviews_order
        FOREIGN KEY (order_id)
        REFERENCES public.orders (order_id),

    ADD CONSTRAINT chk_order_reviews_score
        CHECK (review_score BETWEEN 1 AND 5),

    ADD CONSTRAINT chk_order_reviews_timeline
        CHECK (
            review_creation_date
            <= review_answer_timestamp::DATE
        );


-- =========================================================
-- INDEXES
-- =========================================================

-- PostgreSQL automatically creates indexes for PRIMARY KEY
-- and UNIQUE constraints. The indexes below support foreign
-- key joins and common analytical filters.


-- 1) Customers

CREATE INDEX idx_customers_unique_id
    ON public.customers (customer_unique_id);

CREATE INDEX idx_customers_zip_code
    ON public.customers (customer_zip_code_prefix);

-- 2) Products

CREATE INDEX idx_products_category
    ON public.products (product_category_name);

-- 3) Sellers

CREATE INDEX idx_sellers_zip_code
    ON public.sellers (seller_zip_code_prefix);

-- 4) Orders

CREATE INDEX idx_orders_purchase_timestamp
    ON public.orders (order_purchase_timestamp);

CREATE INDEX idx_orders_delivered_customer_date
    ON public.orders (order_delivered_customer_date);

-- 5) Order items

-- order_id does not need a separate index because it is the
-- first column of the composite primary key.

CREATE INDEX idx_order_items_product_id
    ON public.order_items (product_id);

CREATE INDEX idx_order_items_seller_id
    ON public.order_items (seller_id);

-- 6) Order reviews

-- order_id needs its own index because it is the second
-- column of the composite primary key.

CREATE INDEX idx_order_reviews_order_id
    ON public.order_reviews (order_id);


COMMIT;