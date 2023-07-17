--In this assignment two different missions waiting for you.

--1. Product Sales
--You need to create a report on whether customers who 
--purchased the product named '2TB Red 5400 rpm 
--SATA III 3.5 Internal NAS HDD' buy the product below or not.

--1. 'Polk Audio - 50 W Woofer - Black' -- (other_product)

--To generate this report, you are required to use the appropriate 
--SQL Server Built-in functions or expressions as well as basic SQL knowledge.
--Desired Output:


------------------
SELECT TOP 3 c.customer_id, c.first_name, c.last_name, 'No' AS Other_Product
FROM sale.customer c
 INNER JOIN  sale.orders o ON c.customer_id=o.customer_id
 INNER JOIN  sale.order_item s ON o.order_id = s.order_id
 INNER JOIN product.product p ON s.product_id=p.product_id
 WHERE p.product_name= '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
                      AND  c.customer_id NOT IN
					       (
						     SELECT c.customer_id
                             FROM sale.customer c
                             INNER JOIN  sale.orders o ON c.customer_id=o.customer_id
                              INNER JOIN  sale.order_item s ON o.order_id = s.order_id
                               INNER JOIN product.product p ON s.product_id=p.product_id
                                 WHERE p.product_name= 'Polk Audio - 50 W Woofer - Black'
								 )
 ORDER BY customer_id ASC;
-------------

--2.
--a)
CREATE TABLE Actions (
    Visitor_ID INT,
    Adv_Type CHAR(1),
    Action VARCHAR(10)
);

INSERT INTO Actions (Visitor_ID, Adv_Type, Action)
VALUES
    (1, 'A', 'Left'),
    (2, 'A', 'Order'),
    (3, 'B', 'Left'),
    (4, 'A', 'Order'),
    (5, 'A', 'Review'),
    (6, 'A', 'Left'),
    (7, 'B', 'Left'),
    (8, 'B', 'Order'),
    (9, 'B', 'Review'),
    (10, 'A', 'Review');
--DELETE FROM Actions
SELECT *
FROM Actions

	--b)
SELECT Adv_Type, COUNT(*) AS Total_Actions, SUM(CASE WHEN Action = 'Order' THEN 1 ELSE 0 END) AS Total_Orders
FROM Actions
GROUP BY Adv_Type;

--c)
SELECT Adv_Type, Total_Orders / (Total_Actions * 1.0) AS Conversion_Rate
FROM (
    SELECT Adv_Type, COUNT(*) AS Total_Actions, SUM(CASE WHEN Action = 'Order' THEN 1 ELSE 0 END) AS Total_Orders
    FROM Actions
    GROUP BY Adv_Type
) AS Subquery;