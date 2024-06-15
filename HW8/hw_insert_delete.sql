/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/
INSERT INTO [Sales].[Customers]
			(
			[CustomerID]
           ,[CustomerName]
           ,[BillToCustomerID]
           ,[CustomerCategoryID]
           ,[BuyingGroupID]
           ,[PrimaryContactPersonID]
           ,[AlternateContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[CreditLimit]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[DeliveryRun]
           ,[RunPosition]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryAddressLine2]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalAddressLine2]
           ,[PostalPostalCode]
           ,[LastEditedBy])
VALUES
(NEXT VALUE FOR Sequences.[CustomerID],'Name1', 1, 3, 1, 1007, 1008,	3, 21692, 21692, 0, getdate(), 0, 0, 0, 7, '(423) 555-0100', '(423) 555-0101', '', '', '', '', '', 'xxxx', NULL, '', '', '', 1),
(NEXT VALUE FOR Sequences.[CustomerID],'Name2', 1, 3, 1, 1007, 1008,	3, 21692, 21692, 0, getdate(), 0, 0, 0, 7, '(423) 555-0100', '(423) 555-0101', '', '', '', '', '', 'xxxx', NULL, '', '', '', 1),
(NEXT VALUE FOR Sequences.[CustomerID],'Name3', 1, 3, 1, 1007, 1008,	3, 21692, 21692, 0, getdate(), 0, 0, 0, 7, '(423) 555-0100', '(423) 555-0101', '', '', '', '', '', 'xxxx', NULL, '', '', '', 1),
(NEXT VALUE FOR Sequences.[CustomerID],'Name4', 1, 3, 1, 1007, 1008,	3, 21692, 21692, 0, getdate(), 0, 0, 0, 7, '(423) 555-0100', '(423) 555-0101', '', '', '', '', '', 'xxxx', NULL, '', '', '', 1),
(NEXT VALUE FOR Sequences.[CustomerID],'Name5', 1, 3, 1, 1007, 1008,	3, 21692, 21692, 0, getdate(), 0, 0, 0, 7, '(423) 555-0100', '(423) 555-0101', '', '', '', '', '', 'xxxx', NULL, '', '', '', 1)
;

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE FROM [Sales].[Customers] WHERE [CustomerName] = 'Name3';


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE [Sales].[Customers] SET [FaxNumber] = '(423) 111-22-33' WHERE [CustomerName] = 'Name4';

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/
--DROP TABLE IF EXISTS [Sales].[CustomersMergeSource];

CREATE TABLE [Sales].[CustomersMergeSource](
	[CustomerID] [int] NOT NULL,
	[CustomerName] [nvarchar](100) NOT NULL,
	[BillToCustomerID] [int] NOT NULL,
	[CustomerCategoryID] [int] NOT NULL,
	[BuyingGroupID] [int] NULL,
	[PrimaryContactPersonID] [int] NOT NULL,
	[AlternateContactPersonID] [int] NULL,
	[DeliveryMethodID] [int] NOT NULL,
	[DeliveryCityID] [int] NOT NULL,
	[PostalCityID] [int] NOT NULL,
	[CreditLimit] [decimal](18, 2) NULL,
	[AccountOpenedDate] [date] NOT NULL,
	[StandardDiscountPercentage] [decimal](18, 3) NOT NULL,
	[IsStatementSent] [bit] NOT NULL,
	[IsOnCreditHold] [bit] NOT NULL,
	[PaymentDays] [int] NOT NULL,
	[PhoneNumber] [nvarchar](20) NOT NULL,
	[FaxNumber] [nvarchar](20) NOT NULL,
	[DeliveryRun] [nvarchar](5) NULL,
	[RunPosition] [nvarchar](5) NULL,
	[WebsiteURL] [nvarchar](256) NOT NULL,
	[DeliveryAddressLine1] [nvarchar](60) NOT NULL,
	[DeliveryAddressLine2] [nvarchar](60) NULL,
	[DeliveryPostalCode] [nvarchar](10) NOT NULL,
	[DeliveryLocation] [geography] NULL,
	[PostalAddressLine1] [nvarchar](60) NOT NULL,
	[PostalAddressLine2] [nvarchar](60) NULL,
	[PostalPostalCode] [nvarchar](10) NOT NULL,
	[LastEditedBy] [int] NOT NULL,
	[ValidFrom] datetime2(7) NOT NULL,
	[ValidTo] datetime2(7) NOT NULL)

INSERT INTO [Sales].[CustomersMergeSource]
			(
			[CustomerID]
           ,[CustomerName]
           ,[BillToCustomerID]
           ,[CustomerCategoryID]
           ,[BuyingGroupID]
           ,[PrimaryContactPersonID]
           ,[AlternateContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[CreditLimit]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[DeliveryRun]
           ,[RunPosition]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryAddressLine2]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalAddressLine2]
           ,[PostalPostalCode]
           ,[LastEditedBy]
		   ,[ValidFrom]
		   ,[ValidTo])
