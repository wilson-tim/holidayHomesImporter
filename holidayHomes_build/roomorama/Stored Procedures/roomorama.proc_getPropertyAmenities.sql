 --------------------------------------------------------------------------------------------
--	2014-02-28 MC
--	roomorama.proc_getPropertyAmenities
--  
--  unpivots BIT fields in roomorama property table (feed) to convert them to amenities
--	and splits roomorama.imp_property.amenities into normalised form using CLR function dbo.SplitString
-- 
-- notes
--		NULLs from unpivot will be excluded as only matching where bit is set
--------------------------------------------------------------------------------------------
CREATE PROCEDURE roomorama.proc_getPropertyAmenities
  @runId INT
, @fileId INT
AS
BEGIN
	-- unpivot BIT fields in roomorama property table to convert them to amenities and insert them into roomorama.imp_amenity
 	INSERT roomorama.imp_amenity (sourceId, runId, fileId, amenityValue, [id])
	SELECT DISTINCT unpvt.sourceId, unpvt.runId, unpvt.fileId, unpvt.sourceAmenityValue, unpvt.[id]
	FROM (
		SELECT sourceId
		, runId
		, fileId
		, [id]
		, cleaningAvailable
		, [airport-pickupAvailable]
		, [car-rentalAvailable]
		, conciergeAvailable
		FROM roomorama.imp_property p
		WHERE runId = @runId
		AND fileId = @fileId
	) src
	UNPIVOT (
		[enabled] FOR sourceAmenityValue IN (cleaningAvailable, [airport-pickupAvailable], [car-rentalAvailable], conciergeAvailable)
	) as unpvt
	WHERE [enabled] = 1
UNION ALL
	SELECT DISTINCT sourceId, runId, fileId, split.Item as sourceAmenityValue, [id]
	FROM roomorama.imp_property prop
	CROSS APPLY dbo.SplitString(amenities, ', ') AS split
	WHERE prop.runId = @runId
	AND prop.fileId = @fileId

END