CREATE FUNCTION [dbo].[cleanString]
(
	@dirtyString nvarchar(MAX)
)
RETURNS
	nvarchar(MAX)
AS
	EXTERNAL NAME [clrUtilities].[UserDefinedFunctions].[cleanString];
GO