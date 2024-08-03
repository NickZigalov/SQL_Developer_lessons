USE WideWorldImporters


sp_configure 'clr enabled', 1 
sp_configure 'clr strict security',0
go
reconfigure
go



CREATE ASSEMBLY CLRFunctions FROM 'C:\SQL_Developer_lessons\HW21\ClassLibraryTest\ClassLibraryTest\bin\Debug\ClassLibraryTest.dll'
GO



CREATE FUNCTION [dbo].SplitStringCLR(@text [nvarchar](max), @delimiter [nvarchar](1))

RETURNS TABLE (

part nvarchar(max),

ID_ODER int

) WITH EXECUTE AS CALLER

AS 

EXTERNAL NAME CLRFunctions.UserDefinedFunctions.SplitString
GO



SELECT * FROM [dbo].[SplitStringCLR]('jqfdyjfdjfeqjd,jkgkugug',',') 
