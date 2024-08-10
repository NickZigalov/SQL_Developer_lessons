ALTER PROCEDURE Sales.HW_GetNewInvoice --будет получать сообщение на таргете
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(4000),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
			@ReplyMessageName Sysname,
			@id varchar(50),
			@CustomerID INT,
			@CustomerName varchar(50),
			@OrdersSum INT,
			@DateEdit datetime2,
			@xml XML; 
	
	BEGIN TRAN; 

	--получаем сообщение от инициатора которое находитс¤ у таргета
	RECEIVE TOP(1) --обычно одно сообщение, но можно пачкой
		@TargetDlgHandle = Conversation_Handle, 
		@Message = Message_Body, --само сообщение
		@MessageType = Message_Type_Name --тип сообщени¤( в зависимости от типа можно по разному обрабатывать) обычно два - запрос и ответ
	FROM dbo.HW_TargetQueueWWI; --им¤ очереди которую мы ранее создавали

	SELECT @Message; --для отладки

	SET @xml = CAST(@Message AS XML);

BEGIN

	INSERT INTO Sales.ClienOrderServiceMsg 
		SELECT
			NEWID(), --формируем уникальный id записи
			t.iv.value('(./@CustomerID)', 'INT'), 
			t.iv.value('(./q/@CustomerName)[1]', 'varchar(50)'),
			t.iv.value('(./q/@OrdersSum)[1]', 'INT'),
			getdate() --проставляем системное время записи
		FROM @xml.nodes('/RequestMessage/i') as t(iv);

END;

	
	SELECT @Message AS ReceivedRequestMessage, @MessageType; --для отладки
	
	-- Confirm and Send a reply
	IF @MessageType=N'//WWI/SB/HW_RequestMessage' --если наш тип сообщени¤
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>'; --ответ
	    --отправл¤ем сообщение нами придуманное, что все прошло хорошо
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/SB/HW_ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle; --а вот и завершение диалога!!! - оно двухстороннее(пока-пока) Ё“ќ первый ѕќ ј
		                                   --Ќ≈Ћ№«я «ј¬≈–Ўј“№ ƒ»јЋќ√ ƒќ ќ“ѕ–ј¬ » ѕ≈–¬ќ√ќ —ќќЅў≈Ќ»я
	END 
	
	SELECT @ReplyMessage AS SentReplyMessage; ----для отладки - это для теста

	COMMIT TRAN;
END