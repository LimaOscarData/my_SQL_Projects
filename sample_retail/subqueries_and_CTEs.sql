USE SampleRetail

-- SINGLE ROW SUBQUERY
------------------------------------------------------------------------
-- using subquery inside the select
SELECT  order_id, product_id, 
    (select AVG(list_price) FROM sale.order_item) AS tab_avg,
    (select MIN(list_price) FROM sale.order_item) as tab_min,
    (select MAX(list_price) FROM sale.order_item) AS tab_max
FROM sale.order_item
------------------------------------------------------------------------

SELECT *
FROM sale.order_item
------------------------------------------------------------------------
-- using the subquery inside the from
-- Note : don't forget to use the alias
SELECT order_id, list_price, discount
FROM (SELECT TOP 5 *
        FROM sale.order_item
        ORDER BY product_id asc) AS my_new_table
------------------------------------------------------------------------

-- bring all the staff from the store that Davis Thomas works

SELECT staff_id, first_name, last_name
FROM sale.staff  
WHERE store_id = (SELECT store_id
                    FROM sale.staff
                    WHERE first_name = 'Davis' AND last_name = 'Thomas'
                    )

------------------------------------------------------------------------
-- list all the staffs whose maneger is Charles Cussona
SELECT *
FROM sale.staff
WHERE manager_id = (SELECT staff_id
                    FROM sale.staff
                    WHERE first_name = 'Charles' AND last_name = 'Cussona'
                    )

------------------------------------------------------------------------
-- find the customers who lives in the city where 'The BFLO Store' is. 
SELECT * 
FROM sale.customer
WHERE city = (SELECT city
                FROM sale.store
                WHERE store_name = 'The BFLO Store'
                )

------------------------------------------------------------------------
-- return the products which has a price more than 
-- 'Pro-Series 49-Class Full HD Outdoor LED TV (Silver)' Television category products.
SELECT *
FROM product.product
WHERE list_price > (SELECT list_price
                    FROM product.product
                    WHERE product_name = 'Pro-Series 49-Class Full HD Outdoor LED TV (Silver)'
                    ) AND
                    category_id = (SELECT category_id
                                    FROM product.category
                                    WHERE category_name LIKE '%Television%'
                                    )
------------------------------------------------------------------------
-- MULTIPLE RESULT SUBQUERY

-- list all the customers who orders on the same date as Laurel Goldammer
-- with joins :
SELECT c.first_name, c.last_name, o.order_date
FROM sale.customer AS c 
JOIN sale.orders AS o ON o.customer_id = c.customer_id
WHERE order_date IN (   SELECT order_date
                        FROM sale.orders
                        WHERE customer_id =(SELECT customer_id
                                            FROM sale.customer
                                            WHERE first_name = 'Laurel' AND last_name = 'Goldammer'
                                            )
                    )

-- with where clauses :
SELECT c.first_name, c.last_name, o.order_date
FROM sale.customer AS c , sale.orders AS o 
WHERE c.customer_id = o.customer_id 
        AND 
        order_date IN (   SELECT order_date
                                FROM sale.orders
                                WHERE customer_id =(SELECT customer_id
                                                    FROM sale.customer
                                                    WHERE first_name = 'Laurel' AND last_name = 'Goldammer'
                                                    )
                            )

------------------------------------------------------------------------
--  2021 model year, and doesnt have a gategory name 'game , gps , home theather ' 
SELECT p.category_id, p.product_name, c.category_name
FROM product.product AS p 
JOIN product.category AS c ON c.category_id = p.category_id
WHERE p.model_year = 2021 AND p.category_id NOT IN (SELECT category_id
                            FROM product.category
                            WHERE category_name IN ('game', 'gps', 'home theater')
                            )

------------------------------------------------------------------------
-- List all the products which is more expensive than the most expensive product which has
--  model year = 2020 and category name = 'Receivers Amplifiers'

-- max() method with asc order 
SELECT product_name, list_price
FROM product.product
WHERE list_price >(SELECT MAX(list_price)
                    FROM product.product
                    WHERE category_id =( SELECT category_id
                                        FROM product.category
                                        WHERE category_name = 'Receivers Amplifiers'
                                        ) 
                    ) AND
                    model_year = 2020
ORDER BY list_price

--  with ALL method with desc order
SELECT product_name, list_price
FROM product.product
WHERE list_price >ALL (SELECT list_price
                    FROM product.product
                    WHERE category_id =( SELECT category_id
                                        FROM product.category
                                        WHERE category_name = 'Receivers Amplifiers'
                                        ) 
                    ) AND
                    model_year = 2020
ORDER BY list_price DESC
      
-- with top method
SELECT product_name, list_price
FROM product.product
WHERE list_price > (SELECT TOP 1 list_price
                    FROM product.product
                    WHERE category_id =( SELECT category_id
                                        FROM product.category
                                        WHERE category_name = 'Receivers Amplifiers'
                                        ) 
                    ORDER BY list_price DESC 
                    ) AND
                    model_year = 2020
ORDER BY list_price DESC

-- List all the products which is more expensive than ANY product which has
--  model year = 2020 and category name = 'Receivers Amplifiers'

SELECT product_name, list_price
FROM product.product
WHERE list_price >ANY (SELECT list_price
                    FROM product.product
                    WHERE category_id =( SELECT category_id
                                        FROM product.category
                                        WHERE category_name = 'Receivers Amplifiers'
                                        ) 
                    ) AND
                    model_year = 2020
ORDER BY list_price DESC

------------------------------------------------------------------------
------------------------------------------------------------------------

--  CORELATED SUBQUERIES
-- list the customers who has all orders are after '2020-01-01' date

SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM sale.customer AS c, sale.orders AS o 
WHERE o.customer_id = c.customer_id AND 
                NOT EXISTS (SELECT *
                            FROM sale.orders AS r
                            WHERE r.order_date < '2020-01-01' AND
                            c.customer_id=r.customer_id
                            )

-- with JOIN s
SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM sale.customer AS c 
JOIN sale.orders AS o ON o.customer_id = c.customer_id
WHERE NOT EXISTS (SELECT *
                FROM sale.orders AS r
                WHERE r.order_date < '2020-01-01' AND
                c.customer_id=r.customer_id
                )

-- CTE (WITHs) Common Table Expressions
-- use 'WITH table_name AS' to make a CTEs

WITH table_name AS
(
SELECT MAX(o.order_date) last_order_date
FROM sale.customer AS c 
JOIN sale.orders AS o ON o.customer_id = c.customer_id
WHERE c.first_name = 'Jerald' AND c.last_name = 'Berray'
)

SELECT *
FROM table_name

-- Recursive CTEs
;
WITH table_number AS 
(
    SELECT 1 my_number

    UNION ALL
    SELECT my_number + 1
    FROM table_number
    WHERE my_number < 10
)
SELECT *
FROM table_number
