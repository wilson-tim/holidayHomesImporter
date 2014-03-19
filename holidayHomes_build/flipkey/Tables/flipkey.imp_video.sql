CREATE TABLE [flipkey].[imp_video] (
    [property_videos_Id]   BIGINT          NOT NULL,
    [property_Id]          BIGINT          NOT NULL,
    [baseurl]              NVARCHAR (2000)  NULL,
    [description]          NVARCHAR (4000) NULL,
    [last_verified]        DATETIME        NULL,
    [modified]             DATETIME        NULL,
    [order]                INT             NULL,
    [status]               NVARCHAR (255)  NULL,
    [video_source]         NVARCHAR (255)  NULL,
    [video_source_id]      NVARCHAR (255)  NULL,
    [video_source_updated] DATETIME        NULL,
    [video_thumb_filename] NVARCHAR(255)        NULL,
    [runId]                INT             NOT NULL,
    [fileId]               INT             NOT NULL,
    [sourceId]             INT             NOT NULL
);

