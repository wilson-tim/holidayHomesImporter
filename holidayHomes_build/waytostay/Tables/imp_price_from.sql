CREATE TABLE [waytostay].[imp_price_from] (
    [sourceId]         INT            NOT NULL,
    [runId]            INT            NOT NULL,
    [fileId]           INT            NOT NULL,
    [person_per_night] DECIMAL (5, 2) NULL,
    [per_night]        DECIMAL (5, 2) NULL,
    [payment_id]       INT            NOT NULL
);

