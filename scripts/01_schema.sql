-- ============================================================
-- Create Database
-- ============================================================

DROP DATABASE IF EXISTS DataWarehouseAnalytics;

CREATE DATABASE DataWarehouseAnalytics;

USE DataWarehouseAnalytics;

-- ============================================================
-- NOTE ON SCHEMAS:
-- MSSQL has schemas INSIDE a database (gold.dim_customers)
-- MySQL does not have schemas — the database itself acts as
-- the schema. So we just use the table name directly.
-- ============================================================

CREATE TABLE dim_customers (
    customer_key     INT,
    customer_id      INT,
    customer_number  VARCHAR(50),
    first_name       VARCHAR(50),
    last_name        VARCHAR(50),
    country          VARCHAR(50),
    marital_status   VARCHAR(50),
    gender           VARCHAR(50),
    birthdate        DATE,
    create_date      DATE
);

CREATE TABLE dim_products (
    product_key      INT,
    product_id       INT,
    product_number   VARCHAR(50),
    product_name     VARCHAR(50),
    category_id      VARCHAR(50),
    category         VARCHAR(50),
    subcategory      VARCHAR(50),
    maintenance      VARCHAR(50),
    cost             INT,
    product_line     VARCHAR(50),
    start_date       DATE
);

CREATE TABLE fact_sales (
    order_number     VARCHAR(50),
    product_key      INT,
    customer_key     INT,
    order_date       DATE,
    shipping_date    DATE,
    due_date         DATE,
    sales_amount     INT,
    quantity         TINYINT UNSIGNED,   -- UNSIGNED = 0 to 255
    price            INT
);

-- ============================================================
-- Load Data from CSV files
-- LOAD DATA INFILE ... with equivalent options
-- ============================================================

TRUNCATE TABLE dim_customers;
-- ============================================================
-- file path from secure_file_priv was removed
-- ============================================================
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/Users/Kshitij/Desktop/SQL_Projects/sql-data-analytics-project/datasets/flat-files/dim_customers.csv'
INTO TABLE dim_customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;          -- FIRSTROW=2 in MSSQL = IGNORE 1 ROWS in MySQL

TRUNCATE TABLE dim_products;

LOAD DATA INFILE 'C:/Users/Kshitij/Desktop/SQL_Projects/sql-data-analytics-project/datasets/flat-files/dim_products.csv'
INTO TABLE dim_products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

TRUNCATE TABLE fact_sales;

LOAD DATA INFILE 'C:/Users/Kshitij/Desktop/SQL_Projects/sql-data-analytics-project/datasets/flat-files/fact_sales.csv'
INTO TABLE fact_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
