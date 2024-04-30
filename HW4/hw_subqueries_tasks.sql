/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/
with a as (
select distinct SalespersonPersonID
from Sales.Invoices i
where i.InvoiceDate = '2015-07-04'
),
b as (
	select distinct PersonID, FullName
	from Application.People where IsSalesperson = 1
	)
select b.* from a
right join b on a.SalespersonPersonID = b.PersonID 
WHERE a.SalespersonPersonID is null
--from Sales.Invoices

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

  with a as (
  SELECT distinct [StockItemID]
      ,[Description]
      ,MIN([UnitPrice]) as MinPrice
  FROM [WideWorldImporters].[Sales].[InvoiceLines]
  GROUP BY [StockItemID],[Description]
  )
  select * from a;

  select * from (
			SELECT distinct 
				 [StockItemID]
				,[Description]
				,MIN([UnitPrice]) as MinPrice
			FROM [WideWorldImporters].[Sales].[InvoiceLines]
			GROUP BY [StockItemID],[Description]) a;


/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/


SELECT 
	CustomerID, CustomerName 
FROM [Sales].[Customers] c
WHERE 
	c.CustomerID IN (select top 5 WITH TIES CustomerID from Sales.CustomerTransactions ORDER BY AmountExcludingTax desc);

SELECT
	c.CustomerID, c.CustomerName 
FROM [Sales].[Customers] c
INNER JOIN (select top 5 WITH TIES CustomerID from Sales.CustomerTransactions ORDER BY AmountExcludingTax desc) ct on ct.CustomerID = c.CustomerID;


with a as (
select top 5 WITH TIES CustomerID, AmountExcludingTax from Sales.CustomerTransactions ORDER BY AmountExcludingTax desc
)
select distinct c.CustomerID, c.CustomerName from [Sales].[Customers] c 
inner join a on a.CustomerID = c.CustomerID;

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

set statistics time, io on;

 with a as (
  select il.InvoiceID ,il.StockItemID, mp.UnitPrice from [Sales].[InvoiceLines] il 
  INNER JOIN (SELECT distinct top 3 with ties [StockItemID], UnitPrice FROM [WideWorldImporters].[Sales].[InvoiceLines] ORDER BY [UnitPrice] desc) mp on mp.StockItemID = il.StockItemID --and il.StockItemID = 73
  ),
  b as (
  SELECT CustomerID, CustomerName, PostalAddressLine2, DeliveryCityID FROM [Sales].[Customers]
  )
  select a.StockItemID, a.UnitPrice, i.InvoiceID, b.DeliveryCityID as [CityCode], b.PostalAddressLine2 as [City], p.FullName as [PackedBy] from [WideWorldImporters].[Sales].[Invoices] i
  inner join a on i.InvoiceID = a.InvoiceID
  inner join b on i.CustomerID = b.CustomerID
  inner join [Application].[People] p on i.PackedByPersonID = p.PersonID
  --where i.InvoiceID = 191
  order by a.UnitPrice desc, a.StockItemID desc;
  
  --этот вариант, кажется, немного дольше
  with a as (
  select il.InvoiceID ,il.StockItemID, mp.UnitPrice from [Sales].[InvoiceLines] il 
  INNER JOIN (SELECT distinct top 3 with ties [StockItemID], UnitPrice FROM [WideWorldImporters].[Sales].[InvoiceLines] ORDER BY [UnitPrice] desc) mp on mp.StockItemID = il.StockItemID --and il.StockItemID = 73
  ),
  b as (
  SELECT CustomerID, CustomerName, PostalAddressLine2, DeliveryCityID FROM [Sales].[Customers]
  ),
  c as ( 
  select * from [Application].[People]
  )
  select a.StockItemID, a.UnitPrice, i.InvoiceID, b.DeliveryCityID as [CityCode], b.PostalAddressLine2 as [City], c.FullName as [PackedBy] from [WideWorldImporters].[Sales].[Invoices] i
  inner join a on i.InvoiceID = a.InvoiceID
  inner join b on i.CustomerID = b.CustomerID
  inner join c on i.PackedByPersonID = c.PersonID
  --where i.InvoiceID = 191
  order by a.UnitPrice desc, a.StockItemID desc;


-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

set statistics time, io on;

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC;

-- Первая идея (по производительности) была убрать подзапросы в JOIN, на примере первого стало видно, что это ускоряет незначительно--
/*
SELECT 
	i.InvoiceID, 
	i.InvoiceDate,
	p.FullName AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = 
			(SELECT Orders.OrderId FROM Sales.Orders WHERE Orders.PickingCompletedWhen IS NOT NULL AND Orders.OrderId = i.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices i
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON i.InvoiceID = SalesTotals.InvoiceID
	INNER JOIN (SELECT People.FullName, People.PersonID FROM Application.People) p on p.PersonID = i.SalespersonPersonID
ORDER BY TotalSumm DESC
--второе чтение 3:48
--SQL Server Execution Times:
--   CPU time = 123 ms,  elapsed time = 228358 ms.
*/


-- Дальше стал убирать подзапросы в CTE и убирать повторные чтения (например, таблицы Invoices), однако производительность только ухудшилась. Но улучшилась читаемость, как мне кажется.
-- По плану стоимость 49/51, а по статистике в последнем случае чтений немного меньше, но время больше.
WITH 
inv as (
	SELECT * FROM Sales.Invoices
),
b as (
	SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000
),
c as (
	SELECT OrderLines.PickedQuantity, OrderLines.UnitPrice, OrderLines.OrderId FROM Sales.OrderLines
	JOIN (SELECT o.OrderId FROM Sales.Orders o	WHERE o.PickingCompletedWhen IS NOT NULL) b on b.OrderId = OrderLines.OrderId
),
p as (
SELECT People.FullName, People.PersonID FROM Application.People
)
SELECT 
	inv.InvoiceID, 
	inv.InvoiceDate,
	p.FullName AS SalesPersonName,
	b.TotalSumm AS TotalSummByInvoice,
	SUM(c.PickedQuantity*c.UnitPrice) AS TotalSummForPickedItems
FROM inv
JOIN b ON inv.InvoiceID = b.InvoiceID
JOIN c on c.OrderId = inv.OrderId
JOIN p on p.PersonID = inv.SalespersonPersonID
GROUP BY 
	inv.InvoiceID, inv.InvoiceDate,	p.FullName, b.TotalSumm
ORDER BY TotalSumm DESC;
