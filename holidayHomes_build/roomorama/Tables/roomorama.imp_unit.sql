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
GO

CREATE CLUSTERED INDEX [CX_roomorama_imp_unit_runId_fileId_room_Id_units_Id]
    ON [roomorama].[imp_unit]([runId] ASC, [fileId] ASC, [room_Id] ASC, [units_Id] ASC);
GO

