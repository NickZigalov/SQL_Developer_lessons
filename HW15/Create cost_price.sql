USE [OP_ODS]
GO

/****** Object:  Table [finance].[costPrice]    Script Date: 9/6/2024 12:29:03 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [finance].[costPrice](
	[dt] [date] NULL,
	[showing] [nvarchar](255) NULL,
	[organization_id] [nvarchar](255) NULL,
	[nomenclatureGroup_id] [nvarchar](255) NULL,
	[rawMaterial_id] [nvarchar](255) NULL,
	[plan] [decimal](18, 2) NULL,
	[fact] [decimal](18, 2) NULL,
	[DateEdit] [datetime2](7) NULL,
	[flow_hash] [bigint] NOT NULL,
	[row_hash] [bigint] NOT NULL,
 CONSTRAINT [PK__costPric__row_hash] PRIMARY KEY CLUSTERED 
(
	[row_hash] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [finance].[costPrice]  WITH CHECK ADD  CONSTRAINT [FK_nomenclatureGroupID] FOREIGN KEY([nomenclatureGroup_id])
REFERENCES [nsi].[nomenclatureGroup] ([nomenclatureGroup_id])
GO

ALTER TABLE [finance].[costPrice] CHECK CONSTRAINT [FK_nomenclatureGroupID]
GO

ALTER TABLE [finance].[costPrice]  WITH CHECK ADD  CONSTRAINT [FK_organizationID] FOREIGN KEY([organization_id])
REFERENCES [nsi].[organizations] ([organization_id])
GO

ALTER TABLE [finance].[costPrice] CHECK CONSTRAINT [FK_organizationID]
GO

ALTER TABLE [finance].[costPrice]  WITH CHECK ADD  CONSTRAINT [FK_rawMaterialID] FOREIGN KEY([rawMaterial_id])
REFERENCES [nsi].[rawMaterials] ([rawMaterial_id])
GO

ALTER TABLE [finance].[costPrice] CHECK CONSTRAINT [FK_rawMaterialID]
GO


