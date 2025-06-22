-- USE DATABASE
USE loan_sales_dsa_analysis;


-- ================================
-- Section 1: Data Checks on loan_disbursement
-- ================================

-- 1. View all loan disbursement data 
SELECT * 
FROM loan_disbursement;

-- 2. Check for duplicated loan_id values
SELECT loan_id, COUNT(*) AS record_count
FROM loan_disbursement
GROUP BY loan_id
HAVING COUNT(*) > 1;

-- 3. Check for duplicated or missing dsa_id values
SELECT dsa_id, COUNT(*) AS record_count
FROM loan_disbursement 
GROUP BY dsa_id  
HAVING COUNT(*) > 1 OR dsa_id IS NULL;

-- 4. Fully Paid loans that received less than the loaned amount
SELECT *
FROM loan_disbursement
WHERE loan_status = 'Fully Paid' AND total_received < loan_amount;

-- 5. Identify records with updated_at in the future
SELECT *
FROM loan_disbursement
WHERE TRY_CONVERT(DATETIME, updated_at, 1) > '2025-12-31';

-- 6. Detect invalid interest rate values
SELECT loan_id, interest_rate
FROM loan_disbursement
WHERE interest_rate <= 0 OR interest_rate > 100;

-- 7. Detect negative loan_amount or total_received values
SELECT loan_id, loan_amount, total_received
FROM loan_disbursement
WHERE loan_amount < 0 OR total_received < 0;

-- 8. Check for unexpected loan_status values
SELECT DISTINCT loan_status
FROM loan_disbursement
WHERE loan_status NOT IN ('Approved', 'Charged-off');


-- ================================
-- Section 2: Data Checks on dsa_info
-- ================================

-- 9. Check for missing values in dsa_info
SELECT * 
FROM dsa_info 
WHERE dsa_id IS NULL 
   OR dsa_name IS NULL 
   OR join_date IS NULL 
   OR region_id IS NULL 
   OR status IS NULL;

-- 10. Check for duplicated dsa_id values
SELECT dsa_id, COUNT(*) AS record_count
FROM dsa_info 
GROUP BY dsa_id 
HAVING COUNT(*) > 1;

-- 11. View all distinct DSA status values
SELECT DISTINCT status 
FROM dsa_info;

-- 12. Validate region_id against region table
SELECT region_id 
FROM dsa_info 
WHERE region_id NOT IN (
  SELECT region_id 
  FROM region
);
