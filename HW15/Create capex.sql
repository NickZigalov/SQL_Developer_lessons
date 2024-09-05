USE [OP_ODS]
GO

/****** Object:  Table [finance].[capex]    Script Date: 9/6/2024 12:33:49 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [finance].[capex](
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
	[row_hash] [varbinary](8000) NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [finance].[capex]  WITH CHECK ADD  CONSTRAINT [FK_businessFuncID] FOREIGN KEY([businessFunc_id])
REFERENCES [nsi].[business_function] ([id])
GO

ALTER TABLE [finance].[capex] CHECK CONSTRAINT [FK_businessFuncID]
GO

ALTER TABLE [finance].[capex]  WITH CHECK ADD  CONSTRAINT [FK_capexOrganizationID] FOREIGN KEY([organization_id])
REFERENCES [nsi].[organizations] ([organization_id])
GO

ALTER TABLE [finance].[capex] CHECK CONSTRAINT [FK_capexOrganizationID]
GO

ALTER TABLE [finance].[capex]  WITH CHECK ADD  CONSTRAINT [FK_expensesGroupID] FOREIGN KEY([expensesGroup_id])
REFERENCES [nsi].[ref_expences_grp] ([id])
GO

ALTER TABLE [finance].[capex] CHECK CONSTRAINT [FK_expensesGroupID]
GO

ALTER TABLE [finance].[capex]  WITH CHECK ADD  CONSTRAINT [FK_projectTypeID] FOREIGN KEY([projectType_id])
REFERENCES [nsi].[ref_project] ([id])
GO

ALTER TABLE [finance].[capex] CHECK CONSTRAINT [FK_projectTypeID]
GO


