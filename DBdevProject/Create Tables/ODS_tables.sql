USE [OP_ODS]
GO

/****** Object:  Table [nsi].[ref_organizations]    Script Date: 8/11/2024 2:03:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [nsi].[organizations](
	[id] [uniqueidentifier] NOT NULL,
	[title] [nvarchar](255) NULL,
	[short_title] [nvarchar](50) NULL,
	[organization_guid] [nvarchar](36) NULL,
	[DateEdit] [datetime2](7) NULL,
 CONSTRAINT [PK_OrganisationID] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [nsi].[organizations] ADD  CONSTRAINT [DF_DateEdit]  DEFAULT (sysdatetime()) FOR [DateEdit]
GO



USE [OP_ODS]
GO

/****** Object:  Table [nsi].[ref_organizations]    Script Date: 8/11/2024 2:03:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [nsi].[ref_organizations](
	[id] [uniqueidentifier] NOT NULL,
	[title] [nvarchar](255) NULL,
	[short_title] [nvarchar](50) NULL,
	[organization_guid] [nvarchar](36) NULL,
	[DateEdit] [datetime2](7) NULL,
 CONSTRAINT [PK_OrganisationID] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [nsi].[ref_organizations] ADD  CONSTRAINT [DF_DateEdit]  DEFAULT (sysdatetime()) FOR [DateEdit]
GO



CREATE TABLE [nsi].[ref_rawMaterials](
	[rawMaterial] [nvarchar](255) NULL,
	[rawMaterial_id] [nvarchar](50) NULL
	)