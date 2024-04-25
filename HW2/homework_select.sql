/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

select StockItemID, StockItemName
from Warehouse.StockItems
where StockItemName like '%urgent%' or StockItemName like 'Animal%';

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

select s.SupplierID, s.SupplierName
from Purchasing.Suppliers s
left join Purchasing.PurchaseOrders p on s.SupplierID = p.SupplierID where p.PurchaseOrderID is null
order by s.SupplierID;

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

--Объемы данных не существенны, но первый вариант отрабатывает чуть быстрее судя по плану запроса (без row_num, она для красоты). Интересно Ваше мнение, возможно неправильно оценил план.
--Не нашел функцию, которая высчитывает из даты треть года, поэтому сделал через CASE на скорую руку

DECLARE @pagesize BIGINT = 100, -- Размер страницы
	@pagenum BIGINT = 11;-- Номер страницы
select 
	ROW_NUMBER() OVER(ORDER BY OrderID ASC) as RowNum,
	OrderID, 
	convert(varchar,OrderDate,104) as 'Дата заказа',
	datepart(quarter,OrderDate) as Квартал,
	CASE 
		WHEN datepart(month,OrderDate) in (1,2,3,4) THEN N'1 треть'
		WHEN datepart(month,OrderDate) in (5,6,7,8) THEN N'2 треть'
		WHEN datepart(month,OrderDate) in (9,10,11,12) THEN N'3 треть'
		END as 'Треть года',
	CustomerName 
from (
		select  
			o.OrderID, 
			o.OrderDate, 
			c.CustomerName, 
			SUM(ol.Quantity) as qsum--т.к. есть условие, что в заказе должно быть больше 20 товаров, но в одном заказе может быть n-позиций нужно убедиться, что количество по всему заказу больше 20   
		from Sales.Orders o
		left join Sales.OrderLines ol on o.OrderID = ol.OrderID
		left join sales.Customers c on o.CustomerID = c.CustomerID
		where ol.UnitPrice > 100 and ol.PickingCompletedWhen is not null
		group by o.OrderID, o.OrderDate, c.CustomerName
		) q
where qsum >20
ORDER BY ROW_NUMBER() OVER(ORDER BY OrderID ASC) OFFSET(@pagenum - 1) * @pagesize ROWS 
FETCH NEXT @pagesize ROWS ONLY;

-----------------------------------------------------------------------------------------------------------------------------------------------
--DECLARE @pagesize BIGINT = 100, -- Размер страницы
--	@pagenum BIGINT = 11;-- Номер страницы
select  
	o.OrderID, 
	convert(varchar,OrderDate,104) as 'Дата заказа',
	datepart(quarter,OrderDate) as Квартал,
	CASE 
		WHEN datepart(month,OrderDate) in (1,2,3,4) THEN N'1 треть'
		WHEN datepart(month,OrderDate) in (5,6,7,8) THEN N'2 треть'
		WHEN datepart(month,OrderDate) in (9,10,11,12) THEN N'3 треть'
		END as 'Треть года', 
	c.CustomerName 
	--SUM(ol.Quantity) --т.к. есть условие, что в заказе должно быть больше 20 товаров, но в одном заказе может быть n-позиций нужно убедиться, что количество по всему заказу больше 20   
from Sales.Orders o
left join Sales.OrderLines ol on o.OrderID = ol.OrderID
left join sales.Customers c on o.CustomerID = c.CustomerID
where ol.UnitPrice > 100 and ol.PickingCompletedWhen is not null
group by o.OrderID, o.OrderDate, c.CustomerName
HAVING SUM(ol.Quantity) >20
ORDER BY o.OrderID OFFSET(@pagenum - 1) * @pagesize ROWS 
FETCH NEXT @pagesize ROWS ONLY;

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

select 
	dm.DeliveryMethodName,
	ExpectedDeliveryDate,
	s.SupplierName,
	p.FullName
from Purchasing.PurchaseOrders po
	left join Purchasing.Suppliers s on po.SupplierID = s.SupplierID
	left join Application.DeliveryMethods dm on po.DeliveryMethodID = dm.DeliveryMethodID
	left join Application.People p on po.ContactPersonID = p.PersonID
where
	po.ExpectedDeliveryDate BETWEEN '2013-01-01' and '2013-01-31'
	AND po.IsOrderFinalized = 1
	AND (dm.DeliveryMethodName = 'Air Freight' or dm.DeliveryMethodName = 'Refrigerated Air Freight')

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

select top 10
	o.OrderID,
	o.OrderDate,
	c.CustomerName,
	p.FullName, o.*
from [Sales].[Orders] o
	left join [Sales].[Customers] c on o.CustomerID = c.CustomerID
	left join Application.People p on o.SalespersonPersonID = p.PersonID
order by o.OrderDate desc, o.OrderID desc



/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

select distinct
	o.CustomerID,
	c.CustomerName,
	c.PhoneNumber
from [Sales].[Orders] o
	left join [Sales].[OrderLines] ol on o.OrderID = ol.OrderID
	left join Warehouse.StockItems si on ol.StockItemID = si.StockItemID and si.StockItemName = 'Chocolate frogs 250g'
	left join [Sales].[Customers] c on o.CustomerID = c.CustomerID
order by CustomerName

