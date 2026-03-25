-- Check For Nulls or Duplicates in Primary Key
-- Ensure: No NULLs, No Duplicates

SELECT
    cst_id,
    COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;


-- Validation Summary Quick Check
SELECT
    COUNT(*) AS total_records,
    COUNT(cst_id) AS non_null_records,
    COUNT(*) - COUNT(cst_id) AS null_count,
    COUNT(DISTINCT cst_id) AS unique_keys,
    COUNT(*) - COUNT(DISTINCT cst_id) AS duplicate_count
FROM bronze.crm_cust_info;





-- Check for unwanted Spaces
-- Spaces can break joins, grouping, and reporting hence it is necessary to clean it to ensure clean, standardized text data

SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);





-- Data Standardization & Consistency
-- Helps detect inconsistent values like: 'M', 'Male', 'male', 'F', 'Female', 'female'

SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;

-- After identifying inconsistencies, you typically standardize:

UPDATE bronze.crm_cust_info
SET cst_gndr = 
    CASE 
        WHEN LOWER(TRIM(cst_gndr)) IN ('m', 'male') THEN 'Male'
        WHEN LOWER(TRIM(cst_gndr)) IN ('f', 'female') THEN 'Female'
        ELSE 'Unknown'
    END;




-- Check for NULLs or Negative Numbers
-- Cost should logically be non-negative and not null
-- Prevents incorrect financial/reporting calculations

SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;




-- Check for Invalid Dates
-- Since date here is in YYYYMMDD format, the LEN(sls_order_dt) != 8 condition is used to catch invalid date formats.

SELECT
    NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
   OR LEN(sls_order_dt) != 8



-- Check for Invalid Date Orders
-- sls_order_dt > sls_ship_dt = Order date cannot be after shipping date
-- sls_order_dt > sls_due_dt = Order date cannot be after due date
-- These conditions help identify data quality issues where the sequence of dates is incorrect (i.e., events happening before the order was even placed).

SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt



-- Check Data Consistency: Sales = Quantity * Price
-- Ensure values are valid (not NULL, zero, or negative)

SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
