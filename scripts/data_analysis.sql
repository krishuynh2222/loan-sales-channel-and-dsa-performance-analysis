-- ================================
-- Loan Sales Channel & DSA Performance Analysis
-- ================================

USE loan_sales_dsa_analysis;

-- Total Loan KPIs (Overall system performance)
CREATE OR ALTER VIEW vw_total_loan_kpis AS
SELECT 
    COUNT(loan_id) AS total_loans,
    SUM(CAST(loan_amount AS BIGINT)) AS total_disbursed_amount,
    SUM(CAST(total_received AS BIGINT)) AS total_amount_received,
    SUM(CASE WHEN loan_status = 'Approved' THEN 1 ELSE 0 END) * 100.0 / COUNT(loan_id) AS approval_rate_percent
FROM loan_disbursement;

-- Monthly Loan Growth (Total disbursed amount by month)
CREATE OR ALTER VIEW vw_mom_growth AS
SELECT 
	FORMAT(disbursement_date, 'yyyy-MM') AS month,
	SUM(CAST(loan_amount AS BIGINT)) AS total_disbursed_amount 
FROM loan_disbursement 
GROUP BY FORMAT(disbursement_date, 'yyyy-MM');

-- Loan Summary by Month
CREATE OR ALTER VIEW vw_loan_by_month AS
SELECT 
    FORMAT(disbursement_date, 'yyyy-MM') AS month,
    COUNT(loan_id) AS total_loans,
    SUM(CAST(loan_amount AS BIGINT)) AS total_disbursed_amount,
    SUM(CAST(total_received AS BIGINT)) AS total_amount_received
FROM loan_disbursement
GROUP BY FORMAT(disbursement_date, 'yyyy-MM');

-- Total Disbursed Amount by Region  
CREATE OR ALTER VIEW vw_loan_amount_by_region AS
SELECT 
    r.region_name,
    SUM(CAST(ld.loan_amount AS BIGINT)) AS total_disbursed_amount
FROM loan_disbursement ld
LEFT JOIN dsa_info di ON ld.dsa_id = di.dsa_id
LEFT JOIN region r ON di.region_id = r.region_id
WHERE r.region_name IS NOT NULL
GROUP BY r.region_name;

-- Total Disbursed Amount by Product Type
CREATE OR ALTER VIEW vw_loan_amount_by_product AS
SELECT 
    p.product_name ,
    COUNT(ld.loan_id) AS total_loans,
    SUM(CAST(ld.loan_amount AS BIGINT)) AS total_disbursed_amount,
    SUM(CAST(ld.total_received AS BIGINT)) AS total_amount_received
FROM loan_disbursement ld
LEFT JOIN product_type p ON ld.product_type_id = p.product_type_id
GROUP BY p.product_name ;



-- Loan Performance by Sales Channel
CREATE OR ALTER VIEW vw_loan_amount_by_channel AS
SELECT 
	sc.channel_name,
	sc.channel_type,
	COUNT(ld.loan_id) AS total_loans,
	SUM(CAST(ld.loan_amount AS BIGINT)) AS total_disbursed_amount,
	SUM(CAST(ld.total_received AS BIGINT)) AS total_amount_received
FROM loan_disbursement ld
LEFT JOIN sales_channel sc ON ld.channel_id = sc.channel_id 
GROUP BY sc.channel_name, sc.channel_type;



-- DSA (Sales Agent) Performance 
CREATE OR ALTER VIEW vw_dsa_performance AS
SELECT 
	di.dsa_id,
    di.dsa_name,
    di.status AS dsa_status,
    COUNT(ld.loan_id) AS total_loans,
    SUM(CAST(ld.loan_amount AS BIGINT)) AS total_disbursed_amount,
    SUM(CAST(ld.total_received AS BIGINT)) AS total_amount_received
FROM loan_disbursement ld
LEFT JOIN dsa_info di ON ld.dsa_id = di.dsa_id
GROUP BY di.dsa_id, di.dsa_name, di.status;

-- Top 5 DSA (Sales Agents) by Total Disbursed Amount
CREATE OR ALTER VIEW vw_top5_dsa_by_amount AS
SELECT TOP 5 
    di.dsa_id,
    di.dsa_name,
    SUM(CAST(ld.loan_amount AS BIGINT)) AS total_disbursed_amount
FROM loan_disbursement ld
LEFT JOIN dsa_info di ON ld.dsa_id = di.dsa_id
GROUP BY di.dsa_id, di.dsa_name
ORDER BY total_disbursed_amount DESC;

-- Stored Procedure - Quick KPIs Summary
CREATE OR ALTER PROCEDURE sp_get_total_kpis
AS
BEGIN
	SELECT 
		COUNT(loan_id) AS total_loans,
		SUM(CAST(loan_amount AS BIGINT)) AS total_disbursed_amount,
		SUM(CAST(total_received AS BIGINT)) AS total_amount_received,
		SUM(CASE 
				WHEN loan_status = 'Approved' THEN 1 ELSE 0 
			END) * 100.0 / COUNT(loan_id) AS approval_rate_percent
	FROM loan_disbursement;
END





