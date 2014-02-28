CREATE TABLE [homeaway].[imp_listing] (
    [sourceId]     INT             NOT NULL,
    [runId]        INT             NOT NULL,
    [fileId]       INT             NOT NULL,
    [listing_Id]   INT             NOT NULL,
    [systemId]     NVARCHAR (255)  NULL,
    [propertyId]   INT             NULL,
    [unitId]       INT             NULL,
    [url]          NVARCHAR (2000) NULL,
    [lastModified] DATETIME        NULL,
    [thumbnailURL] NVARCHAR (2000) NULL,
    [imageURL]     NVARCHAR (2000) NULL,
    [headline]     NVARCHAR (2000) NULL,
    [description]  NVARCHAR (4000) NULL,
    [contentId]    INT             NULL
);




GO
CREATE NONCLUSTERED INDEX [IX_imp_listing_runId_fileId]
    ON [homeaway].[imp_listing]([runId] ASC, [fileId] ASC)
    INCLUDE([sourceId], [listing_Id], [propertyId], [unitId]);

