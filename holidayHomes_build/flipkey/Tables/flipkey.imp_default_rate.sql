CREATE TABLE [flipkey].[imp_default_rate] (
    [property_default_rates_Id] BIGINT          NOT NULL,
    [property_Id]               BIGINT          NOT NULL,
    [modified]                  DATETIME        NULL,
    [minimum_length]            INT             NULL,
    [day_max_rate]              DECIMAL (10, 2) NULL,
    [day_min_rate]              DECIMAL (10, 2) NULL,
    [month_max_rate]            DECIMAL (10, 2) NULL,
    [month_min_rate]            DECIMAL (10, 2) NULL,
    [week_max_rate]             DECIMAL (10, 2) NULL,
    [week_min_rate]             DECIMAL (10, 2) NULL,
    [runId]                     INT             NOT NULL,
    [fileId]                    INT             NOT NULL,
    [sourceId]                  INT             NOT NULL
);



