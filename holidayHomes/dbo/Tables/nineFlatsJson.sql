CREATE TABLE [dbo].[nineFlatsJson] (
    [externalId] INT            NOT NULL,
    [feedData]   NVARCHAR (MAX) NULL,
    [xmlFormat]  NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_nineFlatsJson] PRIMARY KEY CLUSTERED ([externalId] ASC)
);

