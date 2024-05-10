/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/

--select CustomerID, CustomerName from [Sales].[Customers]


DECLARE @dml AS NVARCHAR(MAX)
DECLARE @ColumnName AS NVARCHAR(MAX)

 
SELECT @ColumnName = ISNULL(@ColumnName + ',','') 
                   + QUOTENAME(CustomerName)--заключаем в квадратные скобки
FROM (SELECT CustomerName
      FROM [Sales].[Customers] C
      ) AS Names

--SELECT @ColumnName as ColumnName 


SET @dml = 
  N'SELECT MonthStart, ' +@ColumnName + ' FROM
  (
  select  
			CustomerName,
			convert(varchar, datetrunc(month, i.InvoiceDate), 104) as MonthStart,
			COUNT(i.InvoiceID) as InvoiceCount
		from [Sales].[Invoices] i
		join [Sales].[Customers] c on i.customerid = c.CustomerID
		where i.customerid between 2 and 6
		group by  CustomerName, i.InvoiceDate
		 ) AS T
    PIVOT(SUM(InvoiceCount)
           FOR CustomerName IN (' + @ColumnName + ')) AS PVTTable
	ORDER BY YEAR(convert(date,MonthStart)), MONTH(convert(date,MonthStart)) '

EXEC sp_executesql @dml

-- хотел еще заменить NULL на 0, но не нашел вариантов в рамках этой конструкции

