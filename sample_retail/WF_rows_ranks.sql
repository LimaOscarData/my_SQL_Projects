-- WF analytic function
-- row_number, dense rank, rank

-- ROW_NUMBER()
-- same with the row numbers
SELECT order_id, item_id,
ROW_NUMBER() OVER(ORDER BY order_id ) AS row_number
FROM sale.order_item

-- partition by order_id and show row numbers in this order_id group
SELECT order_id, item_id,
ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY order_id ) AS row_number
FROM sale.order_item

SELECT category_id, list_price,
ROW_NUMBER() OVER(PARTITION BY category_id ORDER BY list_price ) AS row_number
FROM product.product
ORDER BY category_id, list_price

-- RANK()
SELECT order_id,
RANK() OVER(ORDER BY order_id ) AS rank_col
FROM sale.order_item

SELECT category_id, list_price,
ROW_NUMBER() OVER(PARTITION BY category_id ORDER BY list_price ) AS row_num,
RANK() OVER(PARTITION BY category_id ORDER BY list_price ) AS rank_num
FROM product.product
ORDER BY category_id, list_price

-- DENSE_RANK()
SELECT order_id,
DENSE_RANK() OVER(ORDER BY order_id ) AS rank_col
FROM sale.order_item

SELECT category_id, list_price,
ROW_NUMBER() OVER(PARTITION BY category_id ORDER BY list_price ) AS row_num,
RANK() OVER(PARTITION BY category_id ORDER BY list_price ) AS rank_num,
DENSE_RANK() OVER(PARTITION BY category_id ORDER BY list_price ) AS dense_rank_num
FROM product.product
ORDER BY category_id, list_price

-- ##########################################################################################
-- Cume_Dist(), Percent_rank(), Ntile(N) Functions

-- Cume_Dist() row_number/ total_rows
SELECT brand_id, list_price,
ROUND( CUME_DIST() OVER(PARTITION BY brand_id ORDER BY list_price ), 3) AS cume_dist_price
FROM product.product



-- Percent_rank() (row_number-1) / (Total_rows-1)
SELECT brand_id, list_price,
ROUND( CUME_DIST() OVER(PARTITION BY brand_id ORDER BY list_price ), 3) AS cume_dist_price,
ROUND( PERCENT_RANK() OVER(PARTITION BY brand_id ORDER BY list_price ), 3) AS percent_rank_price
FROM product.product


-- Ntile(N)
-- returns N group
SELECT brand_id, list_price,
ROUND( CUME_DIST() OVER(PARTITION BY brand_id ORDER BY list_price ), 3) AS cume_dist_price,
ROUND( PERCENT_RANK() OVER(PARTITION BY brand_id ORDER BY list_price ), 3) AS percent_rank_price,
NTILE(4) OVER(PARTITION BY brand_id ORDER BY list_price ) AS ntile_rows,
COUNT(*) OVER(PARTITION BY brand_id )
FROM product.product

-- 


WITH tbl AS
(
    SELECT o.order_id, i.item_id, i.product_id, i.quantity, i.list_price, i.discount,
    (i.list_price * (1-i.discount)) * i.quantity discounted_price,
    SUM((i.list_price * (1-i.discount)) * i.quantity) OVER(PARTITION BY o.order_id ) discounted_order_total,
    SUM(i.quantity * i.list_price ) OVER(PARTITION BY o.order_id ) normal_order_total,
    SUM(i.quantity) OVER(PARTITION BY o.order_id ) count_of_order
    FROM sale.orders AS o 
    JOIN sale.order_item AS i ON i.order_id = o.order_id
)
SELECT DISTINCT order_id, discounted_order_total, normal_order_total, count_of_order,
    1-(discounted_order_total / normal_order_total) discount_ratio,
    (1-(discounted_order_total / normal_order_total)) * 100 as percent_discount_ratio,
    CAST((1-(discounted_order_total / normal_order_total)) * 100 AS int ) INT_PERC_COL,
    ROUND(((1-(discounted_order_total / normal_order_total)) * 100),0,0 ) ROUND_PERC_COL
FROM tbl 
ORDER BY discount_ratio DESC

-- convert method
SELECT CONVERT(nvarchar(6), GETDATE() , 112) AS ay , GETDATE()


WITH tbl AS
(SELECT DISTINCT 
        YEAR(order_date ) yil,
        CONVERT(nvarchar(6), order_date, 112 ) ay,
        COUNT(*) OVER( PARTITION BY CONVERT(nvarchar(6), order_date, 112 ) ) total_order
FROM sale.orders)
SELECT *, LAG(total_order) OVER(ORDER BY ay ) AS previous_month,
            LEAD(total_order ) OVER(ORDER BY ay ) AS following_month,
            CUME_DIST() OVER(PARTITION BY yil ORDER BY ay ) AS kumulatif_yuzde
FROM tbl

