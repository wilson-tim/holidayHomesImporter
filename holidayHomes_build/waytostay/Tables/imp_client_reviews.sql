CREATE TABLE [waytostay].[imp_client_reviews] (
    [sourceId]          INT            NOT NULL,
    [runId]             INT            NOT NULL,
    [fileId]            INT            NOT NULL,
    [number_of_reviews] SMALLINT       NULL,
    [overall]           DECIMAL (5, 2) NULL,
    [cico]              DECIMAL (5, 2) NULL,
    [cleaning]          DECIMAL (5, 2) NULL,
    [comfort]           DECIMAL (5, 2) NULL,
    [value_for_money]   DECIMAL (5, 2) NULL,
    [apartment_id]      INT            NOT NULL
);

