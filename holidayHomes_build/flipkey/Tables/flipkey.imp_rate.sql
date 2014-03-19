CREATE TABLE [flipkey].[imp_rate] (
    [property_rates_Id]         BIGINT          NOT NULL,
    [property_Id]               BIGINT          NOT NULL,
    [weekend_min_rate]          DECIMAL (10, 2) NULL,
    [weeknight_max_rate]        DECIMAL (10, 2) NULL,
    [end_date]                  DATETIME        NULL,
    [week_max_rate]             DECIMAL (10, 2) NULL,
    [weekend_max_rate]          DECIMAL (10, 2) NULL,
    [start_date]                DATETIME        NULL,
    [label]                     NVARCHAR (255)  NULL,
    [weekend_nights]            NVARCHAR (255)  NULL,
    [per_person_per_stay]       DECIMAL (10, 2) NULL,
    [per_person_per_night]      DECIMAL (10, 2) NULL,
    [minimum_length]            INT             NULL,
    [turn_day]                  NVARCHAR (255)  NULL,
    [month_max_rate]            DECIMAL (10, 2) NULL,
    [per_person_over_amount]    DECIMAL (10, 2) NULL,
    [is_changeover_day_defined] NVARCHAR (255)  NULL,
    [weeknight_min_rate]        DECIMAL (10, 2) NULL,
    [changeover_day]            NVARCHAR (255)  NULL,
    [month_min_rate]            DECIMAL (10, 2) NULL,
    [week_min_rate]             DECIMAL (10, 2) NULL,
    [runId]                     INT             NOT NULL,
    [fileId]                    INT             NOT NULL,
    [sourceId]                  INT             NOT NULL
);



