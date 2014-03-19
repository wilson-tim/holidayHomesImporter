CREATE TABLE [flipkey].[imp_bedroom] (
    [property_bedrooms_Id] BIGINT          NOT NULL,
    [property_Id]          BIGINT          NOT NULL,
    [twin_count]           INT             NULL,
    [other_count]          INT             NULL,
    [description]          NVARCHAR (4000) NULL,
    [standard_count]       INT             NULL,
    [bunk_count]           INT             NULL,
    [queen_count]          INT             NULL,
    [king_count]           INT             NULL,
    [runId]                INT             NOT NULL,
    [fileId]               INT             NOT NULL,
    [sourceId]             INT             NOT NULL
);

