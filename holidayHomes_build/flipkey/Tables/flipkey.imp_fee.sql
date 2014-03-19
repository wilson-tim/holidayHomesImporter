CREATE TABLE [flipkey].[imp_fee] (
    [property_fees_Id]     BIGINT          NOT NULL,
    [property_Id]          BIGINT          NOT NULL,
    [fee_units]            NVARCHAR (255)  NULL,
    [required]             INT             NULL,
    [property_fee_type_id] INT             NULL,
    [name]                 NVARCHAR (255)  NULL,
    [cost]                 DECIMAL (10, 2) NULL,
    [type]                 NVARCHAR (255)  NULL,
    [description]          NVARCHAR (4000) NULL,
    [runId]                INT             NOT NULL,
    [fileId]               INT             NOT NULL,
    [sourceId]             INT             NOT NULL
);

