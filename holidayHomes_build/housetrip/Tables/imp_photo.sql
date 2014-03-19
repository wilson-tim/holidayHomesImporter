CREATE TABLE [housetrip].[imp_photo] (
    [sourceId]     INT            NOT NULL,
    [runId]        INT            NOT NULL,
    [fileId]       INT            NOT NULL,
    [imp_photosId] INT            NOT NULL,
    [position]     INT            NULL,
    [url]          NVARCHAR (255) NULL
);




GO
CREATE CLUSTERED INDEX [CX_housetrip_imp_photo_run_file_imp_photosId_position]
    ON [housetrip].[imp_photo]([runId] ASC, [fileId] ASC, [imp_photosId] ASC, [position] ASC);

