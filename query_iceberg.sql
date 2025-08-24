-- =========================================
-- Project: Iceberg Table Load from AWS S3 Datalake
-- Description:
-- This script ingests review data stored in AWS S3 into a Snowflake
-- managed Iceberg table using an external volume. It then creates
-- unified views for multilingual sentiment analysis using Snowflake
-- Cortex AI.
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
-- Defines an external volume pointing to the S3 bucket `vholreviews`.
-- Uses the correct AWS Role ARN and External ID from the storage integration.
-- ALLOW_WRITES = TRUE to allow Snowflake to ingest files.
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
-- Iceberg table tracks metadata for the staged reviews data.
-- This enables efficient querying on large S3 datasets.
-- =========================================
CREATE OR REPLACE ICEBERG
