/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 
*/

--------------------------------------------------------------------------------OPENXML--------------------------------------------------------------------------
DECLARE @xmlDocument XML;

SELECT @xmlDocument = BulkColumn
FROM OPENROWSET
(BULK 'C:\SQL_Developer_lessons\HW9\StockItems.xml', 
 SINGLE_CLOB)
AS data;
-- Проверяем, что в @xmlDocument
--SELECT @xmlDocument AS [@xmlDocument];
DECLARE @docHandle INT;
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument;
-- docHandle - это просто число
--SELECT @docHandle AS docHandle;

/*SELECT *
FROM OPENXML(@docHandle, N'/StockItems/Item')
WITH ( 
	[SupplierID] INT  'SupplierID',
	[StockitemName] NVARCHAR(100) '@Name',
	[UnitPackageID] INT 'Package/UnitPackageID',
	[OuterPackageID] INT 'Package/OuterPackageID',
	[QuantityPerOuter] INT 'Package/QuantityPerOuter',
	[TypicalWeightPerUnit] DECIMAL(18,3) 'Package/TypicalWeightPerUnit',
	[LeadTimeDays] INT 'LeadTimeDays',
	[IsChillerStock] BIT 'IsChillerStock',
	[TaxRate] DECIMAL(18,3) 'TaxRate',
	[UnitPrice] DECIMAL(18,2) 'UnitPrice'
	);*/

DROP TABLE IF EXISTS #StockItems;

CREATE TABLE #StockItems(
	[StockitemName] NVARCHAR(100),
	[SupplierID] INT,
	[UnitPackageID] INT,
	[OuterPackageID] INT,
	[QuantityPerOuter] INT,
	[TypicalWeightPerUnit] DECIMAL(18,3),
	[LeadTimeDays] INT,
	[IsChillerStock] BIT,
	[TaxRate] DECIMAL(18,3),
	[UnitPrice] DECIMAL(18,2) 
);

INSERT INTO #StockItems
SELECT *
FROM OPENXML(@docHandle, N'/StockItems/Item')
WITH ( 
	[StockitemName] NVARCHAR(100) '@Name',
	[SupplierID] INT  'SupplierID',
	[UnitPackageID] INT 'Package/UnitPackageID',
	[OuterPackageID] INT 'Package/OuterPackageID',
	[QuantityPerOuter] INT 'Package/QuantityPerOuter',
	[TypicalWeightPerUnit] DECIMAL(18,3) 'Package/TypicalWeightPerUnit',
	[LeadTimeDays] INT 'LeadTimeDays',
	[IsChillerStock] BIT 'IsChillerStock',
	[TaxRate] DECIMAL(18,3) 'TaxRate',
	[UnitPrice] DECIMAL(18,2) 'UnitPrice'
	);

SELECT * FROM #StockItems


-------------------------------------------------------------------------------XQuery----------------------------------------------------------------------------

DECLARE @x XML;
SET @x = (SELECT * FROM OPENROWSET (BULK 'C:\SQL_Developer_lessons\HW9\StockItems.xml', SINGLE_BLOB)  AS d);

DROP TABLE IF EXISTS #StockItemsXQuery;

CREATE TABLE #StockItemsXQuery(
	[StockitemName] NVARCHAR(100),
	[SupplierID] INT,
	[UnitPackageID] INT,
	[OuterPackageID] INT,
	[QuantityPerOuter] INT,
	[TypicalWeightPerUnit] DECIMAL(18,3),
	[LeadTimeDays] INT,
	[IsChillerStock] BIT,
	[TaxRate] DECIMAL(18,3),
	[UnitPrice] DECIMAL(18,2) 
);

INSERT INTO #StockItemsXQuery
SELECT  
  t.StockItems.value('(@Name)[1]', 'varchar(100)') AS [StockitemName]
  ,t.StockItems.value('(SupplierID)[1]', 'int') AS [SupplierID]
  ,t.StockItems.value('(Package/UnitPackageID)[1]', 'int') AS [UnitPackageID]
  ,t.StockItems.value('(Package/OuterPackageID)[1]', 'int') AS [OuterPackageID]
  ,t.StockItems.value('(Package/QuantityPerOuter)[1]', 'int') AS [QuantityPerOuter]
  ,t.StockItems.value('(Package/TypicalWeightPerUnit)[1]', 'DECIMAL(18,3)') AS [TypicalWeightPerUnit]
  ,t.StockItems.value('(LeadTimeDays)[1]', 'int') AS [LeadTimeDays]
  ,t.StockItems.value('(IsChillerStock)[1]', 'bit') AS [IsChillerStock]
  ,t.StockItems.value('(TaxRate)[1]', 'DECIMAL(18,3)') AS [TaxRate]
  ,t.StockItems.value('(UnitPrice)[1]', 'DECIMAL(18,2)') AS [UnitPrice]
