
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

SELECT TOP (3) Customer_Name, Cust_id,  COUNT(Ord_id) count_of_order
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
SELECT COUNT(Cust_id) count_of_customer
FROM tbl
WHERE YEAR(Order_Date) = '2011' AND
	  MONTH(Order_Date) IN ('01', '02','03','04','05','06','07','08','09','10','11','12')
































