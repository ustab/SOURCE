
/* E-Commerce Data and Customer Retention Analysis with SQL */

USE eCommerceData

SELECT TOP(20) *
FROM cust_dimen

SELECT Customer_Name FROM cust_dimen  
WHERE Customer_Name IS NULL;

SELECT Province FROM cust_dimen  
WHERE Province IS NULL;

SELECT Region FROM cust_dimen  
WHERE Region IS NULL;

SELECT Customer_Segment FROM cust_dimen  
WHERE Customer_Segment IS NULL;

SELECT Cust_id FROM cust_dimen  
WHERE Cust_id IS NULL;
-- NULL deðer olmadýðýný gördük.

UPDATE cust_dimen
SET Cust_id = TRIM('Cust_' FROM Cust_id);

ALTER TABLE cust_dimen
ALTER COLUMN Cust_id INT NOT NULL;

ALTER TABLE cust_dimen
ADD PRIMARY KEY (Cust_id);

-- cust_dimen tablosunda Cust_id sütunu ve veri tipi düzenlendi ve PRIMARY KEY atandý.

---

SELECT TOP(20) *
FROM market_fact

UPDATE market_fact
SET Ord_id = TRIM('Ord_' FROM Ord_id),
    Prod_id = TRIM('Prod_' FROM Prod_id),
	Ship_id = TRIM('SHP_' FROM Ship_id),
	Cust_id = TRIM('Cust_' FROM Cust_id)
;

ALTER TABLE market_fact
ALTER COLUMN Ord_id INT NOT NULL; 
	        
ALTER TABLE market_fact
ALTER COLUMN Prod_id INT NOT NULL; 

ALTER TABLE market_fact
ALTER COLUMN Ship_id INT NOT NULL;

ALTER TABLE market_fact
ALTER COLUMN Cust_id INT NOT NULL;
--market_fact tablosundaki id sütunlarý ve veri tipleri düzenlendi.

SELECT Ord_id FROM market_fact  
WHERE Ord_id IS NULL;

SELECT Prod_id FROM market_fact  
WHERE Prod_id IS NULL;

SELECT Ship_id FROM market_fact  
WHERE Ship_id IS NULL;

SELECT Cust_id FROM market_fact  
WHERE Cust_id IS NULL;

SELECT Sales FROM market_fact  
WHERE Sales IS NULL;

SELECT Discount FROM market_fact  
WHERE Discount IS NULL;

SELECT Order_Quantity FROM market_fact  
WHERE Order_Quantity IS NULL;

SELECT Product_Base_Margin FROM market_fact  
WHERE Product_Base_Margin IS NULL;

--Product_Base_Margin sütununda NULL deðerler olduðunu gördük.
---

SELECT TOP(20) *
FROM orders_dimen

UPDATE orders_dimen
SET Ord_id = TRIM('Ord_' FROM Ord_id);

ALTER TABLE orders_dimen
ALTER COLUMN Ord_id INT NOT NULL;

ALTER TABLE orders_dimen
ADD PRIMARY KEY (Ord_id);

SELECT Order_Date FROM orders_dimen
WHERE Order_Date IS NULL;

SELECT Order_Priority FROM orders_dimen
WHERE Order_Priority IS NULL;

SELECT Ord_id FROM orders_dimen
WHERE Ord_id IS NULL;
-- NULL deðerler olmadýðýný gördük.

--orders_dimen tablosundaki id sütunu ve veri tipi düzenlendi ve PRIMARY KEY atandý.

---

SELECT TOP(20) *
FROM prod_dimen

UPDATE prod_dimen
SET Prod_id = TRIM('Prod_' FROM Prod_id);

ALTER TABLE prod_dimen
ALTER COLUMN Prod_id INT NOT NULL;

ALTER TABLE prod_dimen
ADD PRIMARY KEY (Prod_id);

SELECT Prod_id FROM prod_dimen
WHERE Prod_id IS NULL;

SELECT Product_Category FROM prod_dimen
WHERE Product_Category IS NULL;

SELECT Product_Sub_Category FROM prod_dimen
WHERE Product_Sub_Category IS NULL;

-- NULL deðerler olmadýðýný gördük.

--prod_dimen tablosundaki id sütunu ve veri tipi düzenlendi ve PRIMARY KEY atandý.

---

SELECT TOP(20) *
FROM shipping_dimen

UPDATE shipping_dimen
SET Ship_id = TRIM('SHP_' FROM Ship_id);

ALTER TABLE shipping_dimen
ALTER COLUMN Ship_id INT NOT NULL;

ALTER TABLE shipping_dimen
ADD PRIMARY KEY (Ship_id);

SELECT Ship_Date FROM shipping_dimen
WHERE Ship_Date IS NULL;

SELECT Ship_Mode FROM shipping_dimen
WHERE Ship_Mode IS NULL;

SELECT Ship_id FROM shipping_dimen
WHERE Ship_id IS NULL;

SELECT Order_ID FROM shipping_dimen
WHERE Order_ID IS NULL;

-- NULL deðerler olmadýðýný gördük.

