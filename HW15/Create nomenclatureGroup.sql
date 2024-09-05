USE [OP_ODS]
GO

/****** Object:  Table [nsi].[nomenclatureGroup]    Script Date: 9/6/2024 12:46:06 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [nsi].[nomenclatureGroup](
	[nomenclatureGroup] [nvarchar](255) NOT NULL,
	[nomenclatureGroup_id] [nvarchar](255) NOT NULL,
	[DateEdit] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_nomenclatureGroupID] PRIMARY KEY CLUSTERED 
(
	[nomenclatureGroup_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


