-- Window Functions
-- agg unction, over(partition by clause for column name)
-- write a query that returns stocks amount of products 
-- (use only stock table)
USE SampleRetail

-- with group by
SELECT product_id, SUM(quantity) AS stock_amount
FROM product.stock
GROUP BY product_id
ORDER BY product_id

-- with WF
SELECT * , SUM(quantity) OVER(PARTITION BY product_id ) AS stock_amount
FROM product.stock

--------------------------------
-- find the average list price of every brand
-- WF
SELECT DISTINCT brand_id, AVG(list_price) OVER(PARTITION BY brand_id ) AS avg_price
FROM product.product

-- GROUP BY
SELECT brand_id, AVG(list_price)
FROM product.product
GROUP BY brand_id

--------------------------------

-- ORDER BY method
SELECT	category_id, product_id,
		COUNT(*) OVER() NOTHING,
		COUNT(*) OVER(PARTITION BY category_id) countofprod_by_cat,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) whole_rows,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id) countofprod_by_cat_2,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) prev_with_current,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) current_with_following,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) specified_columns_1,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id ROWS BETWEEN 2 PRECEDING AND 3 FOLLOWING) specified_columns_2
FROM	product.product
ORDER BY category_id, product_id

--------------------------------
-- list  the cheapest product price
SELECT TOP 1 list_price
FROM product.product
ORDER BY list_price

-- with WF
SELECT DISTINCT MIN(list_price) OVER()
FROM product.product

-- list also product_id and name
SELECT  TOP 1 product_id, product_name, MIN(list_price) OVER(PARTITION BY list_price order by list_price) AS min_price
FROM product.product

SELECT  TOP 1 product_id, product_name, MIN(list_price) OVER(PARTITION BY list_price ) AS min_price
FROM product.product

-- cheapest product list
SELECT  product_id, product_name, MIN(list_price) OVER(PARTITION BY list_price ) AS min_price
FROM product.product
WHERE list_price = (SELECT MIN(list_price) FROM product.product )
;

SELECT *
FROM (
    SELECT product_id, product_name, list_price, min(list_price) OVER() cheapest
    FROM product.product
    )  AS a 
WHERE a.list_price = a.cheapest
;

--------------------------------
-- list the category id's with their min list price.
SELECT distinct category_id,  MIN(list_price) OVER(PARTITION BY category_id ) AS min_price
FROM product.product

--------------------------------

SELECT COUNT(*)
FROM product.product
-- or
SELECT COUNT(product_id)
FROM product.product
-- or we can do that with WF
SELECT DISTINCT COUNT(*) OVER()
FROM product.product

--------------------------------
-- how many different products we have ?
SELECT COUNT(DISTINCT product_id)
FROM sale.order_item

-- distinct doesnt work with count function on WFs(overs)
SELECT COUNT(DISTINCT product_id) OVER()
FROM sale.order_item

--------------------------------
-- how many products we sold check it for each order
SELECT DISTINCT order_id, COUNT(item_id) OVER(PARTITION BY order_id ) as cnt_num
FROM sale.order_item
-- or
SELECT DISTINCT order_id, COUNT(*) OVER(PARTITION BY order_id ) as cnt_num
FROM sale.order_item

--------------------------------
-- list total amounts for every category and brand
SELECT DISTINCT category_id, brand_id, COUNT(*) OVER(PARTITION BY category_id, brand_id ) total_
FROM product.product

--------------------------------
-- Analytic Navigation Functions
-- show the first date of orders

SELECT c.first_name, c.last_name, o.order_date, 
    FIRST_VALUE(o.order_date) OVER(ORDER BY o.order_date) first_date
FROM sale.customer AS c 
JOIN sale.orders AS o ON o.customer_id = c.customer_id

--------------------------------
-- show the last value of order's date, be careful for the default value of OVER(ORDER BY defaults)
-- it starts from unbounded preceding and current row

SELECT c.first_name, c.last_name, o.order_date, 
    LAST_VALUE (o.order_date) OVER(ORDER BY o.order_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING  ) first_date
FROM sale.customer AS c 
JOIN sale.orders AS o ON o.customer_id = c.customer_id

--------------------------------
-- what is the cheapest product's name
SELECT distinct FIRST_VALUE(product_name) OVER(ORDER BY list_price )
FROM product.product

-- with its name
SELECT distinct 
    FIRST_VALUE(product_name) OVER(ORDER BY list_price, model_year ),
    FIRST_VALUE(list_price) OVER(ORDER BY list_price, model_year )
FROM product.product


-- lag()
SELECT o.order_id, s.staff_id, s.first_name, s.last_name, o.order_date,
LAG(o.order_date ) OVER(PARTITION BY s.staff_id ORDER BY o.order_id ) AS prev_order_date
FROM sale.orders AS o 
JOIN sale.staff AS s ON s.staff_id = o.staff_id

SELECT o.order_id, s.staff_id, s.first_name, s.last_name, o.order_date,
LAG(o.order_date, 2 ) OVER(PARTITION BY s.staff_id ORDER BY o.order_id ) AS prev_order_date
FROM sale.orders AS o 
JOIN sale.staff AS s ON s.staff_id = o.staff_id

-- lead()
SELECT o.order_id, s.staff_id, s.first_name, s.last_name, o.order_date,
LEAD(o.order_date ) OVER(PARTITION BY s.staff_id ORDER BY o.order_id ) AS prev_order_date
FROM sale.orders AS o 
JOIN sale.staff AS s ON s.staff_id = o.staff_id

SELECT o.order_id, s.staff_id, s.first_name, s.last_name, o.order_date,
LEAD(o.order_date, 2 ) OVER(PARTITION BY s.staff_id ORDER BY o.order_id ) AS prev_order_date
FROM sale.orders AS o 
JOIN sale.staff AS s ON s.staff_id = o.staff_id

