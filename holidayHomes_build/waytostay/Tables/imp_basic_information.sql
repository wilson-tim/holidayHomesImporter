CREATE TABLE [waytostay].[imp_basic_information] (
    [sourceId]               INT      NOT NULL,
    [runId]                  INT      NOT NULL,
    [fileId]                 INT      NOT NULL,
    [basic_information_id]   INT      NOT NULL,
    [square_meters]          SMALLINT NULL,
    [sleeps]                 SMALLINT NULL,
    [sleeps_confortably]     SMALLINT NULL,
    [bedrooms]               SMALLINT NULL,
    [bathrooms]              SMALLINT NULL,
    [rooms_and_amenities_id] INT      NOT NULL
);

