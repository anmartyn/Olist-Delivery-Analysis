BEGIN;

-- =========================================================
-- CREATE CLEAN ZIP-CODE GEOLOCATION LOOKUP
-- =========================================================

-- The source geolocation table may contain multiple records
-- for the same ZIP-code prefix.

-- The cleaned table stores one row per ZIP-code prefix:
-- - median latitude and longitude are used to reduce the
--   influence of geographic outliers;
-- - the most frequently occurring city/state combination
--   is selected as the representative location.

DROP TABLE IF EXISTS public.zip_code_geolocation;

CREATE TABLE public.zip_code_geolocation (
    zip_code_prefix INTEGER PRIMARY KEY,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    city TEXT,
    state VARCHAR(2)
);


WITH coordinate_summary AS (
    SELECT
        geolocation_zip_code_prefix AS zip_code_prefix,

        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY geolocation_lat
        ) AS latitude,

        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY geolocation_lng
        ) AS longitude

    FROM public.geolocation
    WHERE geolocation_zip_code_prefix IS NOT NULL
    GROUP BY geolocation_zip_code_prefix
),

ranked_locations AS (
    SELECT
        geolocation_zip_code_prefix AS zip_code_prefix,
        geolocation_city AS city,
        geolocation_state AS state,
        COUNT(*) AS location_count,

        ROW_NUMBER() OVER (
            PARTITION BY geolocation_zip_code_prefix
            ORDER BY
                COUNT(*) DESC,
                geolocation_state,
                geolocation_city
        ) AS location_rank

    FROM public.geolocation
    WHERE geolocation_zip_code_prefix IS NOT NULL
    GROUP BY
        geolocation_zip_code_prefix,
        geolocation_city,
        geolocation_state
)

INSERT INTO public.zip_code_geolocation (
    zip_code_prefix,
    latitude,
    longitude,
    city,
    state
)
SELECT
    coordinates.zip_code_prefix,
    coordinates.latitude,
    coordinates.longitude,
    locations.city,
    locations.state
FROM coordinate_summary AS coordinates
JOIN ranked_locations AS locations
    ON coordinates.zip_code_prefix = locations.zip_code_prefix
WHERE locations.location_rank = 1;


-- =========================================================
-- COMPLETE ZIP-CODE LOOKUP COVERAGE
-- =========================================================

-- Some ZIP-code prefixes used by customers and sellers are
-- absent from the source geolocation table.

-- These ZIP codes are added to the cleaned lookup using the
-- available city and state values from the related tables.
-- Latitude and longitude remain NULL because the source
-- dataset does not provide reliable coordinates for them.
--
-- This step ensures full ZIP-code coverage before foreign
-- key constraints are added in 04_constraints_and_indexes.sql.


-- Add ZIP codes found in customers but absent from the
-- source geolocation table. Coordinates remain NULL.

INSERT INTO public.zip_code_geolocation (
    zip_code_prefix,
    city,
    state
)
SELECT
    c.customer_zip_code_prefix,
    MIN(c.customer_city) AS city,
    MIN(c.customer_state) AS state
FROM public.customers AS c
LEFT JOIN public.zip_code_geolocation AS z
    ON c.customer_zip_code_prefix = z.zip_code_prefix
WHERE z.zip_code_prefix IS NULL
GROUP BY c.customer_zip_code_prefix;

-- Add remaining ZIP codes found in sellers.

INSERT INTO public.zip_code_geolocation (
    zip_code_prefix,
    city,
    state
)
SELECT
    s.seller_zip_code_prefix,
    MIN(s.seller_city) AS city,
    MIN(s.seller_state) AS state
FROM public.sellers AS s
LEFT JOIN public.zip_code_geolocation AS z
    ON s.seller_zip_code_prefix = z.zip_code_prefix
WHERE z.zip_code_prefix IS NULL
GROUP BY s.seller_zip_code_prefix;

COMMIT;