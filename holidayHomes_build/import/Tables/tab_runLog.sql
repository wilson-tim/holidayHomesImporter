CREATE TABLE [import].[tab_runLog] (
    [runLogId]       INT            IDENTITY (1, 1) NOT NULL,
    [runId]          INT            NOT NULL,
    [messageType]    VARCHAR (255)  NULL,
    [messageContent] VARCHAR (8000) NULL,
    [entryDate]      DATETIME       CONSTRAINT [DF_runLog_entryDate] DEFAULT (getdate()) NOT NULL,
    [sourceId]       INT            NULL,
    PRIMARY KEY CLUSTERED ([runLogId] ASC),
    FOREIGN KEY ([runId]) REFERENCES [import].[tab_run] ([runId])
);



