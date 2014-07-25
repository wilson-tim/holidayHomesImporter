 --------------------------------------------------------------------------------------------
--	2013-12-14 MC
--	waytostay.proc_getPermissionServiceAmenities
--  
--  converts services and (unpivoted) permission fields into amenities (waytostay.imp_amenity)
--	
--------------------------------------------------------------------------------------------
CREATE PROCEDURE waytostay.proc_getPermissionServiceAmenities
  @runId INT
, @fileId INT
AS
BEGIN

	-- convert permissions and services into amenities
	INSERT waytostay.imp_amenity (sourceId, runId, fileId, name, [text], general_amenities_id)

	-- permissions, require an UNPIVOT
	SELECT unpvt.sourceId, unpvt.runId, unpvt.fileId, unpvt.name, NULL AS [text], unpvt.general_amenities_id
	FROM (
		SELECT p.sourceId
		, p.runId
		, p.fileId
		, p.smoking
		, p.pets
		, p.parties
		, p.children
		, [young groups] = p.young_groups
		, ga.general_amenities_id
		FROM waytostay.imp_permissions p
		--re-classing the permissions as general amenities
		INNER JOIN waytostay.imp_general_amenities ga
			ON ga.runId = p.runId
			AND ga.fileId = p.fileId
			AND ga.rooms_and_amenities_id = p.rooms_and_amenities_id
		WHERE p.runId = @runId
		AND p.fileId = @fileId
	) AS src
		UNPIVOT (
			name FOR [column] IN (smoking, pets, parties, children, [young groups])
		) as unpvt

UNION ALL

	--services
	SELECT s.sourceId, s.runId, s.fileId, CAST(dbo.cleanString(s.name) AS nvarchar(50)), NULL AS [text], ga.general_amenities_id
	FROM waytostay.imp_service s
	INNER JOIN waytostay.imp_services ss
		ON ss.runId = s.runId
		AND ss.fileId = s.fileId
		AND ss.services_id = s.services_id
	--re-classing the services as general amenities
	INNER JOIN waytostay.imp_general_amenities ga ON ga.rooms_and_amenities_id = ss.rooms_and_amenities_id
	WHERE s.runId = @runId
	AND s.fileId = @fileId

END
