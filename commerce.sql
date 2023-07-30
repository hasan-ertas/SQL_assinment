CREATE DATABASE commerce
GO

CREATE SCHEMA commerce
GO

CREATE TABLE [commerce].[commerce](
    [Ord_ID] INT NOT NULL,
    [Cust_ID] INT NOT NULL,
    [Prod_ID] INT NOT NULL,
    [Ship_ID] INT NOT NULL,
    [Order_Date] Date NOT NULL,
    [Ship_Date] Date NOT NULL,
    [Customer_Name] [nvarchar](100) NOT NULL,
    [Province] [nvarchar](100) NOT NULL,
    [Region] [nvarchar](100) NOT NULL,
    [Customer_Segment] [nvarchar](100) NOT NULL,
    [Sales] INT NOT NULL,
    [Order_Quantity] INT NOT NULL,
    [Order_Priority] [nvarchar](100) NOT NULL,
    [DaysTakenForShipping] INT NOT NULL
);
select*
from commerce
------------
--1.Find the top 3 customers who have the maximum count of orders.



SELECT TOP 3 Customer_Name, COUNT(*) AS Order_Count
FROM commerce
GROUP BY Customer_Name
ORDER BY Order_Count DESC;

---2.Find the customer whose order took the maximum time to get shipping.
SELECT TOP 1 Customer_Name, DaysTakenForShipping
FROM commerce
ORDER BY DaysTakenForShipping DESC;

---3 Count the total number of unique customers in January and how many of them came back 
---every month over the entire year in 2011
SELECT COUNT(DISTINCT Cust_ID) AS Total_Unique_Customers_In_January
FROM commerce
WHERE YEAR(Order_Date) = 2011 AND MONTH(Order_Date) = 1;

SELECT Cust_ID, COUNT(DISTINCT MONTH(Order_Date)) AS Months_Active
FROM commerce
WHERE YEAR(Order_Date) = 2011
GROUP BY Cust_ID
HAVING COUNT(DISTINCT MONTH(Order_Date)) = 12;

--4.Write a query to return for each user the time elapsed between the first purchasing and the third purchasing, 
--in ascending order by Customer ID.
WITH RankedPurchases AS (
    SELECT
        Cust_ID,
        Order_Date,
        RANK() OVER (PARTITION BY Cust_ID ORDER BY Order_Date) AS PurchaseRank
    FROM commerce
)
SELECT
    FirstPurchase.Cust_ID,
    DATEDIFF(day, FirstPurchase.Order_Date, ThirdPurchase.Order_Date) AS TimeElapsed
FROM RankedPurchases FirstPurchase
JOIN RankedPurchases ThirdPurchase
    ON FirstPurchase.Cust_ID = ThirdPurchase.Cust_ID
    AND FirstPurchase.PurchaseRank = 1
    AND ThirdPurchase.PurchaseRank = 3
ORDER BY FirstPurchase.Cust_ID;




--5. Write a query that returns customers who purchased both product 11 and product 14, as well as 
--the ratio of these products to the total number of products purchased by the customer.



SELECT
    t1.Cust_ID,
    t1.Customer_Name,
    (t1.Count_11 + t2.Count_14) AS Total_Prod_11_14,
    t1.Total_Products,
    CAST((t1.Count_11 + t2.Count_14) * 1.0 / t1.Total_Products AS DECIMAL(10, 3)) AS Ratio_11_14_To_Total
FROM
    (SELECT
        Cust_ID,
        Customer_Name,
        COUNT(*) AS Total_Products,
        SUM(CASE WHEN Prod_ID = 11 THEN 1 ELSE 0 END) AS Count_11
    FROM commerce
    GROUP BY Cust_ID, Customer_Name) t1
JOIN
    (SELECT
        Cust_ID,
        COUNT(*) AS Count_14
    FROM commerce
    WHERE Prod_ID = 14
    GROUP BY Cust_ID) t2
ON t1.Cust_ID = t2.Cust_ID
WHERE t1.Count_11 > 0 AND t2.Count_14 > 0;




--------Customer Segmentation
--Categorize customers based on their frequency of visits. The following steps will guide you. 
--If you want, you can track your own way.
--1. Create a “view” that keeps visit logs of customers on a monthly basis. 
--(For each log, three field is kept: Cust_id, Year, Month)

CREATE VIEW CustomerVisitLogs AS
SELECT
    Cust_ID,
    YEAR(Order_Date) AS [Year],
    MONTH(Order_Date) AS [Month]
FROM commerce;

SELECT *
FROM CustomerVisitLogs;

--2.Create a “view” that keeps the number of monthly visits by users. 
--(Show separately all months from the beginning business)
CREATE VIEW MonthlyVisitsByUsers AS
SELECT
    Cust_ID,
    YEAR(Order_Date) AS [Year],
    MONTH(Order_Date) AS [Month],
    COUNT(*) AS MonthlyVisits
