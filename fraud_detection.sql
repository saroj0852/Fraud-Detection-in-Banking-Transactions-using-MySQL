-- Create database
CREATE DATABASE fraud_detection;
USE fraud_detection;

-- Create table
DROP TABLE IF EXISTS bank_transactions;
CREATE TABLE bank_transactions (
    TransactionID VARCHAR(50) PRIMARY KEY,
    AccountID VARCHAR(50),
    TransactionAmount DECIMAL(15,2),
    TransactionDate DATETIME,
    TransactionType VARCHAR(20),
    Location VARCHAR(100),
    DeviceID VARCHAR(50),
    IP_Address VARCHAR(45), 
    MerchantID VARCHAR(50),
    Channel VARCHAR(30),
    CustomerAge INT,
    CustomerOccupation VARCHAR(100),
    TransactionDuration INT,  
    LoginAttempts INT,
    AccountBalance DECIMAL(15,2),
    PreviousTransactionDate DATETIME
);

-- Load CSV data (MySQL LOAD DATA)
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/bank_transactions_data.csv'
INTO TABLE bank_transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Check data
SELECT * FROM bank_transactions LIMIT 10;

-- Checking Missing Values
SELECT 
    SUM(TransactionID IS NULL) AS missing_transactionid,
    SUM(AccountID IS NULL) AS missing_accountid,
    SUM(TransactionAmount IS NULL) AS missing_transactionamount,
    SUM(TransactionDate IS NULL) AS missing_transactiondate,
    SUM(TransactionType IS NULL) AS missing_transactiontype
FROM bank_transactions;

-- Fraud Detection Queries

-- 1. Frequent High-Value Transactions
WITH highvaluetx AS (
    SELECT t1.AccountID, t1.TransactionDate, t1.TransactionAmount,
           (SELECT COUNT(*) 
            FROM bank_transactions t2 
            WHERE t2.AccountID = t1.AccountID
              AND t2.TransactionDate BETWEEN DATE_SUB(t1.TransactionDate, INTERVAL 1 HOUR) AND t1.TransactionDate) AS tx_count,
           (SELECT SUM(t2.TransactionAmount)
            FROM bank_transactions t2 
            WHERE t2.AccountID = t1.AccountID
              AND t2.TransactionDate BETWEEN DATE_SUB(t1.TransactionDate, INTERVAL 1 HOUR) AND t1.TransactionDate) AS total_value
    FROM bank_transactions t1
)
SELECT AccountID, TransactionDate, TransactionAmount
FROM highvaluetx
WHERE tx_count > 3 AND total_value > 5000;

-- 2. Duplicate Transactions
WITH duplicatetx AS (
    SELECT TransactionID, AccountID, TransactionAmount, TransactionDate, MerchantID,
           COUNT(*) OVER (PARTITION BY AccountID, TransactionAmount, MerchantID, TransactionDate) AS duplicate_count
    FROM bank_transactions
)
SELECT * FROM duplicatetx WHERE duplicate_count > 1;

-- 3. Unusual Withdrawals
WITH oddhourtx AS (
    SELECT t1.TransactionID, t1.AccountID, t1.TransactionDate, t1.TransactionType, t1.Location, t1.TransactionAmount,
           HOUR(t1.TransactionDate) AS tx_hour,
           (SELECT COUNT(DISTINCT t2.Location)
            FROM bank_transactions t2
            WHERE t2.AccountID = t1.AccountID
              AND t2.TransactionDate BETWEEN DATE_SUB(t1.TransactionDate, INTERVAL 24 HOUR) AND t1.TransactionDate) AS location_changes
    FROM bank_transactions t1
)
SELECT * FROM oddhourtx 
WHERE (tx_hour < 6 OR tx_hour > 22) OR location_changes > 2;

-- Store flagged transactions
CREATE TABLE flaggedtransactions AS
SELECT AccountID, TransactionDate, TransactionAmount, 'high_value' AS fraud_type
FROM (
    SELECT t1.AccountID, t1.TransactionDate, t1.TransactionAmount,
           (SELECT COUNT(*) 
            FROM bank_transactions t2 
            WHERE t2.AccountID = t1.AccountID
              AND t2.TransactionDate BETWEEN DATE_SUB(t1.TransactionDate, INTERVAL 1 HOUR) AND t1.TransactionDate) AS tx_count,
           (SELECT SUM(t2.TransactionAmount)
            FROM bank_transactions t2 
            WHERE t2.AccountID = t1.AccountID
              AND t2.TransactionDate BETWEEN DATE_SUB(t1.TransactionDate, INTERVAL 1 HOUR) AND t1.TransactionDate) AS total_value
    FROM bank_transactions t1
) hv
WHERE tx_count > 3 AND total_value > 5000

UNION ALL
SELECT AccountID, TransactionDate, TransactionAmount, 'duplicate' AS fraud_type
FROM (
    SELECT TransactionID, AccountID, TransactionAmount, TransactionDate, MerchantID,
           COUNT(*) OVER (PARTITION BY AccountID, TransactionAmount, MerchantID, TransactionDate) AS duplicate_count
    FROM bank_transactions
) dup
WHERE duplicate_count > 1

UNION ALL
SELECT AccountID, TransactionDate, TransactionAmount, 'odd_hour' AS fraud_type
FROM (
    SELECT t1.TransactionID, t1.AccountID, t1.TransactionDate, t1.TransactionAmount,
           HOUR(t1.TransactionDate) AS tx_hour,
           (SELECT COUNT(DISTINCT t2.Location)
            FROM bank_transactions t2
            WHERE t2.AccountID = t1.AccountID
              AND t2.TransactionDate BETWEEN DATE_SUB(t1.TransactionDate, INTERVAL 24 HOUR) AND t1.TransactionDate) AS location_changes
    FROM bank_transactions t1
) odd
WHERE (tx_hour < 6 OR tx_hour > 22) OR location_changes > 2;

-- Final check
SELECT * FROM flaggedtransactions;
