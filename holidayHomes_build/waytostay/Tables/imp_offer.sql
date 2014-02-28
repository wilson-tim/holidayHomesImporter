CREATE TABLE [waytostay].[imp_offer] (
    [sourceId]      INT            NOT NULL,
    [runId]         INT            NOT NULL,
    [fileId]        INT            NOT NULL,
    [to]            DATETIME       NULL,
    [from]          DATETIME       NULL,
    [discount_type] NVARCHAR (255) NULL,
    [text]          NVARCHAR (255) NULL,
    [offers_id]     INT            NOT NULL
);

