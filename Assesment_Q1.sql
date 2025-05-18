SELECT 
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,  -- Combine first/last names
    COUNT(DISTINCT s.id) AS savings_count,
    COUNT(DISTINCT p.id) AS investment_count,
    SUM(s.confirmed_amount / 100) AS total_deposits  -- Convert kobo to Naira
FROM 
    users_customuser u
    JOIN savings_savingsaccount s ON u.id = s.owner_id
    JOIN plans_plan ps ON s.plan_id = ps.id AND ps.is_regular_savings = 1
    JOIN plans_plan p ON u.id = p.owner_id AND p.is_a_fund = 1
WHERE 
    s.confirmed_amount > 0
GROUP BY 
    u.id, u.first_name, u.last_name  
HAVING 
    savings_count >= 1 AND investment_count >= 1
ORDER BY 
    total_deposits DESC;