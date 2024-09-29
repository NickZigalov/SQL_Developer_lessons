---------------------------------Чистим Stage от лишних записей-----------------------------------------------

DELETE FROM [OP_Stage].[dbo].[capexFact] WHERE flow_id>1
DELETE FROM [OP_Stage].[dbo].[capexPlan] WHERE flow_id>1
DELETE FROM [OP_Stage].[dbo].[prod_volume] WHERE flow_id>1
DELETE FROM [OP_Stage].[dbo].[selfcost] WHERE flow_id>1

---------------------------------Чистим Operation Data Store от лишних записей-----------------------------------------------

TRUNCATE TABLE [OP_ODS].[finance].[capex];
TRUNCATE TABLE [OP_ODS].[finance].[capex_errors];
TRUNCATE TABLE [OP_ODS].[finance].[costPrice];
TRUNCATE TABLE [OP_ODS].[finance].[costPrice_errors];
TRUNCATE TABLE [OP_ODS].[production].[prod_volume];
TRUNCATE TABLE [OP_ODS].[production].[prod_volume_errors];

---------------------------------Чистим Data Mart от лишних записей-----------------------------------------------

TRUNCATE TABLE [OP_DataMart].[production].[prodVolumeMart];
TRUNCATE TABLE [OP_DataMart].[finance].[costPriceMart];
--TRUNCATE TABLE ;