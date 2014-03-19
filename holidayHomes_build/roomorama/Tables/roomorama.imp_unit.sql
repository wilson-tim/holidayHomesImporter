CREATE TABLE [roomorama].[imp_unit] (
    [units_Id]       INT              NULL,
    [room_Id]        INT              NULL,
    [unitId]         INT              NULL,
    [unitTitle]      NVARCHAR (255)   NULL,
    [unitNum-units]  DECIMAL (28, 10) NULL,
    [unitNum-rooms]  DECIMAL (28, 10) NULL,
    [unitMax-guests] DECIMAL (28, 10) NULL,
    [unitMin-stay]   DECIMAL (28, 10) NULL,
    [unitAmenities]  NVARCHAR (2000)  NULL,
    [unitSmoking]    BIT              NULL,
    [unitPets]       BIT              NULL,
    [unitChildren]   BIT              NULL,
    [unitPrice]      DECIMAL (28, 10) NULL,
    [unitCreated-at] NVARCHAR (20)    NULL,
    [unitUpdated-at] NVARCHAR (20)    NULL,
    [runId]          INT              NULL,
    [fileId]         INT              NULL,
    [sourceId]       INT              NULL
);

