# Data Analysis Report

This document outlines the SQL approaches, decisions, and validations made while answering data assessment by cowrywise
---

## Question 1: High-Value Customers with Multiple Products

### **Approach**
1. Joined `users_customuser`, `savings_savingsaccount`, and `plans_plan` tables.
2. Filtered for:
   - Funded savings plans (`is_regular_savings = 1 AND confirmed_amount > 0`)
   - Funded investment plans (`is_a_fund = 1`)
3. Converted amounts from kobo to Naira (`/ 100`).
4. Counted distinct plans per type per customer.
5. Sorted by total deposits in descending order.

### **Key Decisions**
- Used `CONCAT(first_name, ' ', last_name)` as the `name` column was `NULL`.
- Excluded unfunded plans using `confirmed_amount > 0`.
- Verified currency conversion by dividing kobo by 100.

### **Challenges & Solutions**
- **Duplicate amounts**: Used `DISTINCT` in counts to avoid double-counting.
- **Data validation**: Spot-checked conversions with sample queries.
- **Join logic**: Tested multiple strategies for accurate plan matching.

---

## Question 2: Transaction Frequency Analysis

### **Approach**
1. Created a CTE (`monthly_transactions`) to count transactions per customer per month.
2. Grouped by month using `DATE_FORMAT(transaction_date, '%Y-%m')`.
3. Classified customers as:
   - **High Frequency**: ≥10 avg transactions/month
   - **Medium Frequency**: 3–9 avg transactions/month
   - **Low Frequency**: ≤2 avg transactions/month
4. Rounded averages to 1 decimal place for readability.

### **Key Decisions**
- Filtered out `NULL` transaction dates.
- Used `COUNT(DISTINCT customer_id)` to avoid duplication.
- Sorted results by frequency category (High > Medium > Low).

### **Verification**
```sql
-- Spot-check a high-frequency customer
SELECT 
    DATE_FORMAT(transaction_date, '%Y-%m') AS month,
    COUNT(*) AS transactions
FROM savings_savingsaccount
WHERE owner_id = '0257625a02344b239b41e1cbe60ef080'
GROUP BY month
ORDER BY month DESC;
