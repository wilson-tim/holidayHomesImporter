CREATE TABLE [housetrip].[imp_property2amenity] (
    [sourceId]         INT NOT NULL,
    [runId]            INT NOT NULL,
    [fileId]           INT NOT NULL,
    [imp_propertiesId] INT NOT NULL,
    [imp_amenitiesId]  INT NOT NULL
);




GO
CREATE CLUSTERED INDEX [CX_housetrip_imp_property2amenity_runId]
    ON [housetrip].[imp_property2amenity]([runId] ASC, [imp_propertiesId] ASC, [imp_amenitiesId] ASC);