FROM commerce
GROUP BY Cust_ID, YEAR(Order_Date), MONTH(Order_Date);
SELECT *
FROM MonthlyVisitsByUsers;

---------
--3.For each visit of customers, create the next month of the visit as a separate column.
CREATE VIEW CustomerNextMonthVisits1 AS
SELECT
    Cust_ID,
    Order_Date AS Visit_Month,
    LEAD(Order_Date,1, '0001-01-01') OVER (PARTITION BY Cust_ID ORDER BY Order_Date) AS Next_Month_Visit
FROM commerce;

SELECT *
FROM CustomerNextMonthVisits1;

--4.Calculate the monthly time gap between two consecutive visits by each customer.
SELECT
    Cust_ID,
    Order_Date AS Visit_Month,
    LAG(Order_Date) OVER (PARTITION BY Cust_ID ORDER BY Order_Date) AS Previous_Visit_Month,
    DATEDIFF(MONTH, LAG(Order_Date) OVER (PARTITION BY Cust_ID ORDER BY Order_Date), Order_Date) AS Monthly_Time_Gap
FROM commerce;

-- alternatif yöntem

WITH VisitData AS (
    SELECT
        Cust_ID,
        Order_Date,
        LAG(Order_Date) OVER (PARTITION BY Cust_ID ORDER BY Order_Date) AS Previous_Order_Date
    FROM commerce
)
SELECT
    Cust_ID,
    Order_Date AS Current_Visit_Date,
    Previous_Order_Date AS Previous_Visit_Date,
    DATEDIFF(MONTH, Previous_Order_Date, Order_Date) AS Time_Gap_Months
FROM VisitData
WHERE Previous_Order_Date IS NOT NULL;





---5.Categorise customers using average time gaps. Choose the most fitted labeling model for you.
--For example:
-- Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase.
-- Labeled as regular if the customer has made a purchase every month.
WITH samp1 AS (
    SELECT
        Cust_ID,
        Order_Date,
        LAG(Order_Date) OVER (PARTITION BY Cust_ID ORDER BY Order_Date) AS Previous_Order_Date
    FROM commerce
)
, TimeGaps AS (
    SELECT
        Cust_ID,
        Order_Date,
        Previous_Order_Date,
        DATEDIFF(MONTH, Previous_Order_Date, Order_Date) AS Time_Gap_Months
    FROM samp1
    WHERE Previous_Order_Date IS NOT NULL
)
, AverageTimeGap AS (
    SELECT
        Cust_ID,
        AVG(Time_Gap_Months) AS Avg_Time_Gap_Months
    FROM TimeGaps
    GROUP BY Cust_ID
)
SELECT
    Cust_ID,
    Avg_Time_Gap_Months,
    CASE
        WHEN Avg_Time_Gap_Months > 2 THEN 'Irregular'
        ELSE 'Regular'
    END AS Customer_Category
FROM AverageTimeGap;
------------------------------------------------
--Month-Wise Retention Rate
--Find month-by-month customer retention ratei since the start of the business.
--There are many different variations in the calculation of Retention Rate. But we will try to calculate the month-wise retention rate in this project.
--So, we will be interested in how many of the customers in the previous month could be retained in the next month.
--Proceed step by step by creating “views”. You can use the view you got at the end of the Customer Segmentation section as a source.
--1. Find the number of customers retained month-wise. (You can use time gaps)
--2. Calculate the month-wise retention rate.
--Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Current Month / 
--Total Number of Customers in the Current Month

CREATE VIEW MonthWiseRetention AS
SELECT 
    Visit_Month AS Retention_Month,
    COUNT(DISTINCT Cust_ID) AS Customers_Retained
FROM CustomerNextMonthVisits
WHERE Next_Month_Visit IS NOT NULL
GROUP BY Visit_Month;
--
CREATE VIEW TotalCustomersByMonth AS
SELECT
    Year,
    Month,
    COUNT(DISTINCT Cust_ID) AS Total_Customers
FROM CustomerVisitLogs
GROUP BY Year, Month;
---------
--CREATE VIEW TotalCustomersByMonth AS
--SELECT
--    DATEFROMPARTS(Year, Month, 1) AS MonthDate, -- Combine Year and Month into a date
--    COUNT(DISTINCT Cust_ID) AS Total_Customers
--FROM CustomerVisitLogs
--GROUP BY Year, Month;
-- Create a view to calculate the month-wise retention rate
CREATE VIEW MonthWiseRetentionRate AS
SELECT
    R.Retention_Month,
    R.Customers_Retained,
    T.Total_Customers,
    1.0 * R.Customers_Retained / T.Total_Customers AS Retention_Rate
FROM MonthWiseRetention R
JOIN TotalCustomersByMonth T ON R.Retention_Month = T.Month;

select*

from MonthWiseRetentionRate

