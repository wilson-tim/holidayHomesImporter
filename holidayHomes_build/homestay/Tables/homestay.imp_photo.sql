CREATE TABLE [homestay].[imp_photo] (
    [additional_photos_Id] BIGINT          NULL,
    [place_Id]             BIGINT          NULL,
    [photo]                NVARCHAR (2000) NULL,
    [runId]                INT             NULL,
    [fileId]               INT             NULL,
    [sourceId]             INT             NULL
);


GO
CREATE CLUSTERED INDEX [CIX_imp_photo]
    ON [homestay].[imp_photo]([runId] ASC, [fileId] ASC, [place_Id] ASC, [additional_photos_Id] ASC);

