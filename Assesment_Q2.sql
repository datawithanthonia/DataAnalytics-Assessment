-- Transaction Frequency Analysis
WITH monthly_transactions AS (
    SELECT 
        u.id AS customer_id,
        DATE_FORMAT(s.transaction_date, '%Y-%m') AS month,
        COUNT(*) AS transactions_count
    FROM 
        users_customuser u
        JOIN savings_savingsaccount s ON u.id = s.owner_id
    WHERE 
        s.transaction_date IS NOT NULL
    GROUP BY 
        u.id, DATE_FORMAT(s.transaction_date, '%Y-%m')
),
customer_avg AS (
    SELECT 
        customer_id,
        AVG(transactions_count) AS avg_transactions
    FROM 
        monthly_transactions
    GROUP BY 
        customer_id
)

SELECT 
    CASE 
        WHEN avg_transactions >= 10 THEN 'High Frequency'
        WHEN avg_transactions >= 3 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    COUNT(customer_id) AS customer_count,
    ROUND(AVG(avg_transactions), 1) AS avg_transactions_per_month
FROM 
    customer_avg
GROUP BY 
    frequency_category
ORDER BY 
    CASE frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        ELSE 3
    END;