CREATE TABLE [nineflats].[imp_photo] (
    [property_photos_Id] BIGINT          NOT NULL,
    [property_Id]        BIGINT          NOT NULL,
    [runId]              INT             NOT NULL,
    [fileId]             INT             NOT NULL,
    [sourceId]           INT             NOT NULL,
    [photo]              NVARCHAR (2000) NULL
);




GO
CREATE CLUSTERED INDEX [CIX_imp_photo]
    ON [nineflats].[imp_photo]([runId] ASC, [fileId] ASC, [property_Id] ASC, [property_photos_Id] ASC);