--shipping_dimen tablosundaki id sütunu ve veri tipi düzenlendi ve PRIMARY KEY atandý.

---



-- Analyze the data by finding the answers to the questions below:

/* 
1. Using the columns of “market_fact”, “cust_dimen”, “orders_dimen”, “prod_dimen”, “shipping_dimen”, 
Create a new table, named as “combined_table”.
*/

SELECT A.*,
	   B.Customer_Name, B.Customer_Segment, B.Province, B.Region,
	   C.Order_Date, C.Order_Priority,
	   D.Order_ID, D.Ship_Date, D.Ship_Mode,
	   E.Product_Category, E.Product_Sub_Category
INTO combined_table
FROM market_fact A
LEFT JOIN cust_dimen B
ON A.Cust_id = B.Cust_id
LEFT JOIN orders_dimen C
ON A.Ord_id = C.Ord_id
LEFT JOIN shipping_dimen D
ON A.Ship_id = D.Ship_id
LEFT JOIN prod_dimen E
ON A.Prod_id = E.Prod_id

SELECT *
FROM combined_table

/*
2. Find the top 3 customers who have the maximum count of orders.
*/

SELECT TOP (3) Customer_Name, Cust_id,  COUNT(DISTINCT Ord_id) count_of_order
FROM combined_table
GROUP BY Customer_Name, Cust_id
ORDER BY count_of_order DESC

/*
3. Create a new column at combined_table as DaysTakenForDelivery 
that contains the date difference of Order_Date and Ship_Date.
*/

SELECT Order_Date, Ship_Date, DATEDIFF(DAY, Order_Date, Ship_Date) DaysTakenForDelivery
FROM combined_table

ALTER TABLE combined_table
ADD DaysTakenForDelivery INT;

UPDATE combined_table
SET DaysTakenForDelivery = DATEDIFF(DAY, Order_Date, Ship_Date)

SELECT *
FROM combined_table

/*
4. Find the customer whose order took the maximum time to get delivered.
*/

SELECT TOP 1 Customer_Name, DaysTakenForDelivery AS maxdays
FROM combined_table 
ORDER BY DaysTakenForDelivery DESC

/*
5. Count the total number of unique customers in January and
how many of them came back every month over the entire year in 2011
*/

WITH tbl AS(
SELECT DISTINCT Cust_id, Order_Date
FROM combined_table
WHERE MONTH(Order_Date) = '01'
) 
SELECT COUNT(DISTINCT Cust_id) count_of_customer
FROM tbl
WHERE YEAR(Order_Date) = '2011' AND
	  MONTH(Order_Date) IN ('01', '02','03','04','05','06','07','08','09','10','11','12')

/*
6. Write a query to return for each user the time elapsed between 
the first purchasing and the third purchasing, in ascending order by Customer ID.
*/

WITH tbl AS(
SELECT Cust_id, Customer_Name, Order_date,
	   ROW_NUMBER() OVER(PARTITION BY Cust_id ORDER BY Order_date) [row_number]
FROM combined_table
), tbl2 AS(
SELECT Cust_id, Order_Date
FROM tbl
WHERE [row_number] = 1
), tbl3 AS(
SELECT Cust_id, Order_Date
FROM tbl
WHERE [row_number] = 3
)
SELECT A.Cust_id, A.Order_date, DATEDIFF(DAY, A.Order_date, B.Order_date) day_numbers
FROM tbl2 A, tbl3 B
WHERE A.Cust_id = B.Cust_id
ORDER BY Cust_id

/*
7. Write a query that returns customers who purchased both product 11 and
product 14, as well as the ratio of these products to the total number of products purchased by the customer.
*/


SELECT Cust_id, Prod_id, SUM(Order_Quantity) total_prod_amount
FROM combined_table
WHERE Cust_id IN (SELECT Cust_id
				  FROM combined_table
				  WHERE Prod_id = 11
				  INTERSECT
				  SELECT Cust_id
				  FROM combined_table
				  WHERE Prod_id = 14
				  )
GROUP BY Cust_id, Prod_id
ORDER BY 1

---

WITH tbl AS(
SELECT Cust_id, Prod_id, SUM(Order_Quantity) total_prod_amount
FROM combined_table
WHERE Cust_id IN (SELECT Cust_id
				  FROM combined_table
				  WHERE Prod_id = 11
				  INTERSECT
				  SELECT Cust_id
				  FROM combined_table
				  WHERE Prod_id = 14
				  )
GROUP BY Cust_id, Prod_id
),tbl2 AS(
SELECT Cust_id, SUM(total_prod_amount) OVER(PARTITION BY Cust_id) total_amount
FROM tbl
),tbl3 AS(
SELECT Cust_id, SUM(total_prod_amount) OVER(PARTITION BY Cust_id) total_amount_11and14
FROM tbl
WHERE Prod_id IN (11, 14)
)
SELECT DISTINCT A.Cust_id, CAST((B.total_amount_11and14 * 1.0 / A.total_amount) AS NUMERIC(4,2)) ratio_of_11and14
FROM tbl2 A, tbl3 B
WHERE A.Cust_id = B.Cust_id

