CREATE TABLE [import].[tab_source] (
    [sourceId]             INT            NOT NULL,
    [sourceName]           VARCHAR (1000) NOT NULL,
    [ssisPackageName]      VARCHAR (1000) NOT NULL,
    [ssisPackageType]      VARCHAR (50)   NULL,
    [subFolder]            VARCHAR (1000) NOT NULL,
    [fileSpecMask]         VARCHAR (50)   NOT NULL,
    [isActive]             BIT            NOT NULL,
    [createDate]           DATETIME       DEFAULT (getdate()) NOT NULL,
    [lastModifiedDate]     DATETIME       DEFAULT (getdate()) NOT NULL,
    [xmlRootElementName]   VARCHAR (100)  NULL,
    [xmlRecordElementName] VARCHAR (100)  NULL,
    [splitThreshold]       INT            DEFAULT ((100)) NULL,
    [splitSize]            INT            DEFAULT ((50)) NULL,
    [sourceExtension]      VARCHAR (10)   DEFAULT ('xml') NULL,
    [splitExtension]       VARCHAR (10)   DEFAULT ('split') NULL,
    [maxRecords]           INT            DEFAULT ((3000)) NULL,
    CONSTRAINT [PK_source_sourceId] PRIMARY KEY CLUSTERED ([sourceId] ASC)
);



