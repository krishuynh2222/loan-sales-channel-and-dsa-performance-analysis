USE loan_sales_dsa_analysis;

-- ===========================
-- Clean loan_disbursement table
-- ===========================

-- 1. Remove records with missing DSA agents
DELETE FROM loan_disbursement
WHERE dsa_id IS NULL;

-- 2. Standardize loan_status values
UPDATE loan_disbursement
SET loan_status = 'Approved'
WHERE loan_status IN ('Apprvd', 'fullpaid');

UPDATE loan_disbursement
SET loan_status = 'Unknown'
WHERE loan_status IS NULL OR TRIM(loan_status) = '';

-- 3. Standardize credit_score values
UPDATE loan_disbursement
SET credit_score = 'Medium'
WHERE TRIM(credit_score) = 'M';

UPDATE loan_disbursement
SET credit_score = 'High'
WHERE TRIM(LOWER(credit_score)) = 'high';

-- 4. Remove future-dated updated_at entries
DELETE FROM loan_disbursement
WHERE TRY_CONVERT(DATETIME, updated_at, 1) > '2025-12-31';

-- 5. Identify suspicious loan amounts (for manual review)
SELECT * 
FROM loan_disbursement
WHERE loan_amount <= 0 OR loan_amount > 500000000;

-- 6. Convert string-based date columns to date formats (for future ETL use)
SELECT 
  CAST(disbursement_date AS DATE) AS disbursed_date_cleaned,
  CAST(created_at AS DATETIME) AS created_datetime
FROM loan_disbursement;

-- 7. Detect invalid or future disbursement dates
SELECT loan_id, disbursement_date
FROM loan_disbursement
WHERE TRY_CAST(disbursement_date AS DATE) IS NULL
   OR disbursement_date > GETDATE();


-- ===========================
-- Clean dsa_info table
-- ===========================

-- 8. Standardize status values
UPDATE dsa_info
SET status = 'Active'
WHERE LOWER(TRIM(status)) IN ('actv');

UPDATE dsa_info 
SET status = 'Left'
WHERE LOWER(TRIM(status)) IN ('left', 'lefft', 'lft');

-- 9. Replace missing dsa_name with placeholder
UPDATE dsa_info
SET dsa_name = 'Unknown DSA'
WHERE dsa_name IS NULL;

-- 10. Set default join_date if missing
UPDATE dsa_info
SET join_date = '2022-01-01'
WHERE join_date IS NULL;

-- 11. Replace missing status with 'Unknown'
UPDATE dsa_info
SET status = 'Unknown'
WHERE status IS NULL;

-- 12. Replace missing region_id with fallback value (-1)
UPDATE dsa_info
SET region_id = -1
WHERE region_id IS NULL;