---

/*
Customer Segmentation 
Categorize customers based on their frequency of visits.
*/


/*
1. Create a “view” that keeps visit logs of customers on a monthly basis. 
(For each log, three field is kept: Cust_id, Year, Month)
*/

CREATE VIEW Visit_Logs_Of_Cust AS
SELECT DISTINCT Cust_id, YEAR(Order_Date) order_year, MONTH(Order_Date) order_month,
	   COUNT(Order_Date) OVER(PARTITION BY Cust_id, YEAR(Order_Date), MONTH(Order_Date)) Logs_on_Cust_Monthly
FROM combined_table

SELECT * FROM Visit_Logs_Of_Cust
ORDER BY Cust_id


/*
2. Create a “view” that keeps the number of monthly visits by users. 
(Show separately all months from the beginning business)
*/

CREATE VIEW Monthly_Visit AS 
SELECT DISTINCT Cust_id, DATENAME(M, Order_Date) month_name,
	   COUNT(Order_Date) OVER(PARTITION BY Cust_id , MONTH(Order_Date) ) monthly_visits
FROM combined_table

SELECT * 
FROM Monthly_Visit
ORDER BY 1, 2


/*
3. For each visit of customers, create the next month of the visit as a separate column.
*/

SELECT DISTINCT Cust_id, Order_Date,
	   LEAD(Order_Date) OVER(PARTITION BY Cust_id ORDER BY Order_Date) next_visit
FROM combined_table
ORDER BY Cust_id

/*
4. Calculate the monthly time gap between two consecutive visits by each customer.
*/


SELECT DISTINCT Cust_id, Order_Date,
	   LEAD(Order_Date) OVER(PARTITION BY Cust_id ORDER BY Order_Date) next_visit,
	   DATEDIFF(MONTH, Order_Date, LEAD(Order_Date) OVER(PARTITION BY Cust_id ORDER BY Order_Date)) month_diff
FROM combined_table
ORDER BY Cust_id


/*
5. Categorise customers using average time gaps. Choose the most fitted labeling model for you.
For example:
o Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase.
o Labeled as regular if the customer has made a purchase every month.
*/


WITH tbl AS(
SELECT DISTINCT Cust_id, Order_Date,
	   ROW_NUMBER() OVER(PARTITION BY Cust_id ORDER BY Order_Date) rownumber,
	   LEAD(Order_Date) OVER(PARTITION BY Cust_id ORDER BY Order_Date) next_visit,
	   DATEDIFF(MONTH, Order_Date, LEAD(Order_Date) OVER(PARTITION BY Cust_id ORDER BY Order_Date)) month_diff
FROM combined_table
ORDER BY Cust_id OFFSET 0 ROWS
), tbl2 AS(
SELECT DISTINCT Cust_id, 
	   COUNT(rownumber) OVER(PARTITION BY Cust_id) rows_count,
	   AVG(month_diff) OVER(PARTITION BY Cust_id) avg_month_diff
FROM tbl 
),tbl3 AS( 
SELECT Cust_id, rows_count, avg_month_diff
FROM tbl2
WHERE rows_count >= 2 AND avg_month_diff > 0
),tbl4 AS(
SELECT Cust_id, 
	   CAST((1.0 * rows_count / avg_month_diff) AS DECIMAL(4,2)) regular_cust_rate
FROM tbl3
)
SELECT *, 
	   CAST(AVG(regular_cust_rate) OVER() AS DECIMAL(4,2)) avg_regular_cust_rate
INTO regularity_table
FROM tbl4

--SELECT * FROM regularity_table

SELECT Cust_id, regular_cust_rate,
	   CASE 
		   WHEN regular_cust_rate >= 1.8 THEN 'Regular'
		   WHEN regular_cust_rate > 1 AND regular_cust_rate < 2 THEN 'Normal'
		   ELSE 'Churn' 
	   END cust_category
INTO cust_category
FROM regularity_table

SELECT * FROM cust_category

---

/*
Month-Wise Retention Rate
Find month-by-month customer retention rate since the start of the business.
*/

/*
1. Find the number of customers retained month-wise. (You can use time gaps)
2. Calculate the month-wise retention rate.
*/

SELECT M.month_name, COUNT(M.Cust_id) retained_cust
INTO retained_cust
FROM Monthly_Visit M, cust_category C
WHERE M.Cust_id = C.Cust_id AND 
	  C.cust_category IN ('Regular', 'Normal')
GROUP BY M.month_name
ORDER BY 1

--

SELECT M.month_name, COUNT(M.Cust_id) all_cust
INTO all_cust
FROM Monthly_Visit M, cust_category C
WHERE M.Cust_id = C.Cust_id 
GROUP BY M.month_name
ORDER BY 1

--

SELECT R.*, A.all_cust,
	   CAST((1.0 * retained_cust / all_cust) AS DECIMAL (4,2)) month_wise_retention_rate
FROM all_cust A, retained_cust R
WHERE A.month_name = R.month_name

--- END ---