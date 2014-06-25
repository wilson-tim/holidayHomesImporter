--------------------------------------------------------------------------------------------
--	2013-11-28 MC
--	staging.proc_staging_merge_photo_to_holidayHomes
--  
--  updates holidayHomes schema tables for newly imported staging data that has changed
--	relies on the photosChecksum
--	captures updates in changeControl.tab_photo_change to simplify deployment
--	
-- notes
--	2014-01-16 v02 added permanent change capture tables to optimise deployment to production
--	2014-03-16 v03 changed datatype of @tmp_property_changedPhotos.externalId to NVARCHAR(200)
--------------------------------------------------------------------------------------------
CREATE PROCEDURE [staging].[proc_staging_merge_photo_to_holidayHomes]
  @runId INT
AS
BEGIN
	DECLARE @rowcount INT, @message VARCHAR(255)

	--insert new photo records
	--using merge instead of simple insert to to capture output into change table
	MERGE INTO holidayHomes.tab_photo AS ph
	USING (
		SELECT new.propertyId, ph.position, RTRIM(LEFT(ph.url, 255)) AS url, ph.runId
		FROM changeControl.tab_property_change new
		INNER JOIN staging.tab_photo ph
			ON ph.sourceId = new.sourceId
			AND ph.externalId = new.externalId
		WHERE new.runId = @runId
		AND new.[action] = 'INSERT'
	) as stg_ph
	ON stg_ph.propertyId = ph.propertyId
	AND stg_ph.position = ph.position
	AND stg_ph.url = ph.url
	WHEN NOT MATCHED BY TARGET THEN INSERT (propertyId, position, url, runId)
	VALUES (stg_ph.propertyId, stg_ph.position, stg_ph.url, stg_ph.runId)
	OUTPUT @runId, $action, INSERTED.photoId, INSERTED.propertyId
	INTO changeControl.tab_photo_change (runId, [action], photoId, propertyId);

	-- log counts
	INSERT import.tab_runLog ( runId, messageType, messageContent) 
	SELECT @runId, 'info', messageContent = 'tab_photo INSERT:' + LTRIM(STR(@@ROWCOUNT))

	-- table to capture list of properties with changed photos
	DECLARE @tmp_property_changedPhotos TABLE ([action] NVARCHAR(10), sourceId INT NOT NULL, propertyId BIGINT NOT NULL, externalId NVARCHAR(200) NOT NULL);

	--update checksums for existing properties and output list into above table
	MERGE INTO holidayHomes.tab_property AS p
	USING (
		SELECT sourceId, externalId, photosChecksum
		FROM staging.tab_property
	) AS stgp
	ON stgp.sourceId = p.sourceId
	AND stgp.externalId = p.externalId
	WHEN MATCHED AND stgp.photosChecksum <> p.photosChecksum THEN 
	UPDATE SET photosChecksum = stgp.photosChecksum
	OUTPUT $action, DELETED.propertyId, stgp.sourceId, stgp.externalId INTO @tmp_property_changedPhotos ([action], propertyId, sourceId, externalId);

	-- capture tab_property changes for deployment, unless already there, hence merge
	MERGE INTO changeControl.tab_property_change AS pc
	USING @tmp_property_changedPhotos chg
	ON pc.runId = @runId
	AND chg.propertyId = pc.propertyId
	WHEN NOT MATCHED THEN INSERT (runId, [action], sourceId, propertyId, externalId)
	VALUES  ( @runId, chg.[action], chg.sourceId, chg.propertyId, chg.externalId );

	-- log counts
	INSERT import.tab_runLog ( runId, messageType, messageContent) 
	SELECT @runId, 'info'
	, messageContent = 'tab_property Photos CHANGED:' + LTRIM(STR(COUNT(1)))
	FROM @tmp_property_changedPhotos;

	--merge new mappings with existing records (isolated with CTE)
	--then capture changes in changeControl.tab_photo_change for deployment
	WITH ph AS 
	(
		SELECT ph.photoId, ph.propertyId, ph.position, ph.url, ph.runId
		FROM holidayHomes.tab_photo ph
		INNER JOIN @tmp_property_changedPhotos chg
		ON chg.propertyId = ph.propertyId
	)
	MERGE INTO ph
	USING (
		SELECT chg.propertyId, stgph.position, RTRIM(LEFT(stgph.url, 255)) AS url, stgph.runId
		FROM @tmp_property_changedPhotos chg
		INNER JOIN staging.tab_photo stgph
			ON stgph.sourceId = chg.sourceId
			AND stgph.externalId = chg.externalId
	) AS stg (propertyId, position, url, runId)
	ON stg.propertyId = ph.propertyId
	AND stg.position = ph.position
	AND stg.url = ph.url
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (propertyId, position, url, runId)
		VALUES (stg.propertyId, stg.position, stg.url, stg.runId)
	WHEN NOT MATCHED BY SOURCE THEN DELETE
	OUTPUT @runId, $action, ISNULL(INSERTED.photoId, DELETED.photoId), ISNULL(INSERTED.propertyId, DELETED.propertyId)
	INTO changeControl.tab_photo_change (runId, [action], photoId, propertyId);

END