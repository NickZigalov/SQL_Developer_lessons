/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/
/*
CREATE FUNCTION dbo.fGetMaxSumPurchase ()
RETURNS DECIMAL (18,2)
AS
BEGIN
	DECLARE @Result DECIMAL (18,2);
	SELECT @Result = 
		(select top 1 CustomerID/*, SUM(s.Sum) as [Sum]*/ from sales.Orders o
		join (select OrderID, SUM(Quantity*UnitPrice) as [Sum] from sales.OrderLines group by OrderID) s on s.OrderID=o.OrderID
		group by o.CustomerID
		order by SUM(s.Sum) desc)

	RETURN @Result;
END;
*/
CREATE FUNCTION dbo.fGetMaxSumPurchase ()
RETURNS TABLE
AS
RETURN
	(select top 1 CustomerID, SUM(s.Sum) as [Sum] from sales.Orders o
	join (select OrderID, SUM(Quantity*UnitPrice) as [Sum] from sales.OrderLines group by OrderID) s on s.OrderID=o.OrderID
	group by o.CustomerID
	order by SUM(s.Sum) desc
	);


select CustomerID, [Sum] from dbo.fGetMaxSumPurchase();


/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/
------Идея сделать через процедуру, которая вызывает функцию ------------
---- создаем табличную функцию с параметром ----
CREATE FUNCTION dbo.fGetSumPurchase (@CustomerID INT)
RETURNS TABLE
AS
RETURN
	(select c.CustomerName, o.CustomerID, SUM(s.Sum) as [Sum] from Sales.Invoices o
	join (select InvoiceID, SUM(Quantity*UnitPrice) as [Sum] from Sales.InvoiceLines group by InvoiceID) s on s.InvoiceID=o.InvoiceID
	join Sales.Customers c on c.CustomerID = o.CustomerID
	where o.CustomerID = @CustomerID
	group by c.CustomerName, o.CustomerID
	);

--select CustomerName, CustomerID, [Sum] from dbo.fGetSumPurchase(@CustomerID); //проверка

---- создаем процедуру ----
CREATE PROCEDURE [dbo].[uspGetCustomerSum] (@CustomerID INT)
AS 
	SELECT CustomerName, CustomerID, [Sum] from dbo.fGetSumPurchase(@CustomerID);


DECLARE @CustomerID INT;
SET @CustomerID = 444;

exec [dbo].[uspGetCustomerSum] @CustomerID

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/
-- функцию берем из прошлого задания --
-- создаем идентичную процедуру---
CREATE PROCEDURE [dbo].[uspGetCustomerSumInd] (@CustomerID INT)
AS 
	select c.CustomerName, o.CustomerID, SUM(s.Sum) as [Sum] from Sales.Invoices o
	join (select InvoiceID, SUM(Quantity*UnitPrice) as [Sum] from Sales.InvoiceLines group by InvoiceID) s on s.InvoiceID=o.InvoiceID
	join Sales.Customers c on c.CustomerID = o.CustomerID
	where o.CustomerID = @CustomerID
	group by c.CustomerName, o.CustomerID

-- вызов функции и процедуры 
DECLARE @CustomerID INT;
SET @CustomerID = 444; 


select CustomerName, CustomerID, [Sum] from dbo.fGetSumPurchase(@CustomerID);

exec [dbo].[uspGetCustomerSumInd] @CustomerID;
-- Согласно плану запроса, у меня стоимость запросов идентична. Возможно неправильно понял задание?

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

select c.CustomerName, c.CustomerID, f.[Sum] from Sales.Customers c
cross apply dbo.fGetSumPurchase(c.CustomerID) f


/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
-- во всех используемых процедурах считаю достаточным уроверь изоляции read committed, т.к. мы не производим изменения таблиц. Нужно только исключить незакомиченые транзакции.
*/
