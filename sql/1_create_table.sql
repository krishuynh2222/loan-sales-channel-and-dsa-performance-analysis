CREATE DATABASE loan_sales_dsa_analysis;
USE loan_sales_dsa_analysis;

CREATE TABLE loan_disbursement (
    loan_id VARCHAR(10) PRIMARY KEY,
    customer_id INT,
    disbursement_date DATE,
    loan_amount INT,
    interest_rate DECIMAL(5,2),
    term_months INT,
    product_type_id INT,
    channel_id INT,
    dsa_id INT,
    region_id INT,
    loan_status VARCHAR(50),
    total_received DECIMAL(12,2),
    credit_score VARCHAR(20),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

CREATE TABLE dsa_info (
    dsa_id INT PRIMARY KEY,
    dsa_name VARCHAR(100),
    join_date DATE,
    region_id INT,
    status VARCHAR(20)
);

CREATE TABLE sales_channel (
    channel_id INT PRIMARY KEY,
    channel_name VARCHAR(100),
    channel_type VARCHAR(50)
);

CREATE TABLE region (
    region_id INT PRIMARY KEY,
    region_name VARCHAR(100),
    branch_code VARCHAR(50)
);

CREATE TABLE product_type (
    product_type_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    description TEXT,
    min_amount INT,
    max_amount INT,
    loan_term_from INT,
    loan_term_to INT,
    interest_rate_min DECIMAL(5,2),
    interest_rate_max DECIMAL(5,2)
);

SELECT * FROM loan_disbursement;

SELECT * FROM dsa_info;

SELECT * FROM sales_channel;

SELECT * FROM region;

SELECT * FROM product_type;

