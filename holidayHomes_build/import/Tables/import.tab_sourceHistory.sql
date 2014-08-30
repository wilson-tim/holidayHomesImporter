CREATE TABLE [import].[tab_sourceHistory]
(
	  [runId] INT NOT NULL 
	, [sourceId] INT NOT NULL
	, [active] INT DEFAULT 0 NOT NULL
	, [inactive] INT DEFAULT 0 NOT NULL, 
      CONSTRAINT [PK_tab_sourceHistory] PRIMARY KEY ([runId], [sourceId] ASC) 
	, CONSTRAINT [FK_tab_run_sourceHistory] FOREIGN KEY ([runId]) REFERENCES [import].[tab_run] ([runId])
	, CONSTRAINT [FK_tab_source_sourceHistory] FOREIGN KEY ([sourceId]) REFERENCES [import].[tab_source] ([sourceId])
)
