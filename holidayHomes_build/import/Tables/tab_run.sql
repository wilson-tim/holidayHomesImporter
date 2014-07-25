CREATE TABLE [import].[tab_run] (
    [runId]          INT            IDENTITY (1, 1) NOT NULL,
    [rootFolder]     VARCHAR (1000) NULL,
    [runDescription] VARCHAR (1000) NULL,
    [createDate]     DATETIME       DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_run_runId] PRIMARY KEY CLUSTERED ([runId] ASC)
);



