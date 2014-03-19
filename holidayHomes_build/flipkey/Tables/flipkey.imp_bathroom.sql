CREATE TABLE [flipkey].[imp_bathroom] (
    [property_bathrooms_Id] BIGINT         NOT NULL,
    [property_Id]           BIGINT         NOT NULL,
    [type]                  NVARCHAR (50)  NULL,
    [description]           NVARCHAR (4000) NULL,
    [runId]                 INT            NOT NULL,
    [fileId]                INT            NOT NULL,
    [sourceId]              INT            NOT NULL
);