VALUES
(1062,'Name1', 1, 3, 1, 1007, 1008,	3, 21692, 21692, 0, getdate(), 0, 0, 0, 7, '(423) 555-0100', '(423) 555-0101', '', '', '', '', '', 'xxxx', NULL, '', '', '', 1,'2024-06-15 15:57:27.0875218', '9999-12-31 23:59:59.9999999'),
(1063,'Name2', 1, 3, 1, 1007, 1008,	3, 21692, 21692, 0, getdate(), 0, 0, 0, 7, '(423) 555-0100', '(423) 555-0101', '', '', '', '', '', 'xxxx', NULL, '', '', '', 1,'2024-06-15 15:57:27.0875218', '9999-12-31 23:59:59.9999999'),
(1064,'Name3', 1, 3, 1, 1007, 1008,	3, 21692, 21692, 0, getdate(), 0, 0, 0, 7, '(423) 555-0100', '(423) 555-0101', '', '', '', '', '', 'xxxx', NULL, '', '', '', 1,'2024-06-15 15:57:27.0875218', '9999-12-31 23:59:59.9999999'),
(1065,'Name4', 1, 3, 1, 1007, 1008,	3, 21692, 21692, 0, getdate(), 0, 0, 0, 7, '(423) 555-0100', '(423) 555-0101', '', '', '', '', '', 'xxxx', NULL, '', '', '', 1,'2024-06-15 15:57:27.0875218', '9999-12-31 23:59:59.9999999'),
(1066,'Name5', 1, 3, 1, 1007, 1008,	3, 21692, 21692, 0, getdate(), 0, 0, 0, 7, '(423) 555-0100', '(423) 555-0101', '', '', '', '', '', 'xxxx', NULL, '', '', '', 1,'2024-06-15 15:57:27.0875218', '9999-12-31 23:59:59.9999999')
;
--truncate table [Sales].[CustomersMergeSource]
select * from [Sales].[CustomersMergeSource]

-- в таком порядке Target-Source не получается сделать insert. Видимо из-за ограничения на два последних поля. Как это можно обойти? В обратном порядке работает, т.к. на искусственной таблице ограничений нет.
MERGE [Sales].[Customers] AS Target
USING [Sales].[CustomersMergeSource] AS Source
    ON (Target.[CustomerID] = Source.[CustomerID])
WHEN MATCHED 
    THEN UPDATE 
        SET [FaxNumber] = Source.[FaxNumber]
WHEN NOT MATCHED 
    THEN INSERT 
        VALUES (
			Source.[CustomerID]
		   ,Source.[CustomerName]
		   ,Source.[BillToCustomerID]
           ,Source.[CustomerCategoryID]
		   ,Source.[BuyingGroupID]
           ,Source.[PrimaryContactPersonID]
           ,Source.[AlternateContactPersonID]
           ,Source.[DeliveryMethodID]
           ,Source.[DeliveryCityID]
           ,Source.[PostalCityID]
           ,Source.[CreditLimit]
           ,Source.[AccountOpenedDate]
           ,Source.[StandardDiscountPercentage]
           ,Source.[IsStatementSent]
           ,Source.[IsOnCreditHold]
           ,Source.[PaymentDays]
           ,Source.[PhoneNumber]
           ,Source.[FaxNumber]
           ,Source.[DeliveryRun]
           ,Source.[RunPosition]
           ,Source.[WebsiteURL]
           ,Source.[DeliveryAddressLine1]
           ,Source.[DeliveryAddressLine2]
           ,Source.[DeliveryPostalCode]
           ,Source.[DeliveryLocation]
           ,Source.[PostalAddressLine1]
           ,Source.[PostalAddressLine2]
           ,Source.[PostalPostalCode]
           ,Source.[LastEditedBy]
		   ,Source.[ValidFrom]
		   ,Source.[ValidTo]
		   )
--OUTPUT deleted.*, $action, inserted.*
;


/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bcp in
*/

--у меня так работает --bcp WideWorldImporters.Sales.Customers out C:\SQL_Developer_lessons\BCP\Customers.txt -c -T

DECLARE @out varchar(250);
set @out = 'bcp WideWorldImporters.Sales.Customers OUT "C:\SQL_Developer_lessons\BCP\Customers.txt" -T -S ' + @@SERVERNAME + ' -c';
PRINT @out;

EXEC master..xp_cmdshell @out

DROP TABLE IF EXISTS WideWorldImporters.Sales.Customers_copy;
SELECT * INTO WideWorldImporters.Sales.Customers_Copy FROM WideWorldImporters.Sales.Customers
WHERE 1 = 2; 


DECLARE @in varchar(250);
set @in = 'bcp WideWorldImporters.Sales.Customers_Copy IN "C:\SQL_Developer_lessons\BCP\Customers.txt" -T -S ' + @@SERVERNAME + ' -c';

EXEC master..xp_cmdshell @in;

SELECT *
FROM WideWorldImporters.Sales.Customers_Copy;