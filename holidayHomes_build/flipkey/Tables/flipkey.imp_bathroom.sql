CREATE TABLE [flipkey].[imp_bathroom] (
    [sourceId]    INT             NOT NULL,
    [runId]       INT             NOT NULL,
    [fileId]      INT             NOT NULL,
    [property_Id] INT             NOT NULL,
    [type]        NVARCHAR (255)  NOT NULL,
    [description] NVARCHAR (4000) NOT NULL
);

