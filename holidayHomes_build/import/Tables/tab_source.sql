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
    PRIMARY KEY CLUSTERED ([sourceId] ASC)
);

