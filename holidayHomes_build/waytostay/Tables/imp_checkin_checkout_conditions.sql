CREATE TABLE [waytostay].[imp_checkin_checkout_conditions] (
    [sourceId]                       INT      NOT NULL,
    [runId]                          INT      NOT NULL,
    [fileId]                         INT      NOT NULL,
    [checkin_checkout_conditions_id] INT      NOT NULL,
    [check_in]                       DATETIME NULL,
    [check_out]                      DATETIME NULL,
    [apartment_id]                   INT      NOT NULL
);

