CREATE TABLE [waytostay].[imp_img] (
    [sourceId] INT             NOT NULL,
    [runId]    INT             NOT NULL,
    [fileId]   INT             NOT NULL,
    [default]  BIT             NULL,
    [text]     NVARCHAR (2000) NULL,
    [media_id] INT             NOT NULL
);
GO

CREATE CLUSTERED INDEX [CX_waytostay_imp_img_runId_fileId_media_id]
    ON [waytostay].[imp_img]([runId] ASC, [fileId] ASC, [media_id] ASC);
GO
