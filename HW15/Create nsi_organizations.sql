USE [OP_ODS]
GO

/****** Object:  Table [nsi].[organizations]    Script Date: 9/6/2024 12:50:19 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [nsi].[organizations](
	[title] [nvarchar](255) NULL,
	[short_title] [nvarchar](50) NULL,
	[organization_id] [nvarchar](255) NOT NULL,
	[DateEdit] [datetime2](7) NULL,
 CONSTRAINT [PK_OrganisationID] PRIMARY KEY CLUSTERED 
(
	[organization_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [nsi].[organizations] ADD  CONSTRAINT [DF_DateEdit]  DEFAULT (sysdatetime()) FOR [DateEdit]
GO


