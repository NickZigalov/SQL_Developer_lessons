/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
-- ---------------------------------------------------------------------------

USE WideWorldImporters
/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

set statistics time, io on;

with t as (
SELECT  
	i.InvoiceID, i.CustomerID, c.CustomerName, i.InvoiceDate, SUM(il.UnitPrice*il.Quantity) as InvoiceSaleSum,
	(
	SELECT SUM(il2.UnitPrice*il2.Quantity)  
	FROM [Sales].[Invoices] i2
	JOIN [Sales].[InvoiceLines] il2 on i2.InvoiceID = il2.InvoiceID
	WHERE i2.CustomerID = i.CustomerID and EOMONTH(i.InvoiceDate)=EOMONTH(i2.InvoiceDate)
	GROUP BY EOMONTH(i2.InvoiceDate)
	) as TotalMonthSaleSum
FROM 
	[Sales].[Invoices] i
JOIN [Sales].[InvoiceLines] il on i.InvoiceID = il.InvoiceID
JOIN [Sales].[Customers] c on i.CustomerID = c.CustomerID
WHERE 
	i.InvoiceDate >= '2015-01-01'
	and	i.CustomerID = 4
GROUP BY 
	i.InvoiceID, i.CustomerID, c.CustomerName, i.InvoiceDate
),
t1 as (
	select *,
	(select SUM(Tsum)  from 
						(select CustomerID, EOMONTH(InvoiceDate) InvoiceDate, AVG(TotalMonthSaleSum) as TSum from t
						group by CustomerID, EOMONTH(InvoiceDate)) q1  where q.CustomerID = q1.CustomerID and EOMONTH(q.InvoiceDate) >= EOMONTH(q1.InvoiceDate)) as TQSum
	from 
			(select CustomerID, EOMONTH(InvoiceDate) InvoiceDate, AVG(TotalMonthSaleSum) as TSum from t
			group by CustomerID, EOMONTH(InvoiceDate)) q

)
SELECT t.*, t1.TQSum
FROM t
JOIN t1 on t.CustomerID = t1.CustomerID and EOMONTH(t.InvoiceDate) = EOMONTH(t1.InvoiceDate)
ORDER BY t.CustomerID, t.InvoiceDate
;
	
/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

WITH a as (
SELECT  
	i.InvoiceID, i.CustomerID, c.CustomerName, i.InvoiceDate, SUM(il.UnitPrice*il.Quantity) as InvoiceSaleSum
FROM 
	[Sales].[Invoices] i
JOIN [Sales].[InvoiceLines] il on i.InvoiceID = il.InvoiceID
JOIN [Sales].[Customers] c on i.CustomerID = c.CustomerID
WHERE 
	i.InvoiceDate >= '2015-01-01' and 
	i.CustomerID = 4
GROUP BY 
	i.InvoiceID, i.CustomerID, c.CustomerName, i.InvoiceDate
)
SELECT 
	*, 
	SUM(InvoiceSaleSum) OVER (PARTITION BY CustomerID ORDER BY EOMONTH(InvoiceDate)) as TotalMonthSaleSum
FROM a
ORDER BY CustomerID, InvoiceDate



/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

WITH a as (
SELECT  
	EOMONTH(i.InvoiceDate) as [Period], il.[Description], COUNT(il.StockItemID) as GoodsCount
	,dense_rank() OVER(PARTITION BY EOMONTH(i.InvoiceDate) ORDER BY COUNT(il.StockItemID) desc) as GoodsRating
FROM 
	[Sales].[Invoices] i
JOIN [Sales].[InvoiceLines] il on i.InvoiceID = il.InvoiceID
WHERE 
	i.InvoiceDate BETWEEN '2016-01-01' and '2016-12-31'
GROUP BY 
	EOMONTH(i.InvoiceDate), il.Description, il.StockItemID
--ORDER BY EOMONTH(i.InvoiceDate),  COUNT(il.StockItemID) desc
)
SELECT 
	Period, Description, GoodsCount, GoodsRating
FROM a
WHERE GoodsRating <=2
ORDER BY [Period], GoodsCount desc

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
*/
SELECT	
	[StockItemID]
	,[StockItemName]
	,[Brand]
	,[UnitPrice]
	,TotalGoodsCount
	,count([StockItemName]) over(order by lnum) as lnumGoodsCount
FROM
	(SELECT  [StockItemID]
      ,[StockItemName]
	  ,Brand
      ,[UnitPrice]
	  ,dense_rank () over ( order by LEFT([StockItemName],1)) as lnum
	  ,(select count([StockItemName]) from [Warehouse].[StockItems]) AS TotalGoodsCount
  FROM [WideWorldImporters].[Warehouse].[StockItems] ) as q

/*
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"*/

SELECT  [StockItemID]
	  ,lead([StockItemID],1) over ( order by [StockItemName]) as NextStockId
	  ,lag([StockItemID],1) over ( order by [StockItemName]) as PrevStockId
      ,[StockItemName]
	  ,[Brand]
	  ,CASE 
		WHEN lag([StockItemName],2) over(order by [StockItemName]) IS NULL THEN 'No items' 
		ELSE lag([StockItemName],2) over(order by [StockItemName]) END as PrevName
      ,[UnitPrice]
  FROM [WideWorldImporters].[Warehouse].[StockItems] 
  ORDER BY 
  [StockItemName]


/*
--* сформируйте 30 групп товаров по полю вес товара на 1 шт
Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/


SELECT  [StockItemID]
      ,[StockItemName]
      ,TypicalWeightPerUnit
	  ,ntile(30) over (order by TypicalWeightPerUnit) as WeightGroup
  FROM [WideWorldImporters].[Warehouse].[StockItems]



/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/
select  q.SalespersonPersonID, sp.FullName as SalesPersonName ,q.CustomerID, cus.CustomerName as CustomerName 
,q.InvoiceDate, SUM(il.UnitPrice*il.Quantity) as InvoiceSaleSum
from (
	select  i.InvoiceID,i.CustomerID, i.SalespersonPersonID, i.InvoiceDate,
	row_number() over(partition by i.SalespersonPersonID order by i.InvoiceDate desc) as rnum
	FROM [WideWorldImporters].[Sales].[Invoices] i
	--where i.SalespersonPersonID = 2
	) as q
join [Application].[People] as sp on sp.PersonID = q.SalespersonPersonID
join [Sales].[Customers] as cus on cus.CustomerID = q.CustomerID
join [Sales].[InvoiceLines] il on q.InvoiceID = il.InvoiceID
where
	rnum = 1
GROUP BY q.SalespersonPersonID, sp.FullName ,q.CustomerID, cus.CustomerName,q.InvoiceDate
ORDER BY SalespersonPersonID


/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

		
with a as (
		SELECT 
			q.CustomerID, q.CustomerName, q.Description, q.StockItemID, q.InvoiceSaleSum,
			dense_rank() over (partition by CustomerName order by q.InvoiceSaleSum desc) as SaleRank
		FROM (
				select 
				i.InvoiceID, i.CustomerID, cus.CustomerName, i.InvoiceDate, il.StockItemID ,il.Description, SUM(il.UnitPrice*il.Quantity) as InvoiceSaleSum
				,row_number() over (partition by cus.CustomerName, il.Description order by SUM(il.UnitPrice*il.Quantity) desc) as rnum
				--,dense_rank() over (partition by cus.CustomerName order by SUM(il.UnitPrice*il.Quantity) desc) as SaleRank
				from [Sales].[Invoices] i 
				join [Sales].[Customers] cus on i.CustomerID = cus.CustomerID
				join [Sales].[InvoiceLines] il on il.InvoiceID = i.InvoiceID 
				GROUP BY 
					i.InvoiceID, i.CustomerID, cus.CustomerName, i.InvoiceDate, il.StockItemID, il.Description
		) q
		where rnum = 1
)
select * from a where SaleRank <=2

