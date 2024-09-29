USE [OP_Stage]
GO

/****** Object:  Table [nsi].[ref_organizations]    Script Date: 8/10/2024 4:44:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SELECT TOP (1000) 
	   [year]
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
  FROM [OP_Stage].[dbo].[capexFact_import]

CREATE TABLE [dbo].[capexFact](
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
	[DateEdit] [datetime2] NULL
) ON [PRIMARY]
GO

  --INSERT INTO capexFact SELECT 
	 --  [data_year]
  --    ,[month_number]
  --    ,[report_month_start_date]
  --    ,[organization_id]
  --    ,[expenses_group_id]
  --    ,[ВидПроекта_GUID]
  --    ,[ФункцияПроекта_GUID]
  --    ,[project_objective]
  --    ,[scenario]
  --    ,[project_type_high_level]
  --    ,[indicator_value]
  --, getdate() as DateEdit FROM [OP_Stage].[dbo].[Scheet$] s



USE [OP_Stage]
GO

/****** Object:  Table [nsi].[ref_organizations]    Script Date: 8/10/2024 4:44:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[capexPlan](
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
	[DateEdit] [datetime2] NULL
) ON [PRIMARY]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--DROP TABLE [dbo].[selfcost] 

CREATE TABLE [dbo].[selfcost](
	[dt] date NULL,
	[showing] [nvarchar](255) NULL,
	[organization_id] [nvarchar](255) NULL,
	[nomenclatureGroup_id] [nvarchar](255) NULL,
	[rawMaterial_id] [nvarchar](255) NULL,
	[plan] [decimal](18,2) NULL,
	[fact] [decimal](18,2) NULL,
	[DateEdit] [datetime2] NULL
) ON [PRIMARY]
GO


--DROP TABLE [dbo].[prod_volume]

CREATE TABLE [dbo].[prod_volume](
	[flow_id] int NOT NULL,
	[dt] date NULL,
	[organization_id] [nvarchar](255) NULL,
	[nomenclatureGroup_id] [nvarchar](255) NULL,
	[scenario] [nvarchar](255) NULL,
	[type] [nvarchar](255) NULL,
	[productionVolume] [decimal](18,2) NULL,
	[DateEdit] [datetime2] NULL
) ON [PRIMARY]
GO



