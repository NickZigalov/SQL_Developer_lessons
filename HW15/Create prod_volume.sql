USE [OP_ODS]
GO

/****** Object:  Table [production].[prod_volume]    Script Date: 9/6/2024 12:21:45 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [production].[prod_volume](
	[dt] [date] NULL,
	[organization_id] [nvarchar](255) NULL,
	[nomenclatureGroup_id] [nvarchar](255) NULL,
	[scenario] [nvarchar](255) NULL,
	[type] [nvarchar](255) NULL,
	[productionVolume] [decimal](18, 2) NULL,
	[DateEdit] [datetime2](7) NULL,
	[flow_hash] [bigint] NOT NULL,
	[row_hash] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[row_hash] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [production].[prod_volume]  WITH CHECK ADD  CONSTRAINT [FK_nomenclatureGroupID] FOREIGN KEY([nomenclatureGroup_id])
REFERENCES [nsi].[nomenclatureGroup] ([nomenclatureGroup_id])
GO

ALTER TABLE [production].[prod_volume] CHECK CONSTRAINT [FK_nomenclatureGroupID]
GO

ALTER TABLE [production].[prod_volume]  WITH CHECK ADD  CONSTRAINT [FK_organizationID] FOREIGN KEY([organization_id])
REFERENCES [nsi].[organizations] ([organization_id])
GO

ALTER TABLE [production].[prod_volume] CHECK CONSTRAINT [FK_organizationID]
GO


