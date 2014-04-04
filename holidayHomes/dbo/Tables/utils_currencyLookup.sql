CREATE TABLE [dbo].[utils_currencyLookup] (
    [id]          NCHAR (3)  NOT NULL,
    [localId]     NCHAR (3)  NOT NULL,
    [ask]         FLOAT (53) NULL,
    [bid]         FLOAT (53) NULL,
    [rate]        FLOAT (53) NULL,
    [lastUpdated] DATETIME   CONSTRAINT [DF_Table_1_updatedAt] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_utils_currencyLookup] PRIMARY KEY CLUSTERED ([id] ASC, [localId] ASC)
);



