--DROP TABLE [dbo].[selfcost] 

CREATE TABLE [OP_Stage].[dbo].[selfcost](
	[flow_id] int NOT NULL,
	[dt] date NULL,
	[showing] [nvarchar](255) NULL,
	[organization_id] [nvarchar](255) NULL,
	[nomenclatureGroup_id] [nvarchar](255) NULL,
	[rawMaterial_id] [nvarchar](255) NULL,
	[plan] [decimal](18,2) NULL,
	[fact] [decimal](18,2) NULL,
	[DateEdit] [datetime2] NULL,
	[flow_hash] [bigint] NOT NULL,
	[row_hash] [bigint] NOT NULL
) ON [PRIMARY]
GO

--DELETE FROM [OP_Stage].[dbo].[selfcost] WHERE flow_id>1
--TRUNCATE TABLE [OP_Stage].[dbo].[selfcost]

-------- first insert ----------------
--INSERT INTO [OP_Stage].[dbo].[selfcost]
--SELECT distinct
--       1 as flow_id
--      ,[dt]
--      ,[showing]
--      ,[organization_id]
--      ,[nomenclatureGroup_id]
--      ,[rawMaterial_id]
--      ,[plan]
--      ,[fact]
--      ,getdate() as [DateEdit]
--	  ,CONVERT(bigint,HASHBYTES('MD5', CONCAT(1,'_', getdate()))) as [flow_hash]
--	  ,CONVERT(bigint,HASHBYTES('MD5', CONCAT([dt],[showing],[organization_id],[nomenclatureGroup_id],[rawMaterial_id]))) as row_hash
--FROM [OP_Import].[dbo].[selfcost_import]

--------------------------------------


DECLARE @flow_id INT = (select max(flow_id)+1 as flow_id from [OP_Stage].[dbo].[selfcost])

INSERT INTO [OP_Stage].[dbo].[selfcost]
SELECT 
       @flow_id as flow_id
	  --1 as flow_id
      ,[dt]
      ,[showing]
      ,[organization_id]
      ,[nomenclatureGroup_id]
      ,[rawMaterial_id]
      ,[plan]
      ,[fact]
      ,getdate() as [DateEdit]
	  ,HASHBYTES('MD5', CONCAT(@flow_id,'_', DateEdit)) as [flow_hash]
	  ,HASHBYTES('MD5', CONCAT([dt],[showing],[organization_id],[nomenclatureGroup_id],[rawMaterial_id])) as row_hash
FROM [OP_Stage].[dbo].[selfcost]

UPDATE [OP_Stage].[dbo].[selfcost] SET [rawMaterial_id]='731CCDC6-03E1-4785-AFE3-1AD2670E24BB' WHERE [rawMaterial_id] is null



DECLARE @flow_id INT = (select max(flow_id) as flow_id from [OP_Stage].[dbo].[selfcost])

SELECT 
       flow_id
      ,[dt]
      ,[showing]
      ,[organization_id]
      ,[nomenclatureGroup_id]
      ,[rawMaterial_id]
      ,[plan]
      ,[fact]
      ,[DateEdit]
	  ,[flow_hash]
	  ,[row_hash]
	  FROM [OP_Stage].[dbo].[selfcost]
	  WHERE flow_id = @flow_id