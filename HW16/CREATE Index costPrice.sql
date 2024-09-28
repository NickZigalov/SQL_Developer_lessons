USE [OP_ODS]
GO
--На примере одной из таблиц ODS слоя

--Основной кластерный индекс B-tree на основе искусственного первичного ключа уникальных строк
ALTER TABLE [finance].[costPrice] ADD  CONSTRAINT [PK__costPric__row_hash] PRIMARY KEY CLUSTERED 
GO

--Индекс помогает формировать выборку в разрезе номенклатурных групп по конкретной статье
CREATE NONCLUSTERED INDEX IX_NomenclatureGroupID ON [finance].[costPrice]([showing],[nomenclatureGroup_id])
GO

--Альтернативный индекс. Колоночный индекс помогает выбрать информацию по конкретной статье.
--В данном случае тест показал, что производительность снижается на треть, поэтому не использую.
--CREATE COLUMNSTORE INDEX IX_ColIndexShowing ON [finance].[costPriceindextest]([showing], [nomenclatureGroup_id])
--GO


--Индекс помогает в выборке по расходным материалам. Состоит из одного поля и не содержит статью(showing) т.к. для этой задачи статья всегда уникальна
CREATE NONCLUSTERED INDEX IX_RawMaterialID ON [finance].[costPrice]([rawMaterial_id])
GO



/*
select * into [finance].[costPriceindextest] from [finance].[costPrice]

select showing, nomenclatureGroup_id, SUM([plan]) as [plan], SUM([fact]) as [fact] from [finance].[costPrice]
where showing = 'Себестоимость'
group by dt, showing, nomenclatureGroup_id

select showing, nomenclatureGroup_id, SUM([plan]) as [plan], SUM([fact]) as [fact] from [finance].[costPriceindextest] WITH (INDEX (IX_ColIndexShowing))
where showing = 'Себестоимость'
group by dt, showing, nomenclatureGroup_id

--drop table [finance].[costPriceindextest]  
*/














--select * into [finance].[costPrice_indextest] from [finance].[costPrice] 