-- =========================================
-- Project: Snowflake Environment Setup
-- Description:
-- This script sets up the Snowflake environment for the Frostbyte Tasty Bytes project.
-- It creates the database, schemas, warehouses, and roles required for data engineering,
-- analytics, and administration.
-- =========================================

-- =========================================
-- 1️⃣ Set Role
-- =========================================
USE ROLE ACCOUNTADMIN;

-- =========================================
-- 2️⃣ Record Current Region
-- Description: Capture the current Snowflake region for DataLake integration.
-- =========================================
SELECT current_region();

-- =========================================
-- 3️⃣ Create Database
-- =========================================
CREATE OR REPLACE DATABASE frostbyte_tasty_bytes;

-- =========================================
-- 4️⃣ Create Schemas
-- Description: Organize data into raw, harmonized, and analytics layers.
-- =========================================
CREATE OR REPLACE SCHEMA frostbyte_tasty_bytes.raw_pos;
CREATE OR REPLACE SCHEMA frostbyte_tasty_bytes.raw_customer;
CREATE OR REPLACE SCHEMA frostbyte_tasty_bytes.harmonized;
CREATE OR REPLACE SCHEMA frostbyte_tasty_bytes.analytics;

-- =========================================
-- 5️⃣ Create Warehouses
-- Description: Warehouses for different workloads: build, data engineering, BI.
-- =========================================
CREATE OR REPLACE WAREHOUSE demo_build_wh
    WAREHOUSE_SIZE = 'medium'
    WAREHOUSE_TYPE = 'standard'
    AUTO_SUSPEND = 30
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Demo build warehouse for frostbyte assets';
    
CREATE OR REPLACE WAREHOUSE tasty_de_wh
    WAREHOUSE_SIZE = 'xsmall'
    WAREHOUSE_TYPE = 'standard'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Data engineering warehouse for Tasty Bytes';

CREATE OR REPLACE WAREHOUSE tasty_bi_wh
    WAREHOUSE_SIZE = 'small'
    WAREHOUSE_TYPE = 'standard'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Business intelligence warehouse for Tasty Bytes';

-- =========================================
-- 6️⃣ Create Roles
-- Description: Functional roles for admin, data engineering, and BI operations.
-- =========================================
CREATE ROLE IF NOT EXISTS tasty_admin
    COMMENT = 'Admin role for Tasty Bytes';

CREATE ROLE IF NOT EXISTS tasty_data_engineer
    COMMENT = 'Data engineer role for Tasty Bytes';

CREATE ROLE IF NOT EXISTS tasty_bi
    COMMENT = 'Business intelligence role for Tasty Bytes';

-- =========================================
-- 7️⃣ Establish Role Hierarchy
-- Description: Grant roles in a hierarchy to manage permissions efficiently.
-- =========================================
GRANT ROLE tasty_admin TO ROLE ACCOUNTADMIN;
GRANT ROLE tasty_data_engineer TO ROLE tasty_admin;
GRANT ROLE tasty_bi TO ROLE tasty_admin;
