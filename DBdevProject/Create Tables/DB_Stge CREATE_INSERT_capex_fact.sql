--DROP TABLE [dbo].[capexFact]


/*CREATE TABLE [dbo].[capexFact](
    [flow_id] int NOT NULL,
	[year] [INT] NULL,
	[monthNum] [INT] NULL,
	[reportMonth] [date] NULL,
	[organization_id] [nvarchar](255) NULL,
	[expensesGroup_id] [nvarchar](255) NULL,
	[projectType_id] [nvarchar](255) NULL,
	[businessFunc_id] [nvarchar](255) NULL,
	[projectObjective] [nvarchar](255) NULL,
	[scenario] [nvarchar](255) NULL,
	[projectHiLevel] [nvarchar](255) NULL,
	[indicatorValue] [decimal](18,2) NULL,
	[DateEdit] [datetime2] NULL,
	[flow_hash] [varbinary](8000) NOT NULL
) ON [PRIMARY]
GO*/
CREATE TABLE [dbo].[capexFact](
	[flow_id] [int] NOT NULL,
	[year] [int] NULL,
	[monthNum] [int] NULL,
	[reportMonth] [date] NULL,
	[organization_id] [nvarchar](255) NULL,
	[expensesGroup_id] [int] NULL,
	[projectType_id] [int] NULL,
	[businessFunc_id] [int] NULL,
	[projectObjective] [nvarchar](255) NULL,
	[scenario] [nvarchar](255) NULL,
	[projectHiLevel] [nvarchar](255) NULL,
	[indicatorValue] [decimal](18, 2) NULL,
	[DateEdit] [datetime2](7) NULL,
	[flow_hash] [varbinary](8000) NOT NULL,
	[row_hash] [varbinary](8000) NULL
) ON [PRIMARY]
GO


------------first insert -------------------
--INSERT INTO [OP_Stage].[dbo].[capexFact]
--SELECT 
--	   1 as flow_id
--      ,[data_year]
--      ,[month_number]
--      ,[report_month_start_date]
--      ,[organization_guid]
--      ,[expenses_group_guid]
--      ,[project_guid]
--      ,[project_business_guid]
--      ,[project_objective]
--      ,[scenario]
--      ,[project_type_high_level]
--      ,[indicator_value]
--      ,getdate() as [DateEdit]
--	  ,HASHBYTES('MD5', CONCAT(1,'_', getdate())) as [flow_hash]
--	  ,HASHBYTES('MD5', CONCAT([report_month_start_date],[organization_guid],[expenses_group_guid],[project_guid],[project_business_guid],[project_objective],[scenario],[project_type_high_level])) as row_hash
--  FROM [OP_Import].[dbo].[capex_fact_imp];
--  GO
--------------------------------------------

DECLARE @flow_id INT = (select max(flow_id)+1 as flow_id from [OP_Stage].[dbo].[capexFact])

INSERT INTO [OP_Stage].[dbo].[capexFact]
SELECT 
       @flow_id as flow_id
	  --1 as flow_id
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
      ,getdate() as [DateEdit]
	  ,HASHBYTES('MD5', CONCAT(@flow_id,'_', DateEdit)) as [flow_hash]
	  ,HASHBYTES('MD5', CONCAT([reportMonth],[organization_id],[expensesGroup_id],[projectType_id],[businessFunc_id],[projectObjective],[scenario],[projectHiLevel])) as row_hash
  FROM [OP_Stage].[dbo].[capexFact];
  GO




DECLARE @flow_id INT = (select max(flow_id) as flow_id from [OP_Stage].[dbo].[capexFact])

SELECT 
       flow_id
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
	  ,row_hash
  FROM [OP_Stage].[dbo].[capexFact]
  WHERE flow_id = @flow_id;

