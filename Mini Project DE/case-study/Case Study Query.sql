--========================== PRODUCT ANALYSIS ==========================
-- Total Order per Bulan Tahun 1997
WITH CTE_JOIN AS (
	SELECT OD.[OrderID]
		,P.ProductName
		,O.OrderDate
		,OD.[UnitPrice]
		,[Quantity]
		,[Discount]
	FROM [Northwind].[dbo].[Order Details] AS OD
	LEFT JOIN [Northwind].[dbo].[Orders] AS O
	ON OD.OrderID = O.OrderID
	LEFT JOIN [Northwind].[dbo].[Products] AS P
	ON OD.ProductID = P.ProductID
),
CTE_RESULT AS (
	SELECT 
		DATENAME(month, OrderDate) AS OrderMonth, 
		COUNT(DISTINCT OrderID) AS total_order 
	FROM CTE_JOIN
	WHERE DATEPART(year, OrderDate) = '1997'
	GROUP BY DATENAME(month, OrderDate)
)
SELECT *
FROM CTE_RESULT
ORDER BY CASE
	WHEN OrderMonth = 'January' THEN 1 
	WHEN OrderMonth = 'February' THEN 2 
	WHEN OrderMonth = 'March' THEN 3 
	WHEN OrderMonth = 'April' THEN 4
	WHEN OrderMonth = 'May' THEN 5
	WHEN OrderMonth = 'June' THEN 6
	WHEN OrderMonth = 'July' THEN 7
	WHEN OrderMonth = 'August' THEN 8
	WHEN OrderMonth = 'September' THEN 9
	WHEN OrderMonth = 'October' THEN 10
	WHEN OrderMonth = 'November' THEN 11
	WHEN OrderMonth = 'December' THEN 12
	END ASC

-- Top 10 Product dengan total penjualan tertinggi pada tahun 1997
WITH CTE_JOIN AS (
	SELECT OD.[OrderID]
		,P.ProductName
		,O.OrderDate
		,OD.[UnitPrice]
		,[Quantity]
		,[Discount]
	FROM [Northwind].[dbo].[Order Details] AS OD
	LEFT JOIN [Northwind].[dbo].[Orders] AS O
	ON OD.OrderID = O.OrderID
	LEFT JOIN [Northwind].[dbo].[Products] AS P
	ON OD.ProductID = P.ProductID
)
SELECT TOP 10 ProductName, SUM(Quantity) AS total_product_order
FROM CTE_JOIN 
WHERE DATEPART(year, OrderDate) = '1997'
GROUP BY ProductName
ORDER BY SUM(Quantity) DESC


--========================== CUSTOMER ANALYSIS ==========================
-- Top 10 Customer dengan total order terbanyak pada tahun 1997
SELECT TOP 10 
	CompanyName, 
	COUNT(DISTINCT OrderID) total_order
FROM (
	SELECT OD.[OrderID]
		,[ProductID]
		,[CompanyName]
		,[OrderDate]
		,[UnitPrice]
		,[Quantity]
		,[Discount]
	FROM [Northwind].[dbo].[Order Details] AS OD
	LEFT JOIN [Northwind].[dbo].[Orders] AS O
	ON OD.OrderID = O.OrderID
	LEFT JOIN [Northwind].[dbo].[Customers] AS C
	ON O.CustomerID = C.CustomerID
) AS A
WHERE DATEPART(year, OrderDate) = '1997'
GROUP BY CompanyName
ORDER BY COUNT(DISTINCT OrderID) DESC

-- Top 10 Customer dengan total spending tertinggi pada tahun 1997
WITH CTE_JOIN AS (
	SELECT OD.[OrderID]
		,[ProductID]
		,[CompanyName]
		,[OrderDate]
		,[UnitPrice]
		,[Quantity]
		,[Discount]
	FROM [Northwind].[dbo].[Order Details] AS OD
	LEFT JOIN [Northwind].[dbo].[Orders] AS O
	ON OD.OrderID = O.OrderID
	LEFT JOIN [Northwind].[dbo].[Customers] AS C
	ON O.CustomerID = C.CustomerID
)
SELECT TOP 10
	CompanyName, 
	ROUND(SUM((UnitPrice * Quantity) * (1 - Discount)), 2) AS total_spend
FROM CTE_JOIN
WHERE DATEPART(year, OrderDate) = '1997'
GROUP BY CompanyName
ORDER BY SUM((UnitPrice * Quantity) * (1 - Discount)) DESC


--========================== SHIPPER ANALYSIS ==========================
-- TOP 10 Kota dengan pengiriman orderan paling tinggi pada tahun 1997
SELECT TOP 10
	[ShipCity], 
	COUNT(DISTINCT OrderID) AS total_order
FROM (
	SELECT
		[OrderID]
		,[CompanyName]
		,[OrderDate]
		,[ShippedDate]
		,[ShipCity]
	FROM [Northwind].[dbo].[Orders] AS O
	LEFT JOIN [Northwind].[dbo].[Shippers] AS S
	ON O.ShipVia = S.ShipperID
) AS A
WHERE DATEPART(year, OrderDate) = '1997'
GROUP BY [ShipCity]
ORDER BY COUNT(DISTINCT OrderID) DESC


-- Jasa pengiriman yang paling banyak digunakan pada tahun 1997
SELECT [CompanyName], COUNT(DISTINCT OrderID) AS total_order
FROM (
	SELECT 
		[OrderID]
		,[CompanyName]
		,[OrderDate]
		,[ShippedDate]
		,[ShipCity]
	FROM [Northwind].[dbo].[Orders] AS O
	LEFT JOIN [Northwind].[dbo].[Shippers] AS S
	ON O.ShipVia = S.ShipperID
) AS A
WHERE DATEPART(year, OrderDate) = '1997'
GROUP BY [CompanyName]
ORDER BY COUNT(DISTINCT OrderID) DESC