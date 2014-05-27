CREATE FUNCTION [dbo].[SplitString]
(@List NVARCHAR (MAX), @Delimiter NVARCHAR (255))
RETURNS 
     TABLE (
        [Item] NVARCHAR (4000) NULL)
AS
 EXTERNAL NAME [clrUtilities].[UserDefinedFunctions].[SplitString_Multi]

