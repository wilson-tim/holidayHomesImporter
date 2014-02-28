CREATE TABLE [homeaway].[imp_rates] (
    [sourceId]    INT            NOT NULL,
    [runId]       INT            NOT NULL,
    [fileId]      INT            NOT NULL,
    [rates_id]    INT            NOT NULL,
    [rentalBasis] NVARCHAR (255) NULL,
    [listing_id]  INT            NULL
);




GO
CREATE NONCLUSTERED INDEX [IX_homeaway_rates_runId_fileId]
    ON [homeaway].[imp_rates]([runId] ASC, [fileId] ASC)
    INCLUDE([rates_id], [listing_id]);

