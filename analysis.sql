USE customer_churn_analysis;

-- PROJECT 2: CUSTOMER CHURN & RETENTION ANALYSIS
-- Tools: MySQL + Power BI
-- Churn = subscriptions.status = 'Churned'
-- Revenue = Paid payment amount

-- 1. Overall Customer Performance
-- Total Customers, Active Customers, Churned Customers, Churn Rate
SELECT COUNT(*) AS 'Total Customers',
        (Select COUNT(*) FROM subscriptions s WHERE s.status = 'Active') AS 'Active Customers',
        (Select COUNT(*) FROM subscriptions s WHERE s.status = 'Churned') AS 'Churned Customers',
        ROUND(((Select COUNT(*) FROM subscriptions s WHERE s.status = 'Churned') 
        / COUNT(*)) * 100,2)
        AS 'Churn Rate'
FROM customers c;
 
-- 2. Churn by Subscription Plan
-- Plan, Total Customers, Churned Customers, Churn Rate
SELECT plan AS 'Plan',
    COUNT(*) AS 'Total Customers',
    SUM(
        CASE WHEN status = 'Churned' THEN 1 
        ELSE 0
        END
    ) AS 'Churned Customers',
    ROUND(( SUM(
        CASE WHEN status = 'Churned' THEN 1 
        ELSE 0
        END
    )/ COUNT(*) ) * 100, 2) AS 'Churn Rate'
FROM subscriptions
GROUP BY plan;

-- 3. Churn by Customer Segment
-- Segment, Customers, Churned Customers, Churn Rate
SELECT (
    CASE WHEN age BETWEEN 18 AND 25 THEN 'Youth'
    WHEN age BETWEEN 26 AND 40 THEN 'Adult'
    WHEN age BETWEEN 41 AND 60 THEN 'Middle-aged' 
    ELSE 'Senior'
    END) AS 'Age Segment', COUNT(*) AS 'Customers',
    SUM(
      CASE
      WHEN s.status = 'Churned' THEN 1
      ELSE 0
      END  
    ) AS 'Churned Customers',
    ROUND((SUM(
      CASE
      WHEN s.status = 'Churned' THEN 1
      ELSE 0
      END  
    )/ COUNT(*) * 100),2) AS 'Churn Rate'
FROM customers c
LEFT JOIN subscriptions s 
ON c.customer_id = s.customer_id
GROUP BY `Age Segment`;

-- 4. Churn by Tenure
-- Tenure Group, Customers, Churned Customers, Churn Rate
WITH Tenure_Table AS (SELECT (
    CASE WHEN end_date IS NULL THEN TIMESTAMPDIFF(Month, start_date, CURRENT_DATE())
    ELSE TIMESTAMPDIFF(Month, start_date, end_date)
    END
    ) AS 'Month', 
    status

 FROM subscriptions)

SELECT (
    CASE WHEN Month BETWEEN 0 and 6 THEN '0–6 Months'
    WHEN Month BETWEEN 7 and 12 THEN '7–12 Months'
    WHEN Month BETWEEN 13 and 24 THEN '13–24 Months'
    ELSE '25+ Months'
    END
  ) AS 'Tenure Group',
  COUNT(*) AS Customers, 
  SUM(case WHEN status = 'Churned' THEN 1 
  ELSE 0
  END) AS 'Churned Customers',
  ROUND( 
  SUM(case WHEN status = 'Churned' THEN 1 
  ELSE 0
  END) / count(*) * 100, 2) AS 'Churn Rate'

FROM Tenure_Table

GROUP BY `Tenure Group`;

-- 5. Revenue: Active vs Churned Customers
-- Customer Status, Customers, Revenue, Average Revenue

SELECT status, count(distinct p.customer_id) AS 'Customers', SUM(p.amount)  AS 'Revenue',
ROUND(SUM(p.amount)/ count(distinct p.customer_id) ,2) AS 'Average Revenue'
FROM subscriptions s
LEFT JOIN payments p 
ON s.customer_id = p.customer_id
WHERE p.payment_status = 'Paid'
GROUP BY s.status;

-- 6. Churn by Payment Method
-- Payment Method, Customers, Churned Customers, Churn Rate



SELECT payment_method,
       COUNT(DISTINCT p.customer_id) AS 'Customers', 

       COUNT(
        DISTINCT CASE WHEN s.status = 'Churned' THEN p.customer_id
        END
       ) AS 'Churned Customers',

       ROUND(COUNT(
        DISTINCT CASE WHEN s.status = 'Churned' THEN p.customer_id
        END
       ) / COUNT(DISTINCT p.customer_id) * 100,2) AS 'Churn Rate'

FROM 
payments p LEFT JOIN subscriptions s
    ON p.customer_id = s.customer_id
GROUP BY p.payment_method;

-- 7. Customer Activity vs Churn
-- Customer Status, Average Login Count, Average Support Tickets
SELECT s.status, COUNT(Distinct s.customer_id) AS 'Customers', ROUND(sum(ca.login_count)/ COUNT(Distinct s.customer_id),2) AS 'Average Login Count',
ROUND(sum(ca.support_tickets) / COUNT(Distinct s.customer_id), 2) AS 'Average Support Tickets'
FROM subscriptions s
LEFT JOIN customer_activity ca ON s.customer_id = ca.customer_id
GROUP by s.status;

-- 8. Support Tickets vs Churn
-- Support Ticket Group, Customers, Churned Customers, Churn Rate
WITH support_ticket_table AS(
    SELECT ca.customer_id, sum(support_tickets) AS 'support_tickets_total',
    COUNT(Distinct case 
        WHEN s.status = 'Churned' THEN ca.customer_id 
        ELSE NULL
        END) 
        AS 'Churned_Customers'
FROM customer_activity ca 
    LEFT JOIN subscriptions s 
        ON ca.customer_id = s.customer_id
GROUP BY ca.customer_id)


SELECT ( 
    CASE WHEN support_tickets_total = 0 THEN '0 Tickets'
    WHEN support_tickets_total BETWEEN 1 AND 2 THEN '1-2 Tickets'
    WHEN support_tickets_total BETWEEN 3 AND 5 THEN '3-5 Tickets'
    ELSE '6+ Tickets'
    END
    ) as "Support Ticket Group",
    COUNT(Distinct st.customer_id) as 'Customers',
    SUM(st.Churned_Customers) 
    AS 'Churned Customers', 
    round(SUM(st.Churned_Customers) / COUNT(DISTINCT st.customer_id) * 100, 2) AS 'Churn Rate'

FROM support_ticket_table st
GROUP BY `Support Ticket Group`;

