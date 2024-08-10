USE [WideWorldImporters];

--Создадим новую таблицу для сохранения отчетов
  CREATE TABLE Sales.ClienOrderServiceMsg 
  (
    [id] [varchar](100) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[CustomerName] [varchar](100) NULL,
    [OrdersSum] [int] NULL,
	[DateEdit] [datetime2] NOT NULL,
	CONSTRAINT [PK_ClienOrderMsg] PRIMARY KEY CLUSTERED
	([id])
  )
  ALTER TABLE Sales.ClienOrderServiceMsg ADD  CONSTRAINT [DF_ClienOrderServiceMsg_DateEdit]  DEFAULT (sysdatetime()) FOR [DateEdit]
GO
  ALTER TABLE Sales.ClienOrderServiceMsg  WITH CHECK ADD  CONSTRAINT [FK_ClienOrderServiceMsg_Customers] FOREIGN KEY([CustomerID])
  REFERENCES [Sales].[Customers] ([CustomerID])
GO
/*
--Service Broker включен ли?
select name, is_broker_enabled
from sys.databases;

--Включить брокер
USE master
ALTER DATABASE WideWorldImporters
--SET ENABLE_BROKER  WITH ROLLBACK IMMEDIATE; --NO WAIT --prod (в однопользовательском режиме!!! На проде так не нужно)

--БД должна функционировать от имени технической учетки!!!
ALTER AUTHORIZATION    
   ON DATABASE::WideWorldImporters TO [sa];

--Включите это чтобы доверять сервисам без использования сертификатов когда работаем между различными 
--БД и инстансами(фактически говорим серверу, что этой БД можно доверять)
--Если мы открепим БД и вновь ее прикрепим, то это свойство сбросится в OFF
ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;
*/
--Создаем типы сообщений
USE WideWorldImporters
-- For Request
CREATE MESSAGE TYPE
[//WWI/SB/HW_RequestMessage]
VALIDATION=WELL_FORMED_XML; --служит исключительно для проверки, что данные соответствуют типу XML(но можно любой тип)
-- For Reply
CREATE MESSAGE TYPE
[//WWI/SB/HW_ReplyMessage]
VALIDATION=WELL_FORMED_XML; --служит исключительно для проверки, что данные соответствуют типу XML(но можно любой тип) 

--Создаем контракт(определяем какие сообщения в рамках этого контракта допустимы)
CREATE CONTRACT [//WWI/SB/HW_Contract]
      ([//WWI/SB/HW_RequestMessage]
         SENT BY INITIATOR,
       [//WWI/SB/HW_ReplyMessage]
         SENT BY TARGET
      );

--Создаем ОЧЕРЕДЬ таргета(настрим позже т.к. через ALTER можно ею рулить еще
CREATE QUEUE HW_TargetQueueWWI;
--и сервис таргета
CREATE SERVICE [//WWI/SB/HW_TargetService]
       ON QUEUE HW_TargetQueueWWI
       ([//WWI/SB/HW_Contract]);

--то же для ИНИЦИАТОРА
CREATE QUEUE HW_InitiatorQueueWWI;

CREATE SERVICE [//WWI/SB/HW_InitiatorService]
       ON QUEUE HW_InitiatorQueueWWI
       ([//WWI/SB/HW_Contract]);


--select * from HW_TargetQueueWWi
--select * from HW_InitiatorQueueWWI

--Создаем процедуры в скрипте CreateProcedure
--1. HW_SendNewInvoice.sql - процедура которая вызывается в процессе какого-то техпроцесса - НЕ АКТИВАЦИОННАЯ для очередей
--2. HW_GetNewInvoice.sql - АКТИВАЦИОННАЯ процедура(всегда без параметров)
--3. HW_ConfirmInvoice.sql - АКТИВАЦИОННАЯ процедура - обработка сообщения что все прошло хорошо

--тепер настроим ОЧЕРЕДЬ или так можем рулить прецессами связанными с очередями
USE [WideWorldImporters]
GO
--пока с MAX_QUEUE_READERS = 0 чтобы вручную вызвать процедуры и увидеть все своими глазами 
ALTER QUEUE [dbo].[HW_InitiatorQueueWWI] WITH STATUS = ON --OFF=очередь НЕ доступна(ставим если глобальные проблемы)
                                          ,RETENTION = OFF --ON=все завершенные сообщения хранятся в очереди до окончания диалога
										  ,POISON_MESSAGE_HANDLING (STATUS = OFF) --ON=после 5 ошибок очередь будет отключена
	                                      ,ACTIVATION (STATUS = ON --OFF=очередь не активирует ХП(в PROCEDURE_NAME)(ставим на время исправления ХП, но с потерей сообщений)  
										              ,PROCEDURE_NAME = Sales.HW_ConfirmInvoice
													  ,MAX_QUEUE_READERS = 0 --количество потоков(ХП одновременно вызванных) при обработке сообщений(0-32767)
													                         --(0=тоже не позовется процедура)(ставим на время исправления ХП, без потери сообщений) 
													  ,EXECUTE AS OWNER --учетка от имени которой запустится ХП
													  ) 

GO
ALTER QUEUE [dbo].[HW_TargetQueueWWI] WITH STATUS = ON 
                                       ,RETENTION = OFF 
									   ,POISON_MESSAGE_HANDLING (STATUS = OFF)
									   ,ACTIVATION (STATUS = ON 
									               ,PROCEDURE_NAME = Sales.HW_GetNewInvoice
												   ,MAX_QUEUE_READERS = 0
												   ,EXECUTE AS OWNER 
												   ) 

GO



----
--Начинаем тестировать
----

--выполняем бизнес-процедуру
EXEC Sales.HW_SendNewInvoice;

-- мониторим сообщения в очередях
SELECT CAST(message_body AS XML),*
FROM dbo.HW_TargetQueueWWI;

SELECT CAST(message_body AS XML),*
FROM dbo.HW_InitiatorQueueWWI;

--Таргет(получаем сообщение)=вручную запускаем активационные сообщения
EXEC Sales.HW_GetNewInvoice;

--ГДЕ ТЕПЕРЬ БУДЕТ и КАКОЕ сообщение в таргете или в инициаторе???(см. поле message_type_name)

--Initiator(второе пока)
EXEC Sales.HW_ConfirmInvoice;

--список диалогов
SELECT conversation_handle, is_initiator, s.name as 'local service', 
far_service, sc.name 'contract', ce.state_desc
FROM sys.conversation_endpoints ce --представление диалогов(постепенно очищается) чтобы ее не переполнять - --НЕЛЬЗЯ ЗАВЕРШАТЬ ДИАЛОГ ДО ОТПРАВКИ ПЕРВОГО СООБЩЕНИЯ
LEFT JOIN sys.services s
ON ce.service_id = s.service_id
LEFT JOIN sys.service_contracts sc
ON ce.service_contract_id = sc.service_contract_id
ORDER BY conversation_handle;

--смотрим результат записи отчета в таблицу
SELECT * FROM [WideWorldImporters].[Sales].[ClienOrderServiceMsg]

--Теперь поставим 1 для ридеров(очередь должна вызвать все процедуры автоматом)
ALTER QUEUE [dbo].[HW_InitiatorQueueWWI] WITH STATUS = ON --OFF=очередь НЕ доступна(ставим если глобальные проблемы)
                                          ,RETENTION = OFF --ON=все завершенные сообщения хранятся в очереди до окончания диалога
										  ,POISON_MESSAGE_HANDLING (STATUS = OFF) --ON=после 5 ошибок очередь будет отключена
	                                      ,ACTIVATION (STATUS = ON --OFF=очередь не активирует ХП(в PROCEDURE_NAME)(ставим на время исправления ХП, но с потерей сообщений)  
										              ,PROCEDURE_NAME = Sales.HW_ConfirmInvoice
													  ,MAX_QUEUE_READERS = 1000 --количество потоков(ХП одновременно вызванных) при обработке сообщений(0-32767)
													                         --(0=тоже не позовется процедура)(ставим на время исправления ХП, без потери сообщений) 
													  ,EXECUTE AS OWNER --учетка от имени которой запустится ХП
													  ) 

GO
ALTER QUEUE [dbo].[HW_TargetQueueWWI] WITH STATUS = ON 
                                       ,RETENTION = OFF 
									   ,POISON_MESSAGE_HANDLING (STATUS = OFF)
									   ,ACTIVATION (STATUS = ON 
									               ,PROCEDURE_NAME = Sales.HW_GetNewInvoice
												   ,MAX_QUEUE_READERS = 1000
												   ,EXECUTE AS OWNER 
												   ) 

GO

--то же самое в авто режиме
EXEC Sales.HW_SendNewInvoice;

SELECT * FROM [WideWorldImporters].[Sales].[ClienOrderServiceMsg];
