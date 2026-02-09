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

/** 2.How many products of these tech categories have been sold (within the time window of the database snapshot)?***/

SELECT
    product_category_name_english,
    COUNT(DISTINCT p.product_id) AS sold_tech_products
FROM
    products p
        LEFT JOIN
    order_items oi ON p.product_id = oi.product_id
        LEFT JOIN
    orders os ON oi.order_id = os.order_id
        LEFT JOIN
    product_category_name_translation pt ON pt.product_category_name = p.product_category_name
WHERE
    pt.product_category_name_english IN ('audio' , 'electronics',
        'computers_accessories',
        'computers',
        'tablets_printing_image',
        'telephony')
        AND os.order_status NOT IN ('unavailable' , 'canceled')
GROUP BY product_category_name_english;

# 3. What percentage does that represent from the overall number of products sold?
SELECT
  (SUM(translation.product_category_name_english IN (
      'audio','computer_accessories','computers','tablets_printing_image','telephony'
   )) / COUNT(*)) * 100 AS tech_percentage
FROM order_items oi
LEFT JOIN products p
  ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation translation
  ON p.product_category_name = translation.product_category_name;


# 4. What’s the average price of the products being sold? 
SELECT 
    ROUND(AVG(price)) AS average_price
FROM
    order_items;

# output: 121$ (i assume $)


#5 Are expensive tech products popular?
# 5.1 
SELECT
  AVG(oi.price) AS avg_tech
FROM order_items oi
LEFT JOIN products p
  ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation t
  ON p.product_category_name = t.product_category_name
WHERE t.product_category_name_english IN (
  'audio','computer_accessories','computers','tablets_printing_image','telephony'
);## average price for the tech products

#5.2
SELECT
  CASE
    WHEN oi.price > 116.42879094159638 * 1.2 THEN 'expensive'
    WHEN oi.price < 116.42879094159638 * 0.8 THEN 'cheap'
    ELSE 'mid'
  END AS price_category,
  COUNT(*) AS sold_items
FROM order_items oi
LEFT JOIN products p
  ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation t
  ON p.product_category_name = t.product_category_name
WHERE t.product_category_name_english IN (
  'audio','computer_accessories','computers','tablets_printing_image','telephony'
)
GROUP BY price_category; ## count of cheap and expensive sold products products
    
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

/*** 8. What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?****/
SELECT
    SUM(oi.price) AS total_amount_by_all_sellers,
    SUM(CASE
        WHEN
            pt.product_category_name_english IN ('audio' , 'electronics',
                'computers_accessories',
                'computers',
                'tablets_printing_image',
                'telephony')
        THEN
            oi.price
        ELSE 0
    END) AS total_amount_by_tech_sellers
FROM
    order_items oi
        LEFT JOIN
    products p ON oi.product_id = p.product_id
        LEFT JOIN
    orders o ON oi.order_id = o.order_id
        LEFT JOIN
    product_category_name_translation pt ON pt.product_category_name = p.product_category_name
        AND o.order_status = 'delivered';



    
/* 
2.3. In relation to the delivery time:

10. What’s the average time between the order being placed and the product being delivered?
11. How many orders are delivered on time vs orders delivered with a delay?
12. Is there any pattern for delayed orders, e.g. big products being delayed more often?
*/

# 10. What’s the average time between the order being placed and the product being delivered?*/

-- for all sellers

-- delivery estimation:

SELECT
    ROUND(AVG(DATEDIFF(order_estimated_delivery_date,
                    order_purchase_timestamp)),
            2) AS avg_delivery_estimation
FROM
    orders
WHERE
    order_estimated_delivery_date IS NOT NULL;
-- 24.33

-- delivery time:
SELECT
    ROUND(AVG(DATEDIFF(order_delivered_customer_date,
                    order_purchase_timestamp)),
            2) AS avg_delivery_time_days
FROM
    orders
WHERE
    order_delivered_customer_date IS NOT NULL;

-- for tech sellers

-- delivery estimation:
SELECT
    ROUND(AVG(DATEDIFF(order_estimated_delivery_date,
                    order_purchase_timestamp)),
            2) AS avg_delivery_estimation_tech
FROM
    orders
        LEFT JOIN
    order_items USING (order_id)
        LEFT JOIN
    products USING (product_id)
WHERE
    order_estimated_delivery_date IS NOT NULL
        AND product_category_name IN ('audio' , 'eletronicos',
        'informatica_acessorios',
        'pcs',
        'tablets_impressao_imagem',
        'telefonia');
-- 24.79

-- delivery time:
SELECT
    ROUND(AVG(DATEDIFF(order_delivered_customer_date,
                    order_purchase_timestamp)),
            2) AS avg_delivery_time_tech
FROM
    orders
        LEFT JOIN
    order_items USING (order_id)
        LEFT JOIN
    products USING (product_id)
WHERE
    order_delivered_customer_date IS NOT NULL
        AND product_category_name IN ('audio' , 'eletronicos',
        'informatica_acessorios',
        'pcs',
        'tablets_impressao_imagem',
        'telefonia');
-- 13.01

# 11. How many orders are delivered on time vs orders delivered with a delay?

SELECT
case
      When order_delivered_customer_date <= order_estimated_delivery_date
       then 'On time'
	  Else 'Delayed'
	End as delivery_status,
    count(*) as num_orders
From orders
Where order_delivered_customer_date is not Null
group by delivery_status;

# Bonus percentage

SELECT
	delivery_status,
    ROUND(COUNT(*) * 100.0 / SUM(count(*)) OVER (), 2) AS pct_orders
FROM (
	SELect
	 Case
      When order_delivered_customer_date <= order_estimated_delivery_date
       then 'On time'
	  Else 'Delayed'
	End as delivery_status
  From orders
  Where order_delivered_customer_date is not Null
) t
group by delivery_status;


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
