CREATE TABLE [waytostay].[imp_service] (
    [sourceId]    INT            NOT NULL,
    [runId]       INT            NOT NULL,
    [fileId]      INT            NOT NULL,
    [name]        NVARCHAR (255) NULL,
    [extra_cost]  BIT            NULL,
    [on_request]  BIT            NULL,
    [services_id] INT            NOT NULL
);

