CREATE TABLE [waytostay].[imp_late_checkin] (
    [sourceId]                       INT            NOT NULL,
    [runId]                          INT            NOT NULL,
    [fileId]                         INT            NOT NULL,
    [in]                             DATETIME       NULL,
    [out]                            DATETIME       NULL,
    [extra_fee]                      DECIMAL (5, 2) NULL,
    [checkin_checkout_conditions_id] INT            NOT NULL
);

