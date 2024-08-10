
DROP SERVICE [//WWI/SB/HW_TargetService]
GO

DROP SERVICE [//WWI/SB/HW_InitiatorService]
GO

DROP QUEUE [dbo].[HW_TargetQueueWWI]
GO 

DROP QUEUE [dbo].[HW_InitiatorQueueWWI]
GO

DROP CONTRACT [//WWI/SB/HW_Contract]
GO

DROP MESSAGE TYPE [//WWI/SB/HW_RequestMessage]
GO

DROP MESSAGE TYPE [//WWI/SB/HW_ReplyMessage]
GO

DROP PROCEDURE IF EXISTS  Sales.HW_SendNewInvoice;

DROP PROCEDURE IF EXISTS  Sales.HW_GetNewInvoice;

DROP PROCEDURE IF EXISTS  Sales.HW_ConfirmInvoice;


DROP TABLE Sales.ClienOrderServiceMsg;