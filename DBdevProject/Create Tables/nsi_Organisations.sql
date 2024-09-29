USE [OP_ODS]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [nsi].[organizations](
 [id] uniqueidentifier NOT NULL,
 [title] [nvarchar](255) NULL,
 [short_title] [nvarchar](50) NULL,
 [organization_guid] [nvarchar](36) NULL,
 [DateEdit] [datetime2] NULL,
CONSTRAINT [PK_OrganisationID] PRIMARY KEY CLUSTERED ([id])
) ON [PRIMARY]
GO

 ALTER TABLE [nsi].[organizations] ADD  CONSTRAINT [DF_DateEdit]  DEFAULT (sysdatetime()) FOR [DateEdit]
GO


INSERT INTO [nsi].[organizations] 
	VALUES 
		(NEWID(), 'Филиал нашей организации номер 1', 'Филиал 1', 'ffd1539f-9f00-11df-84a9-02215e94355b', getdate()),
		(NEWID(), 'Филиал нашей организации номер 2', 'Филиал 2', '75bda05a-10c3-11df-9ede-001f3c2880c7', getdate())
	;
GO



