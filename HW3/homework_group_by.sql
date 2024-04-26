/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select 
	YEAR(i.InvoiceDate) as [Year], MONTH(i.InvoiceDate) as [Month], AVG(il.UnitPrice) as AvgPrice, SUM(il.UnitPrice*il.Quantity) as SumPrice
from [Sales].[Invoices] i
inner join [Sales].[InvoiceLines] il on i.InvoiceID = il.InvoiceID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
ORDER BY 1, 2;


/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select 
	YEAR(i.InvoiceDate) as [Year], MONTH(i.InvoiceDate) as [Month], SUM(il.UnitPrice*il.Quantity) as SumPrice
from [Sales].[Invoices] i
inner join [Sales].[InvoiceLines] il on i.InvoiceID = il.InvoiceID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
HAVING SUM(il.UnitPrice*il.Quantity) > 4600000
ORDER BY 1, 2;

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select 
	YEAR(i.InvoiceDate) as [Year], 
	MONTH(i.InvoiceDate) as [Month], 
	il.Description,  
	SUM(il.UnitPrice*il.Quantity) as [SumPrice], 
	MIN(i.InvoiceDate) as [FirstSell],
	SUM(il.Quantity) as [SumQuantity]
from [Sales].[Invoices] i
inner join [Sales].[InvoiceLines] il on i.InvoiceID = il.InvoiceID
WHERE il.Quantity < 50
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), il.Description
HAVING SUM(il.Quantity) < 50
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), SUM(il.Quantity);

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/

select 
	pos.Year,
	pos.Month,
	pos.Description,
	coalesce(q.[SumPrice],0) as [SumPrice],
	coalesce(convert(varchar,q.[FirstSell]), N'нет продаж') as [FirstSell],
	coalesce(q.[SumQuantity], 0) as [SumQuantity]
from 
	(select distinct 
			YEAR(i.InvoiceDate) as [Year], 
			MONTH(i.InvoiceDate) as [Month],
			il.Description, 
			il.StockItemID  
		from [Sales].[InvoiceLines] il
		cross join [Sales].[Invoices] i) pos
left join
		(select 
			YEAR(i.InvoiceDate) as [Year], 
			MONTH(i.InvoiceDate) as [Month], 
			il.Description, il.StockItemID , 
			SUM(il.UnitPrice*il.Quantity) as [SumPrice], 
			MIN(i.InvoiceDate) as [FirstSell],
			SUM(il.Quantity) as [SumQuantity]
		from [Sales].[Invoices] i
		inner join [Sales].[InvoiceLines] il on i.InvoiceID = il.InvoiceID
		WHERE il.Quantity < 50
		GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), il.Description, il.StockItemID
		HAVING SUM(il.Quantity) < 50
		--ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), SUM(il.Quantity)
		) q on pos.StockItemID = q.StockItemID and pos.Year = q.Year and pos.Month = q.Month
ORDER BY pos.[Year], pos.[Month];

