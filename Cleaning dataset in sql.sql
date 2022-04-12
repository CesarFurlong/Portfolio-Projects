------ Data Cleaning
------ First glance dataset

SELECT * 
FROM sales

------ Standarize date format
DROP COLUMN IF EXISTS order_date, year

ALTER TABLE sales
ADD order_date Date
ADD year DATE

UPDATE sales 
SET order_date = strftime('%Y-%m-%d', OrderDate)
SET year = strftime('%Y', OrderDate)

SELECT order_date, OrderDate
FROM sales 

------ Split Address column (state, zipcode)

ALTER TABLE sales
ADD state varchar(255)
ADD zipcode varchar(5)
ADD street varchar (20)

UPDATE sales
SET state = substr(PurchaseAddress, -8,2)
SET zipcode = substr(PurchaseAddress, -5)
SET street = substr(PurchaseAddress, 1, instr(PurchaseAddress,',')-1)

SELECT street, City, state, zipcode
FROM sales
 
------ Checking for duplicates entries

SELECT count (OrderID) AS num_duplicates
FROM (
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY order_date, Product, QuantityOrdered, PurchaseAddress, PriceEach, Sales, City ORDER BY OrderID) AS row_num
FROM sales)
WHERE row_num = 2

-------- Delete 269 duplicate values

DROP TABLE IF EXISTS new_sales

CREATE TEMP TABLE new_sales AS 
SELECT OrderID, order_date, year, Month, Product, QuantityOrdered, PriceEach, Sales, PurchaseAddress, street, City, state, zipcode 
FROM (
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY order_date, Product, QuantityOrdered, PurchaseAddress, PriceEach, Sales, City ORDER BY OrderID) AS row_num
FROM sales
)
WHERE row_num = 1

------ Removing unused columns

ALTER TABLE new_sales
DROP COLUMN OrderDate, row_num;

SELECT *
FROM new_sales
ORDER BY order_date 
LIMIT 100 