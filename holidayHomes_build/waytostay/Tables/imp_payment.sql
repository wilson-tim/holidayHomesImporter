CREATE TABLE [waytostay].[imp_payment] (
    [sourceId]       INT            NOT NULL,
    [runId]          INT            NOT NULL,
    [fileId]         INT            NOT NULL,
    [payment_id]     INT            NOT NULL,
    [currency]       NVARCHAR (3)   NULL,
    [minimum_nights] SMALLINT       NULL,
    [damage_deposit] DECIMAL (5, 2) NULL,
    [apartment_id]   INT            NOT NULL
);

