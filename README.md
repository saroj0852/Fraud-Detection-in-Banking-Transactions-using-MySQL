# 🚨 Fraud Detection in Banking Transactions (MySQL)

This project demonstrates how to detect fraudulent banking transactions using **SQL queries**.  
By analyzing transaction patterns, it identifies suspicious behaviors such as:

- **Frequent High-Value Transactions** – multiple large transfers in a short period  
- **Duplicate Transactions** – repeated transactions with identical details  
- **Unusual Withdrawals** – odd-hour or multi-location activities  

Flagged transactions are stored in a separate table for further investigation.

---

## 🔹 Technologies
- MySQL 8.0  
- SQL (CTEs, subqueries, window functions)  
- CSV Import (`LOAD DATA INFILE`)  

---

## 🔹 Features
- Detects high-value fraud attempts  
- Identifies duplicate and unusual transactions  
- Stores suspicious records in `flaggedtransactions` table  
- Optimized queries for efficient fraud detection  

---

## 🔹 How to Run
1. Create the database:  
   ```sql
   CREATE DATABASE fraud_detection;
   USE fraud_detection;
Create the bank_transactions table (schema included in repo).

Place your dataset in MySQL’s Uploads folder:

arduino
Copy code
C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\
Import data using:

# 🚨 Fraud Detection in Banking Transactions (MySQL)

This project demonstrates how to detect fraudulent banking transactions using **SQL queries**.  
By analyzing transaction patterns, it identifies suspicious behaviors such as:

- **Frequent High-Value Transactions** – multiple large transfers in a short period  
- **Duplicate Transactions** – repeated transactions with identical details  
- **Unusual Withdrawals** – odd-hour or multi-location activities  

Flagged transactions are stored in a separate table for further investigation.

---

## 🔹 Technologies
- MySQL 8.0  
- SQL (CTEs, subqueries, window functions)  
- CSV Import (`LOAD DATA INFILE`)  

---

## 🔹 Features
- Detects high-value fraud attempts  
- Identifies duplicate and unusual transactions  
- Stores suspicious records in `flaggedtransactions` table  
- Optimized queries for efficient fraud detection  

---

## 🔹 How to Run
1. Create the database:  
   ```sql
   CREATE DATABASE fraud_detection;
   USE fraud_detection;
2. Create the bank_transactions table (schema included in repo).

3. Place your dataset in MySQL’s Uploads folder:
   ```sql
   C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\

4. Import data using:
To load the dataset into MySQL, run:
   ```sql
   LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/bank_transactions_data.csv'
   INTO TABLE bank_transactions
   FIELDS TERMINATED BY ','
   ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 ROWS;

5. Run fraud detection queries.

6. View suspicious results in flaggedtransactions.
