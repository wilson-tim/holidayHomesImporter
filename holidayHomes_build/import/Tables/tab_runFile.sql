CREATE TABLE [import].[tab_runFile] (
    [runId]        INT      NOT NULL,
    [fileId]       INT      NOT NULL,
    [dateImported] DATETIME DEFAULT (getdate()) NOT NULL,
    [rowsImported] INT      NULL,
    CONSTRAINT [pk_runFile] PRIMARY KEY CLUSTERED ([runId] ASC, [fileId] ASC),
    FOREIGN KEY ([fileId]) REFERENCES [import].[tab_file] ([fileId]),
    FOREIGN KEY ([runId]) REFERENCES [import].[tab_run] ([runId])
);

