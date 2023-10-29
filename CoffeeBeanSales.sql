

-- Understanding the tables

SELECT *
FROM [Personal Projects].dbo.customers$

SELECT *
FROM [Personal Projects].dbo.orders$

SELECT *
FROM [Personal Projects].dbo.products$

-- Reformatting 'Order Date' into a date formate

SELECT [Order Date], CONVERT(DATE,[Order Date])
FROM [Personal Projects].dbo.orders$

ALTER TABLE [Personal Projects].dbo.orders$
ALTER COLUMN [Order Date] DATE

-- Joining the table together

SELECT *
FROM [Personal Projects].dbo.customers$ AS c
LEFT JOIN [Personal Projects].dbo.orders$ AS o
ON c.[Customer ID] = o.[Customer ID]
LEFT JOIN [Personal Projects].dbo.products$ AS p
ON o.[Product ID] = p.[Product ID]

-- Creating TEMP Table with the result from the Join query

DROP TABLE if exists #CoffeeSales
CREATE TABLE #CoffeeSales
(
[Customer ID] nvarchar(255),
[Customer Name] nvarchar(255),
[City] nvarchar(255),
[Country] nvarchar(255),
[Loyalty Card] nvarchar(255),
[Order ID] nvarchar(255),
[Order Date] date,
[Product ID] nvarchar(255),
[Quantity] nvarchar(255),
[Coffee Type] nvarchar(255),
[Roast Type] nvarchar(255),
[Size] nvarchar(255),
[Unit Price] float,

[Profit] float
)

INSERT INTO #CoffeeSales
SELECT 
c.[Customer ID],
c.[Customer Name],
c.[City],
c.[Country],
c.[Loyalty Card],
o.[Order ID],
o.[Order Date],
o.[Product ID],
o.[Quantity],
p.[Coffee Type],
p.[Roast Type],
p.[Size],
p.[Unit Price],

p.[Profit]
FROM [Personal Projects].dbo.customers$ AS c
LEFT JOIN [Personal Projects].dbo.orders$ AS o
ON c.[Customer ID] = o.[Customer ID]
LEFT JOIN [Personal Projects].dbo.products$ AS p
ON o.[Product ID] = p.[Product ID]
WHERE [Order Date] IS NOT NULL

-------------------------------------------------------

-- A look at the data within temp table #CoffeeSales

SELECT *
FROM #CoffeeSales

-------------------------------------------------------

-- What is the total revenue and profit?

SELECT ROUND(SUM([Quantity] * [Unit Price]),2) AS total_revenue, ROUND(SUM(Profit),2) AS Profit
FROM #CoffeeSales

-------------------------------------------------------

-- What is the total revenue each year? 

SELECT YEAR([Order Date]) AS Order_Year, ROUND(SUM([Quantity] * [Unit Price]),2) AS total_revenue
FROM #CoffeeSales
GROUP BY YEAR([Order Date])


-------------------------------------------------------

-- What is the average revenue for each product category (Product ID) and What product had the highest revenue?
WITH ProductRev AS (
  SELECT
    [Product ID],
    ROUND(SUM([Quantity] * [Unit Price]), 2) AS total_revenue,
    YEAR([Order Date]) AS Order_Year  
  FROM #CoffeeSales
  GROUP BY [Product ID], YEAR([Order Date]) 
)
SELECT
  [Product ID],
  Order_Year,
  total_revenue,  -- You can use the alias directly in the SELECT
  ROUND(AVG(total_revenue) OVER (PARTITION BY Order_Year),2) AS Year_Avg_Revenue
FROM ProductRev
ORDER BY Order_Year;




-------------------------------------------------------

-- What is the average revenue for each product category (Product ID) in conjunction to its profit

WITH ProductRev AS (
  SELECT
    [Product ID],
    ROUND(SUM([Quantity] * [Unit Price]), 2) AS total_revenue
  FROM #CoffeeSales
  GROUP BY [Product ID]
),
ProductAvg AS (
SELECT
  [Product ID],
  total_revenue,
  AVG(total_revenue) OVER (PARTITION BY [Product ID]) AS Average_Revenue
FROM ProductRev
 
)
SELECT
  pa.[Product ID],
  MAX(pa.Average_Revenue) AS Average_Revenue,
  ROUND(SUM(cs.Profit),2) AS Total_Profit,
  CASE
	WHEN SUM(cs.Profit) >= 80 THEN 'High Profit'
	WHEN SUM(cs.Profit) >= 50 THEN 'Moderate Profit'
	ELSE 'Low Profit'
	END AS Profit_Category
FROM ProductAvg pa
JOIN #CoffeeSales cs ON pa.[Product ID] = cs.[Product ID]
GROUP BY pa.[Product ID]
ORDER BY MAX(pa.Average_Revenue) DESC

-------------------------------------------------------

-- What is the most popular Roast Type? 

SELECT COUNT(*), [Roast Type]
FROM #CoffeeSales
GROUP BY [Roast Type]

-------------------------------------------------------

-- What is the most popular Coffee Type? 

SELECT COUNT(*), [Coffee Type]
FROM #CoffeeSales
GROUP BY [Coffee Type]

-------------------------------------------------------

-- What is the sales like between loyalty and non-loyalty 
SELECT
	[Loyalty Card],
	ROUND(SUM([Quantity] * [Unit Price]),2) AS TotalSales,
	ROUND(SUM(Profit),2) AS TotalProfit
FROM #CoffeeSales
GROUP BY [Loyalty Card];

-------------------------------------------------------

-- What is the sales and profit like countries?
SELECT
	[Country],
	ROUND(SUM([Quantity] * [Unit Price]),2) AS TotalSales,
	ROUND(SUM(Profit),2) AS TotalProfit
FROM #CoffeeSales
GROUP BY [Country];

-------------------------------------------------------

-- Creating a table for easier dashboard building via PowerBI 

CREATE TABLE CoffeeSalesData
(
    [Customer ID] nvarchar(255),
    [Customer Name] nvarchar(255),
    [City] nvarchar(255),
    [Country] nvarchar(255),
    [Loyalty Card] nvarchar(255),
    [Order ID] nvarchar(255),
    [Order Date] date,
    [Product ID] nvarchar(255),
    [Quantity] int,
    [Coffee Type] nvarchar(255),
    [Roast Type] nvarchar(255),
    [Size] nvarchar(255),
    [Unit Price] float,
    [Profit] float
)

INSERT INTO CoffeeSalesData

-- Below to be use in PowerBI
SELECT 
c.[Customer ID],
c.[Customer Name],
c.[City],
c.[Country],
c.[Loyalty Card],
o.[Order ID],
o.[Order Date],
o.[Product ID],
o.[Quantity],
p.[Coffee Type],
p.[Roast Type],
p.[Size],
p.[Unit Price],

p.[Profit]
FROM [Personal Projects].dbo.customers$ AS c
LEFT JOIN [Personal Projects].dbo.orders$ AS o
ON c.[Customer ID] = o.[Customer ID]
LEFT JOIN [Personal Projects].dbo.products$ AS p
ON o.[Product ID] = p.[Product ID]
WHERE [Order Date] IS NOT NULL


-------------------------------------------------------

-- Checking the table

SELECT * 
FROM CoffeeSalesData