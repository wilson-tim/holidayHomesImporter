 --------------------------------------------------------------------------------------------
--	2013-11-28 MC
--	housetrip.proc_getPropertyAmenities
--  
--  unpivots BIT fields in housetrip property table (feed) to convert them to amenities
--
-- notes
--		NULLs will be excluded as only matching where bit is set
--------------------------------------------------------------------------------------------
CREATE PROCEDURE housetrip.proc_getPropertyAmenities
  @runId INT
AS
BEGIN
	-- unpivot BIT fields in housetrip property table to convert them to amenities andinsert them into housetrip.imp_amenity
 	INSERT housetrip.imp_amenity (sourceId, runId, fileId, amenityValue, amenityName, imp_amenitiesId)
	SELECT unpvt.sourceId, unpvt.runId, unpvt.fileId, unpvt.sourceAmenityValue,  unpvt.sourceAmenityValue, unpvt.imp_amenitiesId
	FROM (
		SELECT p.sourceId
		, p.runId
		, p.fileId
		, p.imp_propertiesId
		, p2a.imp_amenitiesId
		, p.kitchen
		, p.non_smoking_only
		, p.wheelchair_accessible
		, p.pets_not_allowed
		, p.children_friendly
		, p.entire_property
		, p.elevator
		FROM housetrip.imp_property p
		-- joining below to get surrogate key imp_amenitiesId, which is really a surrogate imp_propertiesId...
		LEFT OUTER JOIN housetrip.imp_property2amenity p2a
			ON p2a.runId = p.runId
			AND p2a.imp_propertiesId = p.imp_propertiesId
		WHERE p.runId = @runId
	) src
	UNPIVOT (
		[enabled] FOR sourceAmenityValue IN (kitchen, non_smoking_only, wheelchair_accessible, pets_not_allowed, children_friendly, entire_property, elevator)
	) as unpvt
	WHERE unpvt.[enabled] = 1;

END
