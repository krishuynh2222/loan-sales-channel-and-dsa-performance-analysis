-- ================================
-- Loan Sales Channel & DSA Performance Analysis
-- ================================

USE loan_sales_dsa_analysis;


-- 1.1 Total Loan KPIs
CREATE OR ALTER VIEW vw_total_loan_kpis AS
SELECT 
    COUNT(loan_id) AS total_loans,
    SUM(CAST(loan_amount AS BIGINT)) AS total_disbursed_amount,
    SUM(CAST(total_received AS BIGINT)) AS total_amount_received,
    SUM(CASE WHEN loan_status = 'Approved' THEN 1 ELSE 0 END) * 100.0 / COUNT(loan_id) AS approval_rate_percent
FROM loan_disbursement;


-- 1.2 MoM Growth (Loan Amount)
CREATE OR ALTER VIEW vw_mom_growth AS
SELECT 
	FORMAT(disbursement_date, 'yyyy-MM') AS month,
	SUM(CAST(loan_amount AS BIGINT)) AS total_disbursed_amount 
FROM loan_disbursement 
GROUP BY FORMAT(disbursement_date, 'yyyy-MM');


-- VIEW 3: Loan Amount by Region
CREATE OR ALTER VIEW vw_loan_amount_by_region AS
SELECT 
    COALESCE(r.region_name, 'Unknown Region') AS region_name,
    SUM(CAST(ld.loan_amount AS BIGINT)) AS total_disbursed_amount
FROM loan_disbursement ld
LEFT JOIN dsa_info di ON ld.dsa_id = di.dsa_id
LEFT JOIN region r ON di.region_id = r.region_id
GROUP BY COALESCE(r.region_name, 'Unknown Region');


-- VIEW 4: Loan Amount by Sales Channel
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


-- VIEW 5: DSA Performance Ranking
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


-- VIEW 6: Product & Region Performance
CREATE OR ALTER VIEW vw_product_region_performance AS
SELECT 
    COALESCE(r.region_name, 'Unknown Region') AS region_name,
    pt.product_name,
    SUM(CAST(ld.loan_amount AS BIGINT)) AS total_disbursed_amount,
    COUNT(ld.loan_id) AS total_loans
FROM loan_disbursement ld
LEFT JOIN dsa_info di ON ld.dsa_id = di.dsa_id
LEFT JOIN region r ON di.region_id = r.region_id
LEFT JOIN product_type pt ON ld.product_type_id = pt.product_type_id
GROUP BY COALESCE(r.region_name, 'Unknown Region'), pt.product_name;


-- STORE PROCEDURE 
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

SELECT * FROM vw_total_loan_kpis;
SELECT * FROM vw_mom_growth;
SELECT * FROM vw_loan_amount_by_region;
SELECT * FROM vw_loan_amount_by_channel;
SELECT * FROM vw_dsa_performance;
SELECT * FROM vw_product_region_performance;

EXEC sp_get_total_kpis;


