CREATE TABLE [import].[tab_file] (
    [fileId]           INT           IDENTITY (1, 1) NOT NULL,
    [sourceId]         INT           NOT NULL,
    [fullPath]         VARCHAR (800) NOT NULL,
    [fileName]         VARCHAR (255) NOT NULL,
    [registeredDate]   DATETIME      DEFAULT (getdate()) NOT NULL,
    [lastAccessedDate] DATETIME      DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pk_file_src_path] PRIMARY KEY CLUSTERED ([sourceId] ASC, [fullPath] ASC),
    CONSTRAINT [FK_tab_source_file] FOREIGN KEY ([sourceId]) REFERENCES [import].[tab_source] ([sourceId])
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [uix_file_id]
    ON [import].[tab_file]([fileId] ASC);

