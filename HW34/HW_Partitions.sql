use WideWorldImporters

--создаю копию таблицы для анализа
--select * into [WideWorldImporters].[Sales].[OrdersWithPartitions] from [WideWorldImporters].[Sales].[Orders]

--создаю новую файловую группу и прописываю путь к ней
alter database [WideWorldImporters] add filegroup YearPartition
go
alter database [WideWorldImporters]
	add file (name = N'YearPart', filename = N'C:\SQL_Developer_lessons\YearPartition.ndf')
	to filegroup YearPartition
go

--смотрю таблицу на предмет граничных точек
/*
select distinct YEAR(OrderDate), count(YEAR(OrderDate)) from [WideWorldImporters].[Sales].[OrdersWithPartitions]
group by YEAR(OrderDate)
order by 1
*/

--создаю функцию партиционирования с граничными точками
create partition function fnOrderYearPartition(date)
	as range right
	for values
		('20120101','20130101','20140101','20150101','20160101','20170101')
go

--создаю новую схему партиционирования
create partition scheme schmOrderYearPartition
	as partition fnOrderYearPartition
	all to (YearPartition)
go

--создаю новую таблицу для партиционирования
DROP TABLE IF EXISTS [Sales].[OrdersWithPartitions];

CREATE TABLE [Sales].[OrdersWithPartitions](
	[OrderID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[SalespersonPersonID] [int] NOT NULL,
	[PickedByPersonID] [int] NULL,
	[ContactPersonID] [int] NOT NULL,
	[BackorderOrderID] [int] NULL,
	[OrderDate] [date] NOT NULL,
	[ExpectedDeliveryDate] [date] NOT NULL,
	[CustomerPurchaseOrderNumber] [nvarchar](20) NULL,
	[IsUndersupplyBackordered] [bit] NOT NULL,
	[Comments] [nvarchar](max) NULL,
	[DeliveryInstructions] [nvarchar](max) NULL,
	[InternalComments] [nvarchar](max) NULL,
	[PickingCompletedWhen] [datetime2](7) NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL,
	[OrderConfirmedForProcessing] [datetime] NULL,
) ON [schmOrderYearPartition] ([OrderDate])
GO

--создаю кластерный индекс, содержащий поле по которому делаю партиции
ALTER TABLE [Sales].[OrdersWithPartitions] 
	ADD CONSTRAINT PK_OrdersWithPartitions PRIMARY KEY CLUSTERED
		([OrderDate], [OrderID])
	ON [schmOrderYearPartition] ([OrderDate])
GO

--заливаю данные
INSERT INTO [Sales].[OrdersWithPartitions] 
	SELECT * FROM [Sales].[Orders];

	/*
select distinct object_name(object_id)
from sys.partitions p
where partition_number >1
*/
--делаем проверку, скриншот лиска из плана запроса где видно, что партици работают в папке с ДЗ
SELECT * FROM [Sales].[OrdersWithPartitions];

/* Большое спасибо за лекцию, тема очень интересная!*/
