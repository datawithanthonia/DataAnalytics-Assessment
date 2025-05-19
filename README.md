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

## Verification

```sql
-- Spot-check a high-frequency customer
SELECT 
    DATE_FORMAT(transaction_date, '%Y-%m') AS month,
    COUNT(*) AS transactions
FROM savings_savingsaccount
WHERE owner_id = '0257625a02344b239b41e1cbe60ef080'
GROUP BY month
ORDER BY month DESC;
```
## Question 3: Account Inactivity Alert

### **Approach**:
1. Joined `plans_plan` with `savings_savingsaccount` to track account activity.
2. Used `COALESCE()` to check for both `transaction_date` and `last_charge_date`.
3. Calculated inactivity duration with `DATEDIFF(CURDATE(), ...)`.
4. Applied filters to select:
   - Accounts that are still active (`is_account_deleted = 0`)
   - Accounts with no activity in over 365 days

### **Challenges & Solutions**:
- **Missing Transactions**: Implemented `LEFT JOIN` to include accounts with no recorded transactions.
- **Date Conflicts**: Applied `MAX(COALESCE(...))` to prioritize the most recent activity date.
- **Account Types**: Used `CASE WHEN` to clearly label savings vs investment plans.

### **Verification**:
```sql
-- Spot-check inactive accounts
SELECT * FROM savings_savingsaccount 
WHERE plan_id = '002b48c9f6ec48fdb586bd019a85aa9a'
ORDER BY transaction_date DESC
LIMIT 5;
```
## Question 4: Customer Lifetime Value (CLV)

### **Approach**:
1. Calculated the following metrics:
   - **Tenure**: `TIMESTAMPDIFF(MONTH, date_joined, NOW())`
   - **Average Transaction Value**: `AVG(confirmed_amount / 100)` (converting from kobo to Naira)
   - **CLV Formula**:
     \[
     \text{CLV} = \left( \frac{\text{Transactions}}{\text{Tenure}} \right) \times 12 \times \left(0.1\% \times \text{Avg Transaction Value} \right)
     \]

### **Challenges & Solutions**:
- **New Customers**: Applied `HAVING tenure_months > 0` to filter out users with insufficient tenure.
- **Kobo Conversion**: Divided all monetary amounts by 100 to ensure accurate conversion from kobo to Naira.
- **Edge Cases**: Used `NULLIF()` to avoid division-by-zero errors in tenure or transaction counts.

### **Verification**:
```sql
-- Spot-check a high-CLV customer
SELECT 
    confirmed_amount / 100 AS amount_naira,
    transaction_date 
FROM savings_savingsaccount 
WHERE owner_id = '0257625a02344b239b41e1cbe60ef080'
ORDER BY transaction_date DESC;


