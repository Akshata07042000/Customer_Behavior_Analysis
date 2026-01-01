USE customer_analysis;
SELECT * FROM customers LIMIT 10;

-- Total Revenue of male and female customers-- 
SELECT gender, SUM(purchase_amount) AS revenue
FROM customers
GROUP BY gender;

-- Which customers used a discount but still spent more than average purchase amount-- 
SELECT customer_id , purchase_amount
FROM customers
WHERE discount_applied = 'yes' AND purchase_amount >= (SELECT AVG(purchase_amount)FROM customers);

-- Which are the top 5 products with higher average review ratings  --
SELECT category, item_purchased , ROUND(AVG(review_rating),2) AS 'product average rating'
FROM customers
GROUP BY category, item_purchased
ORDER BY avg(review_rating) desc
LIMIT 5;

-- Compare the average purchase amounts between standard and express shipping 
SELECT shipping_type, ROUND(AVG(purchase_amount),2)
FROM customers
WHERE shipping_type IN ('express', 'standard')
GROUP BY shipping_type;

-- do subscribed customers spends more? compare average spend and total revenue between subcriber and non subscriber 
SELECT subscription_status, 
COUNT(customer_id) as  'no_of_customer',
ROUND(AVG(purchase_amount),2) as 'average spent',
SUM(purchase_amount) as 'total revenue'
FROM customers
GROUP BY subscription_status
ORDER BY AVG(purchase_amount), SUM(purchase_amount) desc;

-- Which 5 products have the highest percentage of purchases with discount applied? 
SELECT item_purchased ,ROUND(100 * SUM(CASE WHEN discount_applied = 'yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS discount_percentage 
FROM customers
GROUP BY item_purchased
ORDER BY discount_percentage desc
LIMIT 5;

-- Segment customers into new, returning, and loyal based on their total numbers of previous purchases , and show 
-- the count of each segment 
WITH customer_type AS (
SELECT customer_id , previous_purchases,
CASE
     WHEN previous_purchases = 1 THEN 'New'
     WHEN Previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
     ELSE 'loyal'
     END AS 'customer_segment'
FROM customers 
)
SELECT customer_segment , COUNT(*) AS ' number of customers' 
FROM customer_type
GROUP BY customer_segment;

-- Which are the top 3 most purchased products within each category?
WITH item_counts AS (
SELECT category,
item_purchased, 
COUNT(customer_id) as total_orders,
ROW_NUMBER() over(partition by category ORDER BY COUNT(customer_id) DESC ) as item_rank
FROM customers
GROUP BY category , item_purchased
)
SELECT item_rank, category, item_purchased, total_orders
from item_counts
where item_rank <= 3;

-- Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe? -- 
SELECT subscription_status , COUNT(customer_id) as repeat_buyers
FROM customers
WHERE previous_purchases > 5 
GROUP BY subscription_status;

-- What is the revenue contribution of each age group ?
SELECT age_group, SUM(purchase_amount) as total_revenue
FROM customers 
GROUP BY age_group
ORDER BY total_revenue DESC;


