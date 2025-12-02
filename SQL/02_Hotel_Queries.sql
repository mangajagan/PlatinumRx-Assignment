/* 1) For every user, get the user_id and last booked room_no */
SELECT u.user_id, b.room_no, b.booking_date
FROM users u
JOIN bookings b ON u.user_id = b.user_id
WHERE b.booking_date = (
    SELECT MAX(b2.booking_date)
    FROM bookings b2
    WHERE b2.user_id = u.user_id
);



/* 2) Get booking_id and total billing amount of every booking created in November 2021 */
SELECT bc.booking_id,
       SUM(i.item_rate * bc.item_quantity) AS total_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
JOIN bookings b ON bc.booking_id = b.booking_id
WHERE b.booking_date >= '2021-11-01'
  AND b.booking_date <  '2021-12-01'
GROUP BY bc.booking_id;



/* 3) Get bill_id and bill amount of all the bills raised in October 2021 having bill amount > 1000 */
SELECT bc.bill_id,
       SUM(i.item_rate * bc.item_quantity) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE bc.bill_date >= '2021-10-01'
  AND bc.bill_date <  '2021-11-01'
GROUP BY bc.bill_id
HAVING SUM(i.item_rate * bc.item_quantity) > 1000;



/* 4) Most ordered and least ordered item of each month of year 2021 */
WITH monthly_qty AS (
    SELECT DATE_FORMAT(bc.bill_date, '%Y-%m') AS month,
           bc.item_id,
           SUM(bc.item_quantity) AS qty
    FROM booking_commercials bc
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY month, bc.item_id
),
ranked AS (
    SELECT month, item_id, qty,
           RANK() OVER (PARTITION BY month ORDER BY qty DESC) AS rnk_desc,
           RANK() OVER (PARTITION BY month ORDER BY qty ASC) AS rnk_asc
    FROM monthly_qty
)
SELECT month, item_id, qty,
       CASE 
           WHEN rnk_desc = 1 THEN 'Most Ordered'
           WHEN rnk_asc  = 1 THEN 'Least Ordered'
       END AS category
FROM ranked
WHERE rnk_desc = 1 OR rnk_asc = 1
ORDER BY month;



/* 5) Customers with the second highest bill value of each month of year 2021 */
WITH customer_month_bill AS (
    SELECT DATE_FORMAT(bc.bill_date, '%Y-%m') AS month,
           b.user_id,
           SUM(i.item_rate * bc.item_quantity) AS total_amount
    FROM booking_commercials bc
    JOIN bookings b ON bc.booking_id = b.booking_id
    JOIN items i ON bc.item_id = i.item_id
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY month, b.user_id
),
ranked AS (
    SELECT month, user_id, total_amount,
           DENSE_RANK() OVER (PARTITION BY month ORDER BY total_amount DESC) AS rnk
    FROM customer_month_bill
)
SELECT month, user_id, total_amount
FROM ranked
WHERE rnk = 2;

