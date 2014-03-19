CREATE TABLE [flipkey].[imp_calendar] (
    [property_calendars_Id] BIGINT   NOT NULL,
    [property_Id]           BIGINT   NOT NULL,
    [property_calendar]     DATETIME NULL,
    [runId]                 INT      NOT NULL,
    [fileId]                INT      NOT NULL,
    [sourceId]              INT      NOT NULL
);

