CREATE TABLE [waytostay].[imp_permissions] (
    [sourceId]               INT            NOT NULL,
    [runId]                  INT            NOT NULL,
    [fileId]                 INT            NOT NULL,
    [smoking]                NVARCHAR (255) NULL,
    [pets]                   NVARCHAR (255) NULL,
    [parties]                NVARCHAR (255) NULL,
    [children]               NVARCHAR (255) NULL,
    [young_groups]           NVARCHAR (255) NULL,
    [rooms_and_amenities_id] INT            NOT NULL
);

