-- Account Inactivity Alert: Find accounts with no transactions in the last 365 days
SELECT 
    p.id AS plan_id,
    p.owner_id,
    CASE 
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
        ELSE 'Other'
    END AS type,
    MAX(COALESCE(s.transaction_date, p.last_charge_date)) AS last_transaction_date,
    DATEDIFF(CURDATE(), MAX(COALESCE(s.transaction_date, p.last_charge_date))) AS inactivity_days
FROM 
    plans_plan p
    LEFT JOIN savings_savingsaccount s ON p.id = s.plan_id
WHERE 
    p.is_deleted = 0  
GROUP BY 
    p.id, p.owner_id, p.is_regular_savings, p.is_a_fund
HAVING 
    last_transaction_date IS NOT NULL
    AND inactivity_days > 365  
ORDER BY 
    inactivity_days DESC;