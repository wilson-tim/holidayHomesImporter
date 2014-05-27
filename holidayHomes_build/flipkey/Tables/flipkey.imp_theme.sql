CREATE TABLE [flipkey].[imp_theme] (
    [property_themes_Id] BIGINT        NOT NULL,
    [property_Id]        BIGINT        NOT NULL,
    [theme_type]         NVARCHAR (10) NULL,
    [theme_description]  NVARCHAR (20) NULL,
    [runId]              INT           NOT NULL,
    [fileId]             INT           NOT NULL,
    [sourceId]           INT           NOT NULL
);

