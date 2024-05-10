/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

select 
	MonthStart, 
	SUM([Sylvanite, MT]) as [Sylvanite, MT],
	SUM([Peeples Valley, AZ]) as [Peeples Valley, AZ],
	SUM([Medicine Lodge, KS]) as [Medicine Lodge, KS],
	SUM([Gasport, NY]) as [Gasport, NY],
	SUM([Jessie, ND] ) as  [Jessie, ND]
from
(
		select  
			i.CustomerID,
			SUBSTRING(
					CustomerName,
					CHARINDEX('(',customername,1)+1,
					LEN(RIGHT(CustomerName,LEN(CustomerName)-CHARINDEX('(',customername,1)))-1) as CustDist,
			datetrunc(month, i.InvoiceDate) as MonthStart, 
			i.InvoiceID
		from [Sales].[Invoices] i
		join [Sales].[Customers] c on i.customerid = c.CustomerID
		where
		 i.CustomerID BETWEEN 2 and 6) as SourceTable
pivot
(
count(invoiceid) for CustDist in (
									[Sylvanite, MT],
									[Peeples Valley, AZ],
									[Medicine Lodge, KS],
									[Gasport, NY],
									[Jessie, ND]
									)
)
as PivotTable
GROUP BY MonthStart
/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/
--сделал в двух вариантах, что посмотреть стоимость. Результат 84%/16% в пользу unpivot
select * from (
		select c.CustomerName, c.DeliveryAddressLine1 as AddressLine
		from [Sales].[Customers] c
		where
			c.CustomerName like 'Tailspin Toys%'
		union all
		select c.CustomerName, c.DeliveryAddressLine2 as AddressLine
		from [Sales].[Customers] c
		where
			c.CustomerName like 'Tailspin Toys%'
		union all
		select c.CustomerName, c.PostalAddressLine1 as AddressLine
		from [Sales].[Customers] c
		where
			c.CustomerName like 'Tailspin Toys%'
		union all
		select c.CustomerName, c.PostalAddressLine2 as AddressLine
		from [Sales].[Customers] c
		where
			c.CustomerName like 'Tailspin Toys%'
		)q
order by CustomerName

select CustomerName, valuekol as AddressLine--,AddressLine
from
		(select CustomerName, DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2
		from [Sales].[Customers] c
		where c.CustomerName like 'Tailspin Toys%') as PivotTable
unpivot
(
valuekol for AddressLine in (DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2)
) as T_unpivot

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

select CountryID, CountryName,  valuecol as Code--,AddressLine
from (
		select CountryID, CountryName, IsoAlpha3Code, convert(nvarchar(3),IsoNumericCode ) as IsoNumericCode
		from Application.Countries
) as pivotTable
unpivot
(
valuecol for code in (IsoAlpha3Code, IsoNumericCode)
) as unpivotTable
/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

select c.CustomerID,c.CustomerName, ca.[UnitPrice]
from [Sales].[Customers] c
CROSS APPLY (
	select top 2 with TIES il.[UnitPrice], i.CustomerID
	from [Sales].[InvoiceLines] il
	join [Sales].[Invoices] i on i.InvoiceID=il.InvoiceID
	--where c.CustomerID = i.CustomerID
	order by i.CustomerID, il.[UnitPrice] desc
	) as ca


select c.CustomerID,c.CustomerName, ca.[UnitPrice]
from [Sales].[Customers] c
CROSS APPLY (
	select distinct top 2il.[UnitPrice], i.CustomerID
	from [Sales].[InvoiceLines] il
	join [Sales].[Invoices] i on i.InvoiceID=il.InvoiceID
	where c.CustomerID = i.CustomerID
	order by il.[UnitPrice] desc
	) as ca