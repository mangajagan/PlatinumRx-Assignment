/* 1. Revenue from each sales channel in a given year */
SELECT sales_channel,
       SUM(amount) AS revenue
FROM clinic_sales
WHERE YEAR(datetime)=2021
GROUP BY sales_channel;

/* 2. Top 10 most valuable customers */
SELECT uid,
       SUM(amount) AS total_spent
FROM clinic_sales
WHERE YEAR(datetime)=2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;

/* 3. Month-wise revenue, expense, profit, status */
WITH r AS (
    SELECT DATE_FORMAT(datetime,'%Y-%m') AS month,
           SUM(amount) AS revenue
    FROM clinic_sales
    WHERE YEAR(datetime)=2021
    GROUP BY month
),
e AS (
    SELECT DATE_FORMAT(datetime,'%Y-%m') AS month,
           SUM(amount) AS expense
    FROM expenses
    WHERE YEAR(datetime)=2021
    GROUP BY month
)
SELECT r.month,
       r.revenue,
       e.expense,
       r.revenue - e.expense AS profit,
       CASE WHEN r.revenue > e.expense THEN 'profitable'
            ELSE 'not-profitable' END AS status
FROM r
LEFT JOIN e ON r.month=e.month;

/* 4. Most profitable clinic per city per month */
WITH profit AS (
    SELECT c.city,
           cs.cid,
           DATE_FORMAT(cs.datetime,'%Y-%m') AS month,
           SUM(cs.amount)
           - COALESCE((SELECT SUM(amount) FROM expenses e 
               WHERE e.cid=cs.cid
               AND DATE_FORMAT(e.datetime,'%Y-%m') = DATE_FORMAT(cs.datetime,'%Y-%m')
           ),0) AS profit
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    WHERE YEAR(cs.datetime)=2021
    GROUP BY c.city, cs.cid, month
),
ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY city, month ORDER BY profit DESC) AS rnk
    FROM profit
)
SELECT city, month, cid, profit
FROM ranked
WHERE rnk=1;

/* 5. Second least profitable clinic per state per month */
WITH profit AS (
    SELECT c.state,
           cs.cid,
           DATE_FORMAT(cs.datetime,'%Y-%m') AS month,
           SUM(cs.amount)
           - COALESCE((SELECT SUM(amount) FROM expenses e 
               WHERE e.cid=cs.cid
               AND DATE_FORMAT(e.datetime,'%Y-%m') = DATE_FORMAT(cs.datetime,'%Y-%m')
           ),0) AS profit
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    WHERE YEAR(cs.datetime)=2021
    GROUP_BY c.state, cs.cid, month
),
ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY state, month ORDER BY profit ASC) AS rnk
    FROM profit
)
SELECT state, month, cid, profit
FROM ranked
WHERE rnk=2;
