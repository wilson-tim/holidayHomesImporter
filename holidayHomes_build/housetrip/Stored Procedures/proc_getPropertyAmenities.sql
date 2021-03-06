﻿ --------------------------------------------------------------------------------------------
--	2013-11-28 MC
--	housetrip.proc_getPropertyAmenities
--  
--  unpivots BIT fields in housetrip property table (feed) to convert them to amenities
--
-- notes
--		NULLs will be excluded as only matching where bit is set
--------------------------------------------------------------------------------------------
CREATE PROCEDURE housetrip.proc_getPropertyAmenities
  @runId INT,
  @fileId INT
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
		, [non smoking only] = p.non_smoking_only
		, [wheelchair accessible] = p.wheelchair_accessible
		, [pets not allowed] = p.pets_not_allowed
		, [children friendly] = p.children_friendly
		, [entire property] = p.entire_property
		, p.elevator
		FROM housetrip.imp_property p
		-- joining below to get surrogate key imp_amenitiesId, which is really a surrogate imp_propertiesId...
		LEFT OUTER JOIN housetrip.imp_property2amenity p2a
			ON p2a.runId = p.runId
			AND p2a.fileId = p.fileId
			AND p2a.imp_propertiesId = p.imp_propertiesId
		WHERE p.runId = @runId
		AND p.fileId = @fileId
	) src
	UNPIVOT (
		[enabled] FOR sourceAmenityValue IN (kitchen, [non smoking only], [wheelchair accessible], [pets not allowed], [children friendly], [entire property], elevator)
	) as unpvt
	WHERE unpvt.[enabled] = 1;

END