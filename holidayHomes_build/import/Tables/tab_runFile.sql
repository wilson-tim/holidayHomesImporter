CREATE TABLE [import].[tab_runFile] (
    [runId]        INT      NOT NULL,
    [fileId]       INT      NOT NULL,
    [dateImported] DATETIME DEFAULT (getdate()) NOT NULL,
    [rowsImported] INT      NULL,
    CONSTRAINT [pk_runFile] PRIMARY KEY CLUSTERED ([runId] ASC, [fileId] ASC),
    CONSTRAINT [FK_tab_file_runFile] FOREIGN KEY ([fileId]) REFERENCES [import].[tab_file] ([fileId]),
    CONSTRAINT [FK_tab_run_runFile] FOREIGN KEY ([runId]) REFERENCES [import].[tab_run] ([runId])
);



