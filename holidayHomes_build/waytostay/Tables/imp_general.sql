CREATE TABLE [waytostay].[imp_general] (
    [sourceId]             INT             NOT NULL,
    [runId]                INT             NOT NULL,
    [fileId]               INT             NOT NULL,
    [general_id]           INT             NOT NULL,
    [lang]                 NVARCHAR (6)    NULL,
    [reference]            SMALLINT        NULL,
    [name]                 NVARCHAR (255)  NULL,
    [general_url]          NVARCHAR (2000) NULL,
    [reviews_link]         NVARCHAR (2000) NULL,
    [location_link]        NVARCHAR (2000) NULL,
    [availability_link]    NVARCHAR (2000) NULL,
    [updated]              NVARCHAR (255)  NULL,
    [business_suitable]    BIT             NULL,
    [number_of_apartments] SMALLINT        NULL,
    [class]                NVARCHAR (255)  NULL,
    [inside_description]   NVARCHAR (1000) NULL,
    [outside_description]  NVARCHAR (1000) NULL,
    [apartment_id]         INT             NOT NULL
);

