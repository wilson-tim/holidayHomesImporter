CREATE TABLE [flipkey].[imp_photo] (
    [property_photos_Id]   BIGINT          NOT NULL,
    [property_Id]          BIGINT          NOT NULL,
    [description]          NVARCHAR (4000) NULL,
    [has_full]             NVARCHAR (255)  NULL,
    [base_url]             NVARCHAR (2000) NULL,
    [photo_file_name]      NVARCHAR (255)  NULL,
    [height]               INT             NULL,
    [original_height]      INT             NULL,
    [largest_image_prefix] NVARCHAR (10)   NULL,
    [photo_type]           NVARCHAR (255)  NULL,
    [width]                INT             NULL,
    [original_width]       INT             NULL,
    [order]                INT             NULL,
    [runId]                INT             NOT NULL,
    [fileId]               INT             NOT NULL,
    [sourceId]             INT             NOT NULL
);



