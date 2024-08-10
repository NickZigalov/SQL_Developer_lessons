USE [WideWorldImporters];

-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

--процедура без входящих параметров для простоты отладки
ALTER PROCEDURE Sales.HW_SendNewInvoice

AS
BEGIN
	SET NOCOUNT ON;

    --Sending a Request Message to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(4000);
	
	BEGIN TRAN --на всякий случай в транзакции, т.к. это еще не относится к транзакции ПЕРЕДАЧИ сообщения

	--Формируем XML с корнем RequestMessage где передадим результат запроса
	SELECT @RequestMessage = (
								  select top 3 i.CustomerID, q.CustomerName, COUNT(i.OrderID) as OrdersSum from sales.Invoices i
								  outer apply (select OrderDate from Sales.Orders o where i.OrderID=o.OrderID) x
								  outer apply (select CustomerName from sales.Customers c where i.CustomerID=c.CustomerID) q 
								  where x.OrderDate BETWEEN '2015-08-01' and '2015-08-07'
								  GROUP BY i.CustomerID, q.CustomerName
								  FOR XML AUTO, root('RequestMessage')

								); 
	
	
	--Создаем диалог
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//WWI/SB/HW_InitiatorService] --от этого сервиса(это сервис текущей БД, поэтому он НЕ строка)
	TO SERVICE
	'//WWI/SB/HW_TargetService'    --к этому сервису(это сервис который может быть где-то, поэтому строка)
	ON CONTRACT
	[//WWI/SB/HW_Contract]         --в рамках этого контракта
	WITH ENCRYPTION=OFF;        --не шифрованный

	--отправляем одно наше подготовленное сообщение, но можно отправить и много сообщений, которые будут обрабатываться строго последовательно)
	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//WWI/SB/HW_RequestMessage]
	(@RequestMessage);
	
	COMMIT TRAN 

END
GO
