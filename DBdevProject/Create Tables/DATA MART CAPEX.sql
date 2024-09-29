
INSERT INTO [OP_DataMart].[finance].[capexMart] 

SELECT [year]
      ,[monthNum]
      ,[reportMonth]
      ,ca.[organization_id]
	  ,o.short_title
	  ,o.title
      ,[expensesGroup_id]
      ,[projectType_id]
      ,[businessFunc_id]
      ,[projectObjective]
      ,[scenario]
      ,[projectHiLevel]
      ,[indicatorValue]
      ,ca.[DateEdit]
  FROM [OP_ODS].[finance].[capex] ca
  join [nsi].[organizations] o on ca.organization_id = o.organization_id


  --DROP TABLE [OP_DataMart].[production].[prod_volume]
  --TRUNCATE TABLE [OP_DataMart].[production].[prodVolumeMart]