--------------------------------------------------------------------------------------------
--	2013-11-28 MC
--	staging.proc_staging_merge_rate_to_holidayHomes
--  
--  updates holidayHomes schema tables for newly imported staging data that has changed
--	relies on the ratesChecksum
--	captures updates in changeControl.tab_rate_change to simplify deployment
--	
-- notes
--	2014-01-16 v02 added permanent change capture tables to optimise deployment to production
--	2014-03-16 v03 changed datatype of @tmp_property_changedRates.externalId to NVARCHAR(200)
--  2014-07-10     revised declaration of @tmp_property_changedRates
--------------------------------------------------------------------------------------------
CREATE PROCEDURE [staging].[proc_staging_merge_rate_to_holidayHomes]
  @runId INT
AS
BEGIN
	DECLARE @rowcount INT, @message VARCHAR(255)

	--insert new rate records
	--using merge instead of simple insert to to capture output into change table
	MERGE INTO holidayHomes.tab_rate AS r
	USING (
		SELECT new.propertyId
		, r.periodType
		, r.[from]
		, r.[to]
		, r.[currencyCode]
		, r.runId
		FROM changeControl.tab_property_change new
		INNER JOIN staging.tab_rate r
			ON r.sourceId = new.sourceId
			AND r.externalId = new.externalId
		WHERE new.runId = @runId
		AND new.[action] = 'INSERT'
	) as stg_r
	ON stg_r.propertyId = r.propertyId
	AND stg_r.periodType = r.periodType
	AND stg_r.[from] = r.[from]
	AND stg_r.[to] = r.[to]
	AND stg_r.[currencyCode] = r.[currencyCode]
	WHEN NOT MATCHED BY TARGET THEN INSERT (propertyId, periodType, [from], [to], [currencyCode], runId)
	VALUES (stg_r.propertyId, stg_r.periodType, stg_r.[from], stg_r.[to], stg_r.[currencyCode], stg_r.runId)
	OUTPUT @runId, $action, INSERTED.rateId, INSERTED.propertyId
	INTO changeControl.tab_rate_change (runId, [action], rateId, propertyId);

	-- log counts
	INSERT import.tab_runLog ( runId, messageType, messageContent) 
	SELECT @runId, 'info', messageContent = 'tab_rate INSERT:' + LTRIM(STR(@@ROWCOUNT))

	-- table to capture list of properties with changed rates
	DECLARE @tmp_property_changedRates TABLE
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
		SELECT sourceId, externalId, ratesChecksum
		FROM staging.tab_property
	) AS imp
	ON imp.sourceId = p.sourceId
	AND imp.externalId = p.externalId
	WHEN MATCHED AND imp.ratesChecksum <> p.ratesChecksum THEN 
	UPDATE SET ratesChecksum = imp.ratesChecksum
	OUTPUT $action, DELETED.propertyId, imp.sourceId, imp.externalId
	INTO @tmp_property_changedRates ([action], propertyId, sourceId, externalId);
	*/
	UPDATE holidayHomes.tab_property
	SET ratesChecksum = s.ratesChecksum
	OUTPUT 'UPDATE', DELETED.propertyId, s.sourceId, s.externalId
	INTO @tmp_property_changedRates ([action], propertyId, sourceId, externalId)
	FROM holidayHomes.tab_property p
	INNER JOIN staging.tab_property s
	ON s.sourceId = p.sourceId
	AND s.externalId = p.externalId
	WHERE s.ratesChecksum <> p.ratesChecksum;

	-- log counts
	INSERT import.tab_runLog ( runId, messageType, messageContent) 
	SELECT @runId, 'info'
	, messageContent = 'tab_property Rates CHANGED:' + LTRIM(STR(COUNT(1)))
	FROM @tmp_property_changedRates;

	-- capture tab_property changes for deployment, unless already there, hence merge
	MERGE INTO changeControl.tab_property_change AS pc
	USING @tmp_property_changedRates chg
	ON pc.runId = @runId
	AND chg.propertyId = pc.propertyId
	WHEN NOT MATCHED THEN INSERT (runId, [action], sourceId, propertyId, externalId)
	VALUES  ( @runId, chg.[action], chg.sourceId, chg.propertyId, chg.externalId );

	-- log update
	INSERT import.tab_runLog ( runId, messageType, messageContent) 
	VALUES ( @runId, 'info', 'tab_property Rates changes captured');

	--merge new mappings with existing records (isolated with CTE)
	--then capture changes in changeControl.tab_rate_change for deployment
	WITH r AS 
	(
		SELECT r.rateId, r.propertyId, r.periodType, r.[from], r.[to], r.[currencyCode], r.runId
		FROM holidayHomes.tab_rate r
		INNER JOIN @tmp_property_changedRates chg
		ON chg.propertyId = r.propertyId
	)
	MERGE INTO r
	USING (
		SELECT chg.propertyId, stg_r.periodType, stg_r.[from], stg_r.[to], stg_r.[currencyCode], stg_r.runId
		FROM @tmp_property_changedRates chg
		INNER JOIN staging.tab_rate stg_r
			ON stg_r.sourceId = chg.sourceId
			AND stg_r.externalId = chg.externalId
	) AS stg (propertyId, periodType, [from], [to], [currencyCode], runId)
	ON stg.propertyId = r.propertyId
	AND stg.periodType = r.periodType
	AND stg.[from] = r.[from]
	AND stg.[to] = r.[to]
	AND stg.[currencyCode] = r.[currencyCode]
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (propertyId, periodType, [from], [to], [currencyCode], runId)
		VALUES (stg.propertyId, stg.periodType, stg.[from], stg.[to], stg.[currencyCode], stg.runId)
	WHEN NOT MATCHED BY SOURCE THEN DELETE
	OUTPUT @runId, $action, ISNULL(INSERTED.propertyId, DELETED.propertyId), ISNULL(INSERTED.rateId, DELETED.rateId)
	INTO changeControl.tab_rate_change (runId, [action], propertyId, rateId);

	-- log counts
	INSERT import.tab_runLog ( runId, messageType, messageContent) 
	SELECT @runId, 'info'
	, messageContent = 'tab_rate ' + [action] + ':' + LTRIM(STR(COUNT(1)))
	FROM changeControl.tab_rate_change
	WHERE runId = @runId
	GROUP BY [action];

END