with a as (SELECT  [flow_id]
      ,[year]
      ,[monthNum]
      ,[reportMonth]
      ,[organization_id]
      ,[expensesGroup_id]
      ,[projectType_id]
      ,[businessFunc_id]
      ,[projectObjective]
      ,[scenario]
      ,[projectHiLevel]
      ,[indicatorValue]
      ,[DateEdit]
      ,[flow_hash]
	  ,HASHBYTES('MD5', CONCAT([reportMonth],[organization_id],[expensesGroup_id],[projectType_id],[businessFunc_id],[projectObjective],[scenario],[projectHiLevel])) as row_hash
  FROM [OP_Stage].[dbo].[capexFact])
  select * from a
  ORDER BY row_hash, DateEdit desc




    with a as (
  SELECT distinct pv.[nomenclatureGroup_id], o.title
  FROM [OP_Stage].[dbo].[prod_volume] pv
  left join [OP_ODS].[nsi].[organizations] o on o.organization_id=pv.organization_id
  WHERE o.organization_id is not null
  ),
  b as (
  select distinct  s.[nomenclatureGroup_id]
  from [OP_Stage].[dbo].[selfcost] s
  left join [OP_ODS].[nsi].[organizations] o on o.organization_id=s.organization_id
  WHERE o.organization_id is not null
  )
  INSERT INTO [OP_ODS].[nsi].[nomenclatureGroup]
  select c.[nomenclatureGroup], c.[NomenclatureGroup_GUID], getdate() as DateEdit from a
  --full 
  join b on a.[nomenclatureGroup_id] = b.[nomenclatureGroup_id]
  left outer join [OP_ODS].[dbo].[Лист1$] c on c.[NomenclatureGroup_GUID] = b.[nomenclatureGroup_id]


  select * from  [OP_ODS].[nsi].[nomenclatureGroup]