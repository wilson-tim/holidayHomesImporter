--------------------------------------------------------------------------------------------
--  2014-03-10 TW (method copied from roomorama.proc_getPropertyAmenities 2014-02-28 MC)
--	roomorama.proc_getUnitAmenities
--  
--	splits roomorama.imp_property.amenities into normalised form using CLR function dbo.SplitString
-- 
--	notes
--
--------------------------------------------------------------------------------------------
CREATE PROCEDURE [roomorama].[proc_getUnitAmenities]
  @runId INT
, @fileId INT
AS
BEGIN
 	INSERT roomorama.imp_amenity (sourceId, runId, fileId, amenityValue, [id])
	SELECT DISTINCT sourceId
		, runId
		, fileId
		, split.Item AS sourceAmenityValue
		, [unitId]
	FROM roomorama.imp_unit unit
	CROSS APPLY dbo.SplitString(unitAmenities, ', ') AS split
	WHERE unit.runId  = @runId
	AND   unit.fileId = @fileId

END