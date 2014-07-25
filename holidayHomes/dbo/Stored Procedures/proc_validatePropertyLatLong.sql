--------------------------------------------------------------------------------------------
--	2014-07-14 TW
--	dbo.proc_validatePropertyLatLong
--  
--  validates property latitude and longitude data
--  bad data is replaced by NULLs
--		
-- History
--	2014-07-14 TW New
--------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[proc_validatePropertyLatLong]
AS
BEGIN

	UPDATE dbo.tab_property
	SET   latitude  = NULL
		, longitude = NULL
	WHERE ABS(ISNULL(latitude, 0)) > 90 OR ABS(ISNULL(longitude, 0)) > 180
	;

END
GO