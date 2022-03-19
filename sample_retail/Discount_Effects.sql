/*
Discount Effects

Generate a report including product IDs and discount effects on whether the increase in the 
discount rate positively impacts the number of orders for the products.

In this assignment, you are expected to generate a solution using SQL with a logical approach. 

Sample Result:
Product_id	Discount Effect
1			Positive
2			Negative
3			Negative
4			Neutral
*/

select product_id, sum(quantity)
from sale.order_item
GROUP BY product_id
ORDER BY product_id


SELECT  DISTINCT product_id, discount,
SUM (quantity) OVER(PARTITION BY product_id, discount) cnt_quantity
FROM sale.order_item
ORDER BY product_id, discount
;

CREATE VIEW TABLE_A
AS
SELECT	product_id, discount, sum(quantity) as sale_quantity,
		LEAD(sum(quantity)) OVER (PARTITION BY product_id ORDER BY discount) AS next_sale_quantity,
		CASE 
			WHEN (lead(sum(quantity)) OVER (PARTITION BY product_id ORDER BY discount) - sum(quantity)) > 0 THEN 'Positive'
			WHEN (lead(sum(quantity)) OVER (PARTITION BY product_id ORDER BY discount) - sum(quantity)) < 0 THEN 'Negative'
			WHEN (lead(sum(quantity)) OVER (PARTITION BY product_id ORDER BY discount) - sum(quantity)) = 0 THEN 'Neutral'
			ELSE '-'
		END AS Discount_Effect
FROM sale.order_item
GROUP BY product_id, discount
-- 
SELECT * FROM TABLE_A
-- 
CREATE VIEW TABLE_B
AS
SELECT DISTINCT product_id, AVG(sale_quantity) AS avg_sale_quantity, 
				AVG(next_sale_quantity) AS avg_next_sale_quantity 
from TABLE_A
group by product_id

-- 
select * from TABLE_B
-- 
select product_id,
		CASE 
			WHEN avg_next_sale_quantity > avg_sale_quantity THEN 'Positive'
			WHEN avg_next_sale_quantity < avg_sale_quantity THEN 'Negative'
			WHEN avg_next_sale_quantity = avg_sale_quantity THEN 'Neutral'
			ELSE '-'
		END AS discount_effect
from TABLE_B

SELECT product_id, discount,
SUM (quantity) OVER(PARTITION BY product_id)
FROM sale.order_item


SELECT distinct product_id, discount,
SUM (quantity) OVER(PARTITION BY product_id, discount) cnt_quantity
FROM sale.order_item




--##################################################################################
-- solving it with CTEs

WITH T1 AS
            (
            SELECT distinct product_id, discount,
            SUM (quantity) OVER(PARTITION BY product_id, discount) cnt_quantity
            FROM sale.order_item
            ), T2 AS(
SELECT product_id, discount, cnt_quantity,
LEAD(cnt_quantity, 1) OVER(PARTITION BY product_id ORDER BY discount) higher_discount_quantity,
LEAD(cnt_quantity, 1) OVER(PARTITION BY product_id ORDER BY discount) - cnt_quantity as diff
FROM T1
        )
        SELECT DISTINCT product_id, discount, cnt_quantity, higher_discount_quantity,  diff,
                CASE WHEN SUM(diff) OVER(PARTITION  BY product_id) > 0 THEN 'POSITIVE'
                    WHEN SUM(diff) OVER(PARTITION  BY product_id) < 0 THEN 'NEGATIVE'
                    ELSE 'NOTR' 
                END AS DISCOUNT_EFFECT
        FROM T2

