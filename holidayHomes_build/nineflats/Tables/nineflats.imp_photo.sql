CREATE TABLE [nineflats].[imp_photo] (
    [property_photos_Id] BIGINT          NOT NULL,
    [property_Id]        BIGINT          NOT NULL,
    [runId]              INT             NOT NULL,
    [fileId]             INT             NOT NULL,
    [sourceId]           INT             NOT NULL,
    [photo]              NVARCHAR (2000) NULL
);

