-- Customer Lifetime Value (CLV) Estimation
SELECT 
    u.id AS customer_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    -- Calculate tenure in months
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
    -- Count all transactions
    COUNT(s.id) AS total_transactions,
    -- Calculate estimated CLV: (transactions/tenure)*12*(0.1% of avg transaction value)
    ROUND(
        (COUNT(s.id) / NULLIF(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 0)) * 
        12 * 
        (0.001 * AVG(s.confirmed_amount/100)),  -- 0.1% of average transaction in Naira
        2
    ) AS estimated_clv
FROM 
    users_customuser u
    JOIN savings_savingsaccount s ON u.id = s.owner_id
WHERE 
    s.confirmed_amount > 0  -- Only funded transactions
    AND u.date_joined IS NOT NULL  -- Customers with known join dates
GROUP BY 
    u.id, u.first_name, u.last_name, u.date_joined
HAVING 
    tenure_months > 0  -- Exclude customers who joined this month
ORDER BY 
    estimated_clv DESC;