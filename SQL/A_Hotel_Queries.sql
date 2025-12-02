/* 1. Last booked room for every user */
SELECT u.user_id, b.room_no
FROM users u
JOIN bookings b ON u.user_id = b.user_id
WHERE b.booking_date = (
    SELECT MAX(b2.booking_date)
    FROM bookings b2
    WHERE b2.user_id = u.user_id
);

/* 2. Total billing amount for bookings created in November 2021 */
SELECT bc.booking_id,
       SUM(i.item_rate * bc.item_quantity) AS total_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
JOIN bookings b ON bc.booking_id = b.booking_id
WHERE b.booking_date >= '2021-11-01'
  AND b.booking_date <  '2021-12-01'
GROUP BY bc.booking_id;

/* 3. Bills raised in October 2021 with amount > 1000 */
SELECT bc.bill_id,
       SUM(i.item_rate * bc.item_quantity) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE bc.bill_date >= '2021-10-01'
  AND bc.bill_date <  '2021-11-01'
GROUP BY bc.bill_id
HAVING SUM(i.item_rate * bc.item_quantity) > 1000;

/* 4. Most & least ordered item per month (2021) */
WITH monthly AS (
    SELECT DATE_FORMAT(bc.bill_date, '%Y-%m') AS month,
           bc.item_id,
           SUM(bc.item_quantity) AS qty
    FROM booking_commercials bc
    WHERE YEAR(bc.bill_date)=2021
    GROUP BY month, bc.item_id
),
ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY month ORDER BY qty DESC) AS most_rank,
        RANK() OVER (PARTITION BY month ORDER BY qty ASC) AS least_rank
    FROM monthly
)
SELECT month, item_id, qty,
       CASE WHEN most_rank=1 THEN 'Most Ordered'
            WHEN least_rank=1 THEN 'Least Ordered' END AS status
FROM ranked
WHERE most_rank=1 OR least_rank=1;

/* 5. Second highest bill customer per month (2021) */
WITH bills AS (
    SELECT DATE_FORMAT(bc.bill_date,'%Y-%m') AS month,
           b.user_id,
           SUM(i.item_rate * bc.item_quantity) AS amount
    FROM booking_commercials bc
    JOIN bookings b ON bc.booking_id = b.booking_id
    JOIN items i ON bc.item_id = i.item_id
    WHERE YEAR(bc.bill_date)=2021
    GROUP BY month, b.user_id
),
ranked AS (
    SELECT *,
        DENSE_RANK() OVER(PARTITION BY month ORDER BY amount DESC) AS rnk
    FROM bills
)
SELECT month, user_id, amount
FROM ranked
WHERE rnk=2;
