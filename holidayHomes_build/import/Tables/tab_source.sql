CREATE TABLE [import].[tab_source] (
    [sourceId]         INT            NOT NULL,
    [sourceName]       VARCHAR (1000) NOT NULL,
    [ssisPackageName]  VARCHAR (1000) NOT NULL,
    [ssisPackageType]  VARCHAR (50)   NULL,
    [subFolder]        VARCHAR (1000) NOT NULL,
    [fileSpecMask]     VARCHAR (50)   NOT NULL,
    [isActive]         BIT            NOT NULL,
    [createDate]       DATETIME       DEFAULT (getdate()) NOT NULL,
    [lastModifiedDate] DATETIME       DEFAULT (getdate()) NOT NULL,
    [xmlRootElementName] VARCHAR(100) NULL, 
    [xmlRecordElementName] VARCHAR(100) NULL, 
    [splitThreshold] INT NULL DEFAULT 100, 
    [splitSize] INT NULL DEFAULT 50, 
    [sourceExtension] VARCHAR(10) NULL DEFAULT 'xml', 
    [splitExtension] VARCHAR(10) NULL DEFAULT 'split', 
    [maxRecords] INT NULL DEFAULT 3000, 
    PRIMARY KEY CLUSTERED ([sourceId] ASC)
);

