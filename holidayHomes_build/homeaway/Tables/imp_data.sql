CREATE TABLE [homeaway].[imp_data] (
    [sourceId]     INT            NOT NULL,
    [runId]        INT            NOT NULL,
    [fileId]       INT            NOT NULL,
    [propertyType] NVARCHAR (255) NULL,
    [bedrooms]     INT            NULL,
    [sleeps]       INT            NULL,
    [wc]           INT            NULL,
    [bathrooms]    INT            NULL,
    [showerRooms]  INT            NULL,
    [city]         NVARCHAR (255) NULL,
    [state]        NVARCHAR (255) NULL,
    [country]      NVARCHAR (255) NULL,
    [postalCode]   NVARCHAR (255) NULL,
    [listing_id]   INT            NULL
);




GO
CREATE NONCLUSTERED INDEX [IX_homeaway_data_runId_fileId_listingId]
    ON [homeaway].[imp_data]([runId] ASC, [fileId] ASC, [listing_id] ASC)
    INCLUDE([propertyType], [bedrooms], [sleeps], [bathrooms], [city], [state], [country], [postalCode]);

