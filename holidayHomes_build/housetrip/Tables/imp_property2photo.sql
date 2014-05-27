CREATE TABLE [housetrip].[imp_property2photo] (
    [sourceId]         INT NOT NULL,
    [runId]            INT NOT NULL,
    [fileId]           INT NOT NULL,
    [imp_propertiesId] INT NOT NULL,
    [imp_photosId]     INT NOT NULL
);




GO
CREATE CLUSTERED INDEX [CX_housetrip_imp_property2photo_run_file_imp_propertiesId]
    ON [housetrip].[imp_property2photo]([runId] ASC, [fileId] ASC, [imp_propertiesId] ASC);

