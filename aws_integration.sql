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
                STORAGE_AWS_EXTERNAL_ID = 'GTC13243_SFCRole=2_/NJpsii2JzqThIuUeEM0dL_