FROM @x.nodes('/StockItems/Item') AS t(StockItems);

SELECT * FROM #StockItemsXQuery

/*
Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/
--Сделал выше две разные временные таблицы для двух методов

DROP TABLE if exists [Warehouse].[StockItemsTest];

CREATE TABLE [Warehouse].[StockItemsTest] 
(
	[StockitemName] NVARCHAR(100),
	[SupplierID] INT,
	[UnitPackageID] INT,
	[OuterPackageID] INT,
	[QuantityPerOuter] INT,
	[TypicalWeightPerUnit] DECIMAL(18,3),
	[LeadTimeDays] INT,
	[IsChillerStock] BIT,
	[TaxRate] DECIMAL(18,3),
	[UnitPrice] DECIMAL(18,2) 
);
ALTER TABLE [Warehouse].[StockItemsTest] ALTER COLUMN [StockitemName] VARCHAR(100) COLLATE Cyrillic_General_CI_AS
------------------- тренируемся на тестовой таблице ---------------------------
INSERT INTO [Warehouse].[StockItemsTest]
SELECT 
	StockitemName,
	SupplierID,
	UnitPackageID,
	OuterPackageID,
	QuantityPerOuter,
	TypicalWeightPerUnit,
	LeadTimeDays,
	IsChillerStock,
	TaxRate,
	UnitPrice 
FROM [Warehouse].[StockItems]


MERGE #StockItemsXQuery AS Target
USING [Warehouse].[StockItemsTest] AS Source
    ON (Target.StockitemName = Source.StockitemName)
WHEN MATCHED 
    THEN UPDATE 
        SET SupplierID = Source.SupplierID,
		UnitPackageID = Source.UnitPackageID,
		OuterPackageID = Source.OuterPackageID,
		QuantityPerOuter = Source.QuantityPerOuter,
		TypicalWeightPerUnit = Source.TypicalWeightPerUnit
WHEN NOT MATCHED 
    THEN INSERT 
        VALUES (
			Source.StockitemName,
			Source.SupplierID,
			Source.UnitPackageID,
			Source.OuterPackageID,
			Source.QuantityPerOuter,
			Source.TypicalWeightPerUnit,
			Source.LeadTimeDays,
			Source.IsChillerStock,
			Source.TaxRate,
			Source.UnitPrice 
		   );


/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

SELECT 
	StockitemName,
	SupplierID,
	UnitPackageID,
	OuterPackageID,
	QuantityPerOuter,
	TypicalWeightPerUnit,
	LeadTimeDays,
	IsChillerStock,
	TaxRate,
	UnitPrice 
FROM [Warehouse].[StockItems]
FOR XML AUTO;

--не работает, подскажите в чем дело
DECLARE @cmd  VARCHAR(4000);
SET @cmd = 'bcp "select * from [Warehouse].[StockItems] FOR XML AUTO" 
             queryout "C:\SQL_Developer_lessons\BCP\StockItem.xml" -c -T ' + @@SERVERNAME+ ' -w' ;
PRINT @cmd;
EXEC xp_cmdshell @cmd;


/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

SELECT  StockItemID, StockItemName,
	JSON_VALUE(CustomFields, '$.CountryOfManufacture') AS  CountryOfManufacture,
	JSON_VALUE(CustomFields, '$.Tags[0]') AS FirstTag
FROM Warehouse.StockItems;


/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

--это, вероятно, не подойдет по условию задачи--
SELECT  StockItemID, StockItemName,
	tags.[key],
	tags.value
FROM Warehouse.StockItems
CROSS APPLY OPENJSON (CustomFields, '$.Tags') tags
WHERE  tags.value = 'Vintage'
;

-- а это, видимо подойдет
With a as (
SELECT 
	StockItemID, StockItemName, que.value as val
FROM Warehouse.StockItems
CROSS APPLY OPENJSON (CustomFields) que
WHERE  que.value like '%Vintage%'
)
SELECT
	StockItemID, StockItemName, val, ans.value
FROM a
CROSS APPLY OPENJSON (val) as ans
WHERE ans.value = 'Vintage'
;

-- опциональная задачка через строковую функцию, например
SELECT * 
FROM (
		SELECT  StockItemID, StockItemName,
			CAST(JSON_QUERY(CustomFields, '$.Tags') as varchar(250))  AS Tag
		FROM Warehouse.StockItems) as subquery
WHERE CHARINDEX(',', Tag) >0
;

