-- =========================================
-- Project: Raw Zone Table Load from AWS S3
-- Description:
-- This script loads raw zone tables from CSV files stored in AWS S3 
-- into Snowflake. It covers country, franchise, location, menu, truck,
-- customer loyalty, and order tables. It also performs a sample 
-- timestamp adjustment for order_header data.
-- =========================================

-- =========================================
-- 1️⃣ Set Role and Warehouse
-- =========================================
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE demo_build_wh;

-- =========================================
-- 2️⃣ Load Raw Tables from S3
-- =========================================

-- Country table
COPY INTO frostbyte_tasty_bytes.raw_pos.country
FROM @frostbyte_tasty_bytes.public.s3load/raw_pos/country/;

-- Franchise table
COPY INTO frostbyte_tasty_bytes.raw_pos.franchise
FROM @frostbyte_tasty_bytes.public.s3load/raw_pos/franchise/;

-- Location table
COPY INTO frostbyte_tasty_bytes.raw_pos.location
FROM @frostbyte_tasty_bytes.public.s3load/raw_pos/location/;

-- Menu table
COPY INTO frostbyte_tasty_bytes.raw_pos.menu
FROM @frostbyte_tasty_bytes.public.s3load/raw_pos/menu/;

-- Truck table
COPY INTO frostbyte_tasty_bytes.raw_pos.truck
FROM @frostbyte_tasty_bytes.public.s3load/raw_pos/truck/;

-- Customer Loyalty table
COPY INTO frostbyte_tasty_bytes.raw_customer.customer_loyalty
FROM @frostbyte_tasty_bytes.public.s3load/raw_customer/customer_loyalty/;

-- Order Header table
COPY INTO frostbyte_tasty_bytes.raw_pos.order_header
FROM @frostbyte_tasty_bytes.public.s3load/raw_pos/order_header/;

-- =========================================
-- 3️⃣ Adjust Order Timestamps
-- Sample data is from 2022; shift by 3 years
-- =========================================
UPDATE frostbyte_tasty_bytes.raw_pos.order_header
SET order_ts = DATEADD(year, 3, order_ts);

-- Order Detail table
COPY INTO frostbyte_tasty_bytes.raw_pos.order_detail
FROM @frostbyte_tasty_bytes.public.s3load/raw_pos/order_detail/;

-- =========================================
-- 4️⃣ Cleanup
-- =========================================
DROP WAREHOUSE IF EXISTS demo_build_wh;

-- =========================================
-- 5️⃣ Setup Completion Note
-- =========================================
SELECT 'frostbyte_tasty_bytes setup is now complete' AS note;
