-- 1. Jumlah customer tiap bulan pada tahun 1997
WITH CTE_RESULT AS(
SELECT 
	DATENAME(MONTH, OrderDate) AS month, 
	COUNT(DISTINCT CustomerID) AS number_of_customer
FROM [Northwind].[dbo].[Orders]
WHERE DATEPART(year, OrderDate) = '1997'
GROUP BY DATENAME(MONTH, OrderDate)
)
SELECT *
FROM CTE_RESULT
ORDER BY CASE
	WHEN month = 'January' THEN 1 
	WHEN month = 'February' THEN 2 
	WHEN month = 'March' THEN 3 
	WHEN month = 'April' THEN 4
	WHEN month = 'May' THEN 5
	WHEN month = 'June' THEN 6
	WHEN month = 'July' THEN 7
	WHEN month = 'August' THEN 8
	WHEN month = 'September' THEN 9
	WHEN month = 'October' THEN 10
	WHEN month = 'November' THEN 11
	WHEN month = 'December' THEN 12
	END ASC


-- 2. Nama Employee yang termasuk Sales Representative
SELECT CONCAT(FirstName, ' ', LastName) AS EmployeeName
FROM [Northwind].[dbo].[Employees]
WHERE Title = 'Sales Representative'


-- 3. Top 5 nama produk yang quantitynya paling banyak diorder pada bulan Januari 1997
SELECT TOP 5
	P.ProductName, 
	SUM(OD.Quantity) AS Quantity
FROM [Northwind].[dbo].[Order Details] AS OD
LEFT JOIN [Northwind].[dbo].[Products] AS P
ON OD.ProductID = P.ProductID
WHERE OD.OrderID IN 
	(
	SELECT DISTINCT [OrderID]
	FROM [Northwind].[dbo].[Orders]
	WHERE OrderDate BETWEEN '1997-01-01' AND '1997-01-31'
	)
GROUP BY P.ProductName
ORDER BY SUM(OD.Quantity) DESC


-- 4. Nama company yang melakukan order Chai pada bulan Juni 1997.
SELECT *
FROM [Northwind].[dbo].[Customers]
WHERE CustomerID IN (
	SELECT CustomerID
	FROM [Northwind].[dbo].[Orders]
	WHERE OrderDate BETWEEN '1997-06-01'AND '1997-06-30'
	AND OrderID IN (
		SELECT DISTINCT [OrderID]
		FROM [Northwind].[dbo].[Order Details]
		WHERE ProductID = (
			SELECT ProductID
			FROM [Northwind].[dbo].[Products]
			WHERE ProductName = 'Chai')
  )	
)


-- 5. Jumlah OrderID yang pernah melakukan pembelian (unit_price dikali quantity) <=100, 100<x<=250, 250<x<=500, dan >500.
WITH CTE_TOTAL_SALES AS (
SELECT *,
	CASE 
		WHEN UnitPrice * Quantity <= 100 THEN '<=100'
		WHEN UnitPrice * Quantity > 100 AND UnitPrice * Quantity <= 250 THEN '100<x<=250'
		WHEN UnitPrice * Quantity > 250 AND UnitPrice * Quantity <= 500 THEN '250<x<=500'
		ELSE '>500'
	END AS total_sales
FROM [Northwind].[dbo].[Order Details]
)
SELECT 
	total_sales, 
	COUNT(DISTINCT OrderID) AS number_of_order
FROM CTE_TOTAL_SALES
GROUP BY total_sales
ORDER BY 
	CASE total_sales
    	WHEN '<=100' THEN 1
    	WHEN '100<x<=250' THEN 2
    	WHEN '250<x<=500' THEN 3
	WHEN '>500' THEN 4
    ELSE 0
END ASC


-- 6. Company name yang melakukan pembelian di atas 500 pada tahun 1997.
SELECT CompanyName
FROM [Northwind].[dbo].[Customers]
WHERE CustomerID IN (
	SELECT 
	CustomerID
	FROM [Northwind].[dbo].[Orders] AS O
	LEFT JOIN [Northwind].[dbo].[Order Details] AS OD
	ON O.OrderID = OD.OrderID
	WHERE DATEPART(year, O.OrderDate) = '1997'
	GROUP BY CustomerID
	HAVING SUM(UnitPrice) > 500
	)


-- 7. Nama produk yang merupakan Top 5 sales tertinggi tiap bulan di tahun 1997.
WITH CTE_SALES AS (
SELECT 
	OD.OrderID, 
	OD.ProductID, 
	OrderDate, 
	(OD.UnitPrice * OD.Quantity) * (1-OD.Discount) AS total_sales
FROM [Northwind].[dbo].[Orders] AS O
RIGHT JOIN [Northwind].[dbo].[Order Details] AS OD
ON O.OrderID = OD.OrderID
WHERE DATEPART(year, O.OrderDate) = '1997'
), CTE_PARTITION AS (
SELECT DATENAME(month, OrderDate) AS month, ProductID, SUM(total_sales) AS total_sales
FROM CTE_SALES
GROUP BY DATENAME(month, OrderDate), ProductID
), CTE_RESULT AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY month ORDER BY total_sales DESC) AS row_num
FROM CTE_PARTITION
), CTE_RESULT_FINAL AS (
SELECT *
FROM CTE_RESULT
WHERE row_num IN (1, 2, 3, 4, 5)
)
SELECT month, P.ProductName, total_sales
FROM CTE_RESULT_FINAL AS CRF 
LEFT JOIN [Northwind].[dbo].[Products] AS P
ON CRF.ProductID = P.ProductID
ORDER BY CASE
	WHEN month = 'January' THEN 1 
	WHEN month = 'February' THEN 2 
	WHEN month = 'March' THEN 3 
	WHEN month = 'April' THEN 4
	WHEN month = 'May' THEN 5
	WHEN month = 'June' THEN 6
	WHEN month = 'July' THEN 7
	WHEN month = 'August' THEN 8
	WHEN month = 'September' THEN 9
	WHEN month = 'October' THEN 10
	WHEN month = 'November' THEN 11
	WHEN month = 'December' THEN 12
	END ASC


-- 8. Buatlah view untuk melihat Order Details yang berisi OrderID, ProductID, ProductName, UnitPrice, Quantity, Discount, Harga setelah diskon.
CREATE VIEW View_Order_Detail AS
SELECT 
     [OrderID]
    ,OD.[ProductID]
    ,P.[ProductName]
    ,OD.[UnitPrice]
    ,[Quantity]
    ,[Discount]
    ,(OD.UnitPrice * Quantity) * (1 - Discount) AS total_price
FROM [Northwind].[dbo].[Order Details] AS OD
LEFT JOIN [Northwind].[dbo].[Products] AS P
ON OD.ProductID = P.ProductID

-- 9. Buatlah procedure Invoice untuk memanggil CustomerID, CustomerName/company name, OrderID, OrderDate, RequiredDate, ShippedDate jika terdapat inputan CustomerID tertentu.
CREATE PROCEDURE [dbo].[SP_Customer_Order_Detail]
	-- Add the parameters for the stored procedure here
	@CUST_ID VARCHAR(20)
AS
BEGIN
	SELECT O.[CustomerID]
      	  ,[CompanyName]
	  ,[OrderID]
	  ,[OrderDate]
          ,[RequiredDate]
          ,[ShippedDate]
	FROM [Northwind].[dbo].[Customers] AS C
	RIGHT JOIN [Northwind].[dbo].[Orders] AS O
	ON C.CustomerID = O.CustomerID
	WHERE O.[CustomerID] = @CUST_ID
END
