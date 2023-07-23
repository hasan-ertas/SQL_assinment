--Generate a report including product IDs and discount effects on whether the increase in the discount 
--rate positively impacts the number of orders for the products.
--In this assignment, you are expected to generate a solution using SQL with a logical approach. 


SELECT 
    product_id,
    CASE
        WHEN cnt_orders < LAG(cnt_orders) OVER (PARTITION BY product_id ORDER BY discount) THEN 'Negative'
        WHEN cnt_orders > LAG(cnt_orders) OVER (PARTITION BY product_id ORDER BY discount) THEN 'Positive'
        ELSE 'Neutral'
    END AS Discount_Effect
FROM
(
    SELECT 
        product_id,
        discount,
        cnt_orders
    FROM
    (
        SELECT
            product_id,
            discount,
            COUNT(*) AS cnt_orders
        FROM
            sale.order_item
        GROUP BY
            product_id,
            discount
    ) AS subquery_with_counts
) AS subquery_ordered
ORDER BY product_id;
---------------------------------- alternatif yöntem


WITH DiscountStats AS (
    SELECT
        product_id,
        discount,
        count(quantity) AS number_orders
    FROM
        sale.order_item
    GROUP BY
        product_id,
        discount
)
SELECT
    product_id,
    CASE
        WHEN number_orders < LAG(number_orders) OVER (PARTITION BY product_id ORDER BY discount) THEN 'Negative'
        WHEN number_orders > LAG(number_orders) OVER (PARTITION BY product_id ORDER BY discount) THEN 'Positive'
        ELSE 'Neutral'
    END AS Discount_Effect
FROM
    DiscountStats
ORDER BY
    product_id;
--------------------------------------------------- alternatif yöntem
 
SELECT product_id,
       CASE
         WHEN total_number_orders > pre_total_orders THEN 'Positive'       
         WHEN total_number_orders < pre_total_orders THEN 'Negative'
         ELSE 'Neutral'
       END AS 'discount_effects'
FROM (
  SELECT product_id, discount,
         SUM(quantity) AS total_number_orders,
         LAG(SUM(quantity)) OVER(PARTITION BY product_id ORDER BY discount) AS pre_total_orders
  FROM sale.order_item
  GROUP BY product_id, discount
) AS product_total_orders
ORDER BY product_id;

