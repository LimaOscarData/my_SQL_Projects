---- RDB&SQL Exercise-2 Student


-- ##########################################################################
----1. By using view get the average sales by staffs and years using the AVG() aggregate function.
USE SampleRetail

-- with views
CREATE VIEW table11 AS
SELECT first_name, last_name, years, avg_amount
FROM 
        (
        SELECT s.first_name, s.last_name, AVG((i.list_price) * (1-i.discount)* i.quantity) AS avg_amount, 
        Year(o.order_date) as years
        FROM sale.staff AS s 
        JOIN sale.orders AS o ON o.staff_id = s.staff_id
        JOIN sale.order_item i ON i.order_id = o.order_id
        GROUP BY s.first_name, s.last_name, year(o.order_date
        )) as A
     ;

SELECT first_name, last_name, years, ROUND(avg_amount,2,0)
FROM table11
ORDER BY first_name, last_name,years

--------------------------------------------------
-- example for where clause
SELECT * 
FROM(
SELECT s.first_name, s.last_name, AVG((i.list_price) * (1-i.discount)* i.quantity) AS avg_amount, 
        Year(o.order_date) as years
        FROM sale.staff AS s 
        JOIN sale.orders AS o ON o.staff_id = s.staff_id
        JOIN sale.order_item i ON i.order_id = o.order_id
        GROUP BY s.first_name, s.last_name, year(o.order_date
        )) as A
WHERE A.avg_amount < 400

--------------------------------------------------

-- with group by
SELECT s.first_name, s.last_name, AVG((i.list_price) * (1-i.discount)* i.quantity) AS avg_amount, 
        Year(o.order_date) as years
FROM sale.staff AS s 
JOIN sale.orders AS o ON o.staff_id = s.staff_id
JOIN sale.order_item i ON i.order_id = o.order_id
GROUP BY s.first_name, s.last_name, year(o.order_date)
ORDER BY first_name, last_name,years





-- ##########################################################################
----2. Select the annual amount of product produced according to brands (use window functions).
-- SELECT *
-- FROM product.stock AS s 
-- JOIN product.product AS p ON p.product_id = s.product_id
-- JOIN product.brand AS b ON b.brand_id = p.brand_id


SELECT DISTINCT A.brand_name, B.model_year, 
SUM(C.quantity) OVER(PARTITION BY B.model_year ORDER BY A.brand_name, B.model_year) ANNUAL_AMOUNT
FROM product.brand A, product.product B, product.stock C
WHERE A.brand_id = B.brand_id AND
	  B.product_id = C.product_id




-- ##########################################################################
----3. Select the least 3 products in stock according to stores.

-- SELECT *
-- FROM product.product

select * from 
(
SELECT t.store_name, p.product_name, sum(s.quantity) as sum_of_quantity,
row_number() over(partition by t.store_name order by sum(s.quantity) asc) least_3
FROM product.stock AS s 
JOIN product.product AS p ON p.product_id = s.product_id
JOIN sale.store as t ON t.store_id= s.store_id
GROUP BY t.store_name, p.product_name,s.quantity 
having sum(s.quantity) > 0
 ) a
 where a.least_3 < 4





-- ##########################################################################
----4. Return the average number of sales orders in 2020 sales

-- ##########################################################################
----5. Assign a rank to each product by list price in each brand and get products with rank less than or equal to three.