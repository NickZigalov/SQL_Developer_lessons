--DROP TABLE [dbo].[capex]

CREATE TABLE [finance].[capex](
	[year] [INT] NULL,
	[monthNum] [INT] NULL,
	[reportMonth] [date] NULL,
	[organization_id] [nvarchar](255) NOT NULL,
	[expensesGroup_id] [nvarchar](255) NOT NULL,
	[projectType_id] [nvarchar](255) NOT NULL,
	[businessFunc_id] [nvarchar](255) NOT NULL,
	[projectObjective] [nvarchar](255) NULL,
	[scenario] [nvarchar](255) NULL,
	[projectHiLevel] [nvarchar](255) NULL,
	[indicatorValue] [decimal](18,2) NULL,
	[DateEdit] [datetime2] NULL,
	[flow_hash] [varbinary](8000) NOT NULL,
	[row_hash] [varbinary](8000) NOT NULL
) ON [PRIMARY]
GO




CREATE TABLE [production].[prod_volume](
	[dt] date NULL,
	[organization_id] [nvarchar](255) NULL,
	[nomenclatureGroup_id] [nvarchar](255) NULL,
	[scenario] [nvarchar](255) NULL,
	[type] [nvarchar](255) NULL,
	[productionVolume] [decimal](18,2) NULL,
	[DateEdit] [datetime2] NULL,
	[flow_hash] [varbinary](8000) NOT NULL,
	[row_hash] [varbinary](8000) NOT NULL
) ON [PRIMARY]
GO




CREATE TABLE [finance].[costPrice](
	[dt] date NULL,
	[showing] [nvarchar](255) NULL,
	[organization_id] [nvarchar](255) NULL,
	[nomenclatureGroup_id] [nvarchar](255) NULL,
	[rawMaterial_id] [nvarchar](255) NULL,
	[plan] [decimal](18,2) NULL,
	[fact] [decimal](18,2) NULL,
	[DateEdit] [datetime2] NULL,
	[flow_hash] [varbinary](8000) NOT NULL,
	[row_hash] [varbinary](8000) NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [production].[prod_volume]
ADD CONSTRAINT FK_nomenclatureGroupID FOREIGN KEY ([nomenclatureGroup_id])
REFERENCES [nsi].[nomenclatureGroup]([nomenclatureGroup_id]);


ALTER TABLE [production].[prod_volume] 
ADD CONSTRAINT FK_organizationID FOREIGN KEY ([organization_id])
REFERENCES [nsi].[organizations]([organization_id]);