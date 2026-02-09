USE magist;
/* 
2.1. In relation to the products:

1. What categories of tech products does Magist have?
2. How many products of these tech categories have been sold (within the time window of the database snapshot)? 
3. What percentage does that represent from the overall number of products sold?
4. What’s the average price of the products being sold?
5. Are expensive tech products popular? *

* TIP: Look at the function CASE WHEN to accomplish this task. 
*/

# 1. What categories of tech products does Magist have? Tech Categories: audio, electronics, computers_accessories, computers, tablets_printing_image, telephony
SELECT DISTINCT
    (product_category_name_english)
FROM
    product_category_name_translation
WHERE
    product_category_name_english IN ('audio' , 'electronics',
        'computers_accessories',
        'computers',
        'tablets_printing_image',
        'telephony');


# 4. What’s the average price of the products being sold? 
SELECT 
    ROUND(AVG(price)) AS average_price
FROM
    order_items;

# output: 121$ (i assume $)

/* 
2.2. In relation to the sellers:

6. How many months of data are included in the magist database?
7. How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
8. What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?
9. Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers? 
*/

# 6. How many months of data are included in the magist database?

# This counts how many months per year separately
SELECT 
    YEAR(order_purchase_timestamp) AS order_year,
    COUNT(DISTINCT MONTH(order_purchase_timestamp)) AS months_in_year
FROM
    orders
GROUP BY order_year;

# This counts the total of all months
SELECT 
    SUM(months_in_year) AS total_months
FROM
    (SELECT 
        YEAR(order_purchase_timestamp) AS order_year,
            COUNT(DISTINCT MONTH(order_purchase_timestamp)) AS months_in_year
    FROM
        orders
    GROUP BY order_year) total_months_magist; # the last name (total_months_magist) is an alias for the Subquery (the one in the parentheses)

/* 
2.3. In relation to the delivery time:

10. What’s the average time between the order being placed and the product being delivered?
11. How many orders are delivered on time vs orders delivered with a delay?
12. Is there any pattern for delayed orders, e.g. big products being delayed more often?
*/

# 12. Is there any pattern for delayed orders, e.g. big products being delayed more often?

SELECT 
    CASE
        WHEN (o.order_delivered_customer_date - o.order_estimated_delivery_date) >= 0 THEN 'delayed'
        ELSE 'on time'
    END AS delivery_status,
    CASE
        WHEN p.product_weight_g <= 500 THEN 'light'
        WHEN p.product_weight_g BETWEEN 500 AND 2000 THEN 'medium'
        ELSE 'heavy'
    END AS product_weight,
    COUNT(DISTINCT o.order_id) AS delivery_count
FROM
    orders AS o
        LEFT JOIN
    order_items AS ot ON o.order_id = ot.order_id
        LEFT JOIN
    products AS p ON ot.product_id = p.product_id
WHERE
    o.order_delivered_customer_date IS NOT NULL
        AND o.order_status LIKE 'delivered'
GROUP BY delivery_status , product_weight
ORDER BY delivery_status , product_weight;
