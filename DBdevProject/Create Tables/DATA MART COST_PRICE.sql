
SELECT * INTO [OP_DataMart].[finance].[costPriceMart] FROM
(
SELECT [dt]
      ,[showing]
      ,cp.[organization_id]
	  ,o.[short_title]
	  ,o.[title]
      ,cp.[nomenclatureGroup_id]
	  ,ng.nomenclatureGroup
      ,cp.[rawMaterial_id]
	  ,rm.rawMaterial
      ,[plan]
      ,[fact]
      ,cp.[DateEdit]
      ,[flow_hash]
      ,[row_hash]
  FROM [OP_ODS].[finance].[costPrice] cp
  join [nsi].[organizations] o on cp.organization_id = o.organization_id
  join [nsi].nomenclatureGroup ng on cp.nomenclatureGroup_id = ng.nomenclatureGroup_id
  join [nsi].rawMaterials rm on cp.rawMaterial_id = rm.rawMaterial_id
  ) v

  --DROP TABLE [OP_DataMart].[production].
  --TRUNCATE TABLE [OP_DataMart].[finance].[costPriceMart]