--------------------------------------------------------------------------------------------
--	2013-11-28 MC
--	staging.proc_staging_merge_amenity_to_holidayHomes
--  
--  updates holidayHomes.tab_amenity and holidayHomes.tab_property2amenity for newly imported staging data that has changed
--	relies on tab_property.amenitiesChecksum to detect changes
--	captures updates in changeControl.tab_amenity_change to simplify deployment
--	
-- notes
--	2014-01-16 v02 added permanent change capture tables to optimise deployment to production
--	2014-03-16 v03 changed datatype of @tmp_property_changedAmenities.externalId to NVARCHAR(200)
--  2014-07-10     revised declaration of @tmp_property_changedRates
--------------------------------------------------------------------------------------------
CREATE PROCEDURE [staging].[proc_staging_merge_amenity_to_holidayHomes]
  @runId INT
AS
BEGIN
	DECLARE @rowcount INT, @message VARCHAR(255)

	--first insert any new amenities
	--using merge instead of simple insert to to capture output into change table
	MERGE INTO holidayHomes.tab_amenity AS am
	USING staging.tab_amenity as stg_am
	ON stg_am.amenityId = am.amenityId
	WHEN NOT MATCHED BY TARGET THEN INSERT (amenityId, amenityValue)
	VALUES (stg_am.amenityId, stg_am.amenityValue)
 	OUTPUT @runId, $action, INSERTED.amenityId
	INTO changeControl.tab_amenity_change (runId, [action], amenityId);

	-- log counts
	INSERT import.tab_runLog ( runId, messageType, messageContent) 
	SELECT @runId, 'info', messageContent = 'tab_amenity INSERT:' + LTRIM(STR(@@ROWCOUNT))

	--now insert new property2amenity records
	--using merge instead of simple insert to to capture output into change table
	MERGE INTO holidayHomes.tab_property2amenity AS p2a
	USING (
			SELECT @runId, new.[action], new.propertyId, imp2a.amenityId
			FROM changeControl.tab_property_change new
			INNER JOIN staging.tab_property2amenity imp2a
				ON imp2a.sourceId = new.sourceId
				AND imp2a.externalId = new.externalId
			WHERE new.runId = @runId
			AND new.[action] = 'INSERT'
	) as stg_p2a (runId, [action], propertyId, amenityId)
	ON stg_p2a.propertyId = p2a.propertyId
	AND stg_p2a.amenityId = p2a.amenityId
	WHEN NOT MATCHED BY TARGET THEN INSERT (propertyId, amenityId, runId)
	VALUES (stg_p2a.propertyId, stg_p2a.amenityId, stg_p2a.runId)
	OUTPUT @runId, $action, INSERTED.propertyId, INSERTED.amenityId
	INTO changeControl.tab_property2amenity_change (runId, [action], propertyId, amenityId);

	-- log counts
	INSERT import.tab_runLog ( runId, messageType, messageContent) 
	SELECT @runId, 'info', messageContent = 'tab_property2amenity INSERT:' + LTRIM(STR(@@ROWCOUNT))

	-----------------------
	--now for the amenity updates
	-- amenities persist, so simplest to delete existing and add new records to tab_property2amenity

	-- table to capture list of properties with changed amenities
	DECLARE @tmp_property_changedAmenities TABLE
		(
		  [action] NVARCHAR(10) COLLATE DATABASE_DEFAULT NOT NULL
		, sourceId INT NOT NULL
		, propertyId BIGINT NOT NULL
		, externalId NVARCHAR(100) COLLATE DATABASE_DEFAULT NOT NULL
		, PRIMARY KEY (propertyId, [action])
		);

	--update checksums for existing properties and output list into above table
	/*
	MERGE INTO holidayHomes.tab_property AS p
	USING (
		SELECT sourceId, externalId, amenitiesChecksum
		FROM staging.tab_property
	) AS stg
	ON stg.sourceId = p.sourceId
	AND stg.externalId = p.externalId
	WHEN MATCHED AND stg.amenitiesChecksum <> p.amenitiesChecksum THEN 
	UPDATE SET amenitiesChecksum = stg.amenitiesChecksum
	OUTPUT $action, stg.sourceId, DELETED.propertyId, stg.externalId
	INTO @tmp_property_changedAmenities ([action], sourceId, propertyId, externalId);
	*/
	UPDATE holidayHomes.tab_property
	SET amenitiesChecksum = s.amenitiesChecksum
	OUTPUT 'UPDATE', DELETED.propertyId, s.sourceId, s.externalId
	INTO @tmp_property_changedAmenities ([action], propertyId, sourceId, externalId)
	FROM holidayHomes.tab_property p
	INNER JOIN staging.tab_property s
	ON s.sourceId = p.sourceId
	AND s.externalId = p.externalId
	WHERE s.amenitiesChecksum <> p.amenitiesChecksum;

	-- log counts
	INSERT import.tab_runLog ( runId, messageType, messageContent) 
	SELECT @runId, 'info'
	, messageContent = 'tab_property Amenities CHANGED:' + LTRIM(STR(COUNT(1)))
	FROM @tmp_property_changedAmenities;

	-- capture tab_property changes for deployment, unless already there, hence merge
	MERGE INTO changeControl.tab_property_change AS pc
	USING @tmp_property_changedAmenities chg
	ON pc.runId = @runId
	AND chg.propertyId = pc.propertyId
	WHEN NOT MATCHED THEN INSERT (runId, [action], sourceId, propertyId, externalId)
	VALUES  ( @runId, chg.[action], chg.sourceId, chg.propertyId, chg.externalId );

	-- log update
	INSERT import.tab_runLog ( runId, messageType, messageContent) 
	VALUES ( @runId, 'info', 'tab_property Amenities changes captured');

	--merge new mappings with existing records (isolated with CTE)
	--then capture changes in changeControl.tab_property2amenity_change for deployment
	WITH p2a AS 
	(
		SELECT p2a.propertyId, p2a.amenityId, p2a.runId
		FROM holidayHomes.tab_property2amenity p2a
		INNER JOIN @tmp_property_changedAmenities chg
		ON chg.propertyId = p2a.propertyId
	)
	MERGE INTO p2a
	USING (
		SELECT chg.propertyId, stg2a.amenityId, stg2a.runId
		FROM @tmp_property_changedAmenities chg
		INNER JOIN staging.tab_property2amenity stg2a
			ON stg2a.sourceId = chg.sourceId
			AND stg2a.externalId = chg.externalId
	) AS stg (propertyId, amenityId, runId)
	ON stg.propertyId = p2a.propertyId
	AND stg.amenityId = p2a.amenityId
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (propertyId, amenityId, runId)
		VALUES (stg.propertyId, stg.amenityId, stg.runId)
	WHEN NOT MATCHED BY SOURCE THEN DELETE
	OUTPUT @runId, $action, ISNULL(INSERTED.propertyId, DELETED.propertyId), ISNULL(INSERTED.amenityId, DELETED.amenityId)
	INTO changeControl.tab_property2amenity_change (runId, [action], propertyId, amenityId);

	-- log counts
	INSERT import.tab_runLog ( runId, messageType, messageContent) 
	SELECT @runId, 'info'
	, messageContent = 'tab_property2amenity ' + [action] + ':' + LTRIM(STR(COUNT(1)))
	FROM changeControl.tab_property2amenity_change
	WHERE runId = @runId
	GROUP BY [action];

END