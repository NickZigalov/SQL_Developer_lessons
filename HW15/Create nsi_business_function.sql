USE [OP_ODS]
GO

/****** Object:  Table [nsi].[business_function]    Script Date: 9/6/2024 12:39:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [nsi].[business_function](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[business_function] [nvarchar](255) NULL,
 CONSTRAINT [PK_business_functionID] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


