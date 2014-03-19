CREATE TABLE [flipkey].[imp_booked_date] (
    [property_booked_dates_Id] BIGINT   NOT NULL,
    [property_Id]              BIGINT   NOT NULL,
    [booked_date]              DATETIME NULL,
    [runId]                    INT      NOT NULL,
    [fileId]                   INT      NOT NULL,
    [sourceId]                 INT      NOT NULL
);

