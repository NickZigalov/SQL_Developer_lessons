--DROP TABLE [dbo].[prod_volume]
Use [OP_Stage];

CREATE TABLE [dbo].[prod_volume](
	[flow_id] int NOT NULL,
	[dt] date NULL,
	[organization_id] [nvarchar](255) NULL,
	[nomenclatureGroup_id] [nvarchar](255) NULL,
	[scenario] [nvarchar](255) NULL,
	[type] [nvarchar](255) NULL,
	[productionVolume] [decimal](18,2) NULL,
	[DateEdit] [datetime2] NULL,
	[flow_hash] [bigint] NOT NULL,
	[row_hash] [bigint] NOT NULL
) ON [PRIMARY]
GO

  
--DELETE FROM [OP_Stage].[dbo].[prod_volume] WHERE flow_id>1
--TRUNCATE TABLE [OP_Stage].[dbo].[selfcost]

-------- first insert ----------------
--INSERT INTO [OP_Stage].[dbo].[prod_volume]
--SELECT distinct
--       1 as flow_id
--      ,[dt]
--      ,[organization_id]
--      ,[nomenclatureGroup_id]
--      ,[scenario]
--      ,[type]
--      ,[productionVolume]
--      ,getdate() as [DateEdit]
--	  ,CONVERT(bigint,HASHBYTES('MD5', CONCAT(1,'_', getdate()))) as [flow_hash]
--	  ,CONVERT(bigint,HASHBYTES('MD5', CONCAT([dt],[organization_id],[nomenclatureGroup_id],[scenario],[type]))) as row_hash
--FROM [OP_Import].[dbo].[prod_volume_import]

--select * from [OP_Stage].[dbo].[prod_volume]
--------------------------------------


DECLARE @flow_id INT = (select max(flow_id)+1 as flow_id from [OP_Stage].[dbo].[prod_volume])

INSERT INTO [OP_Stage].[dbo].[prod_volume] 
SELECT 
	  @flow_id as flow_id
	  --1 as flow_id
	  ,[dt]
      ,[organization_id]
      ,[nomenclatureGroup_id]
      ,[scenario]
      ,[type]
      ,[productionVolume]
      ,getdate() as [DateEdit]
--	  ,CONVERT(bigint,HASHBYTES('MD5', CONCAT(1,'_', getdate()))) as [flow_hash]
--	  ,CONVERT(bigint,HASHBYTES('MD5', CONCAT([dt],[showing],[organization_id],[nomenclatureGroup_id],[rawMaterial_id]))) as row_hash
  FROM [OP_Stage].[dbo].[prod_volume]; 
  

-----------------------------------------------------------------------------------------------------------


DECLARE @flow_id INT = (select max(flow_id) as flow_id from [OP_Stage].[dbo].[prod_volume])

SELECT 
	  [dt]
      ,[organization_id]
      ,[nomenclatureGroup_id]
      ,[scenario]
      ,[type]
      ,[productionVolume]
      ,[DateEdit]
	  ,[flow_hash]
	  ,[row_hash]
  FROM [OP_Stage].[dbo].[prod_volume]
  WHERE flow_id = @flow_id;

  --select * from [OP_Stage].[dbo].[prod_volume] order by flow_id desc





 -- select * from [dbo].[prod_volume] 
 --delete from [dbo].[prod_volume]  where flow_id>1