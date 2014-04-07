CREATE TABLE [dbo].[utils_numbers] (
    [number] BIGINT NULL
);
GO

CREATE NONCLUSTERED INDEX [NCI_utils_numbers]
    ON [dbo].[utils_numbers]([number] ASC);
GO