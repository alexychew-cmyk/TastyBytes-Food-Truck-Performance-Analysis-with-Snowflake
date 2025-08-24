-- =========================================
-- Project: AWS S3 Integration & Iceberg Table Setup
-- Description:
-- This script integrates Snowflake with an AWS S3 bucket,
-- creates an external volume, and sets up Iceberg tables
-- for querying truck review data. It also creates views
-- to unify multilingual reviews and compute sentiment.
-- =========================================

-- =========================================
-- 1️⃣ Set Role, Database, and Schema
-- =========================================
USE ROLE ACCOUNTADMIN;
USE DATABASE frostbyte_tasty_bytes;
USE SCHEMA raw_customer;

-- =========================================
-- 2️⃣ Create External Volume
-- Description:
-- Defines an external volume pointing to the S3 bucket 'vholreviews'.
-- Uses the AWS Role ARN and External ID from storage integration.
-- ALLOW_WRITES = TRUE enables ingestion of files.
-- =========================================
CREATE OR REPLACE EXTERNAL VOLUME vol_tastybytes_truckreviews
    STORAGE_LOCATIONS =
        (
            (
                NAME = 'reviews-s3-volume',
                STORAGE_PROVIDER = 'S3',
                STORAGE_BASE_URL = 's3://vholreviews',
                STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::551171829142:role/chew_admin',
                STORAGE_AWS_EXTERNAL_ID = 'GTC13243_SFCRole=2_/NJpsii2JzqThIuUeEM0dL7JIyA='
            )
        )
    ALLOW_WRITES = TRUE;

-- =========================================
-- 3️⃣ Create Iceberg Table
-- Description:
-- Iceberg table stores metadata for staged truck review data,
-- enabling efficient querying on large S3 datasets.
-- =========================================
CREATE OR REPLACE ICEBERG TABLE iceberg_truck_reviews
(
    source_name VARCHAR,
    quarter VARCHAR,
    order_id BIGINT,
    truck_id INT,
    language VARCHAR, 
    review VARCHAR,
    primary_city VARCHAR,
    customer_id VARCHAR,
    year DATE,
    month DATE,
    truck_brand VARCHAR,
    review_date DATE
)
CATALOG = 'SNOWFLAKE'
EXTERNAL_VOLUME = 'vol_tastybytes_truckreviews'
BASE_LOCATION = 'reviews-s3-volume';

-- =========================================
-- 4️⃣ Insert Staged Data into Iceberg Table
-- Description:
-- Loads CSV files from the stage '@stg_truck_reviews' into the Iceberg table.
-- Randomized review_date added for demo purposes.
-- =========================================
INSERT INTO iceberg_truck_reviews
SELECT 
    SPLIT_PART(METADATA$FILENAME, '/', 4) AS source_name,
    CONCAT(SPLIT_PART(METADATA$FILENAME, '/', 2), '/', SPLIT_PART(METADATA$FILENAME, '/', 3)) AS quarter,
    $1 AS order_id,
    $2 AS truck_id,
    $3 AS language,
    $5 AS review,
    $6 AS primary_city, 
    $7 AS customer_id,
    $8 AS year,
    $9 AS month,
    $10 AS truck_brand,
    DATEADD(day, -UNIFORM(0,180,RANDOM()), CURRENT_DATE()) AS review_date
FROM @stg_truck_reviews
(FILE_FORMAT => frostbyte_tasty_bytes.raw_customer.ff_csv,
 PATTERN => '.*reviews.*[.]csv');

-- =========================================
-- 5️⃣ Switch to Analytics Schema
-- =========================================
USE SCHEMA analytics;

-- =========================================
-- 6️⃣ Create Unified Reviews View
-- Description:
-- Combines English and non-English reviews into a single view.
-- Non-English reviews are translated to English using Snowflake Cortex AI.
-- Sentiment scores extracted for analytics purposes.
-- =========================================
CREATE OR REPLACE VIEW frostbyte_tasty_bytes.analytics.product_unified_reviews AS
SELECT
    order_id, quarter, truck_id, language, source_name, primary_city, truck_brand,
    snowflake.cortex.sentiment(review) AS sentiment, review_date
FROM frostbyte_tasty_bytes.raw_customer.iceberg_truck_reviews
WHERE language = 'en'
UNION
SELECT
    order_id, quarter, truck_id, language, source_name, primary_city, truck_brand,
    snowflake.cortex.sentiment(snowflake.cortex.translate(review, language, 'en')) AS sentiment, review_date
FROM frostbyte_tasty_bytes.raw_customer.iceberg_truck_reviews
WHERE language != 'en';

-- =========================================
-- 7️⃣ Create Aggregated Sentiment View
-- Description:
-- Computes average sentiment grouped by city and truck brand,
-- providing insights into customer satisfaction across regions and brands.
-- =========================================
CREATE OR REPLACE VIEW frostbyte_tasty_bytes.analytics.product_sentiment AS
SELECT
    primary_city, 
    truck_brand, 
    AVG(snowflake.cortex.sentiment(review_date)) AS avg_review_sentiment
FROM frostbyte_tasty_bytes.analytics.product_unified_reviews
GROUP BY primary_city, truck_brand;
