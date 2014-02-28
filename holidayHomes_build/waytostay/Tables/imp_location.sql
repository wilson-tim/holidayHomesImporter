CREATE TABLE [waytostay].[imp_location] (
    [sourceId]      INT              NOT NULL,
    [runId]         INT              NOT NULL,
    [fileId]        INT              NOT NULL,
    [country]       NVARCHAR (255)   NULL,
    [city]          NVARCHAR (255)   NULL,
    [neighbourhood] NVARCHAR (255)   NULL,
    [area]          NVARCHAR (255)   NULL,
    [longitude]     DECIMAL (19, 16) NULL,
    [latitude]      DECIMAL (19, 16) NULL,
    [apartment_id]  INT              NOT NULL
);

