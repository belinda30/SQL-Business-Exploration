USE magist;


##############################3 Explore The Tables ##############################################

/* 1. How many orders are there in the dataset.
 
The orders table contains a row for each order, so this should be easy to find out!*/
SELECT COUNT(order_id) AS order_count FROM orders;

# orders in total: 99.441 orders

/* 2. Are orders actually delivered? 

Look at the columns in the orders table: one of them is called order_status. 
Most orders seem to be delivered, but some aren’t. 
Find out how many orders are delivered and how many are cancelled, unavailable, 
or in any other status by grouping and aggregating this column.
*/

SELECT order_status FROM orders;

SELECT 
    order_status, COUNT(*) AS orders
FROM
    orders
GROUP BY
    order_status;

# delivered orders in total: 96.478

/*
3. Is Magist having user growth? 

A platform losing users left and right isn’t going to be very useful to us. 
It would be a good idea to check for the number of orders grouped by year and month.
Tip: you can use the functions YEAR() and MONTH() to separate the year and the month of the order_purchase_timestamp.
*/

SELECT order_purchase_timestamp FROM orders;

SELECT 
    YEAR(order_purchase_timestamp) AS order_year,
    MONTH(order_purchase_timestamp) AS order_month,
    COUNT(order_id) AS number_of_orders
FROM
    orders
GROUP BY order_year, order_month
ORDER BY order_year DESC, order_month DESC;

/*
4. How many products are there on the products table? 
(Make sure that there are no duplicate products.)
*/

SELECT * FROM products;

SELECT COUNT(DISTINCT(product_id)) AS unique_products FROM products;

/*
5. Which are the categories with the most products? 

Since this is an external database and has been partially anonymized, 
we do not have the names of the products. 
But we do know which categories products belong to. 
This is the closest we can get to knowing what sellers are offering in the Magist marketplace. 
By counting the rows in the products table and grouping them by categories, 
we will know how many products are offered in each category. 
This is not the same as how many products are actually sold by category.
To acquire this insight we will have to combine multiple tables together: 
we’ll do this in the next lesson.
*/

SELECT * FROM products;

SELECT DISTINCT
    (COUNT(p.product_id)) AS products_qty,
    pt.product_category_name_english
FROM
    products AS p
        LEFT JOIN
    product_category_name_translation AS pt ON p.product_category_name = pt.product_category_name
GROUP BY product_category_name_english
ORDER BY products_qty DESC;

/*
6. How many of those products were present in actual transactions? 
The products table is a “reference” of all the available products. 
Have all these products been involved in orders? 
Check out the order_items table to find out!
*/
# JOIN mit product_id, Distinct order_id
SELECT * FROM order_items;

SELECT DISTINCT
    (COUNT(product_id)) AS num_products
FROM
    order_items;


/*
7. What’s the price for the most expensive and cheapest products? 
Sometimes, having a broad range of prices is informative. 
Looking for the maximum and minimum values is also a good way to detect extreme outliers.
*/

SELECT * FROM order_items;

SELECT 
    MAX(price) AS expensive_, MIN(price) AS cheapest_
FROM
    order_items;


/*
8. What are the highest and lowest payment values? 
Some orders contain multiple products. 
What’s the highest someone has paid for an order? 
Look at the order_payments table and try to find it out.
 */
 
 SELECT * FROM order_payments;
 
 
 # highest and lowest payment values
 SELECT 
    MAX(payment_value) AS highest_payment_value,
    MIN(payment_value) AS lowest_payment_value
FROM
    order_payments;
 
 
 # Highest someone has paid for an order
SELECT 
    SUM(payment_value) AS highest_order
FROM
    order_payments
GROUP BY order_id
ORDER BY highest_order DESC
LIMIT 1;
 
 
