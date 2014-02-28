--------------------------------------------------------------------------------------------
--	2013-11-28 MC
--	staging.proc_staging_merge_property_to_holidayHomes
--  
--  updates holidayHomes.tab_property for newly imported staging data that has changed
--	relies on the propertyHashKey for comparison
--	captures updates in changeControl.tab_property_change to simplify deployment
--		both tables are also added to by the other merge procs
--		
-- history
--	2014-01-16 v02 added permanent change capture tables to optimise deployment to production
--	2014-02-07 v03 added thumbnailURL - it wasn't being copied 
--------------------------------------------------------------------------------------------
CREATE PROCEDURE [staging].[proc_staging_merge_property_to_holidayHomes]
  @runId INT
AS
BEGIN
	DECLARE @rowcount INT, @message VARCHAR(255)
	
	--capture affected sources to restrict merge queries
	DECLARE @tmp_stagingSource TABLE (sourceId INT NOT NULL PRIMARY KEY)

	INSERT @tmp_stagingSource (sourceId)
	SELECT DISTINCT sourceId FROM staging.tab_property;

	--use CTE to restrict target records to jsut the source we are dealing with
	WITH prop AS (
		SELECT prop.propertyId, prop.sourceId, prop.runId, prop.externalId, prop.thumbnailUrl, prop.externalURL, prop.[description], prop.name, prop.regionName, prop.typeOfProperty, prop.postcode, prop.regionId, prop.cityId
		, prop.cityName, prop.countryCode, prop.latitude, prop.longitude, prop.checkInFrom, prop.checkOutBefore, prop.sizeOfSpaceInSqm, prop.sizeOfSpaceInSqft, prop.cancellationPolicy
		, prop.minimumPricePerNight, prop.currencyCode, prop.numberOfProperBedrooms, prop.numberOfBathrooms, prop.[floor], prop.reviewsCount, prop.averageRating
		, prop.maximumNumberOfPeople, prop.numberOfOtherRoomsWhereGuestsCanSleep, prop.minimumDaysOfStay, prop.dateCreated, prop.lastUpdated
		, prop.propertyHashKey, prop.amenitiesChecksum, prop.photosChecksum, prop.ratesChecksum
		FROM holidayHomes.tab_property prop
		INNER JOIN @tmp_stagingSource src on src.sourceId = prop.sourceId
	)
	MERGE INTO prop
	USING (
		SELECT sourceId, runId, externalId, thumbnailUrl, externalURL, [description], name, regionName, typeOfProperty, postcode, regionId, cityId
		, cityName, countryCode, latitude, longitude, checkInFrom, checkOutBefore, sizeOfSpaceInSqm, sizeOfSpaceInSqft, cancellationPolicy
		, minimumPricePerNight, currencyCode, numberOfProperBedrooms, numberOfBathrooms, [floor], reviewsCount, averageRating
		, maximumNumberOfPeople, numberOfOtherRoomsWhereGuestsCanSleep, minimumDaysOfStay, propertyHashKey, amenitiesChecksum, photosChecksum, ratesChecksum
		FROM staging.tab_property
	) AS src (sourceId, runId, externalId, thumbnailUrl, externalURL, [description], name, regionName, typeOfProperty, postcode, regionId, cityId
		, cityName, countryCode, latitude, longitude, checkInFrom, checkOutBefore, sizeOfSpaceInSqm, sizeOfSpaceInSqft, cancellationPolicy
		, minimumPricePerNight, currencyCode, numberOfProperBedrooms, numberOfBathrooms, [floor], reviewsCount, averageRating
		, maximumNumberOfPeople, numberOfOtherRoomsWhereGuestsCanSleep, minimumDaysOfStay, propertyHashKey, amenitiesChecksum, photosChecksum, ratesChecksum
		)
		ON (src.sourceId = prop.sourceId
		AND	src.externalId = prop.externalId
		)
	-- exists but different, so update details
	WHEN MATCHED AND src.propertyHashKey <> prop.propertyHashKey THEN UPDATE
		SET sourceId = src.sourceId
		, runId = src.runId
		, thumbnailUrl = src.thumbnailUrl
		, externalURL = src.externalURL
		, [description] = src.[description]
		, name = src.name
		, regionName = src.regionName
		, typeOfProperty = src.typeOfProperty
		, postcode = src.postcode
		, regionId = src.regionId
		, cityId = src.cityId
		, cityName = src.cityName
		, countryCode = src.countryCode
		, latitude = src.latitude
		, longitude = src.longitude
		, checkInFrom = src.checkInFrom
		, checkOutBefore = src.checkOutBefore
		, sizeOfSpaceInSqm = src.sizeOfSpaceInSqm
		, sizeOfSpaceInSqft = src.sizeOfSpaceInSqft
		, cancellationPolicy = src.cancellationPolicy
		, minimumPricePerNight = src.minimumPricePerNight
		, currencyCode = src.currencyCode
		, numberOfProperBedrooms = src.numberOfProperBedrooms
		, numberOfBathrooms = src.numberOfBathrooms
		, [floor] = src.[floor]
		, reviewsCount = src.reviewsCount
		, averageRating = src.averageRating
		, maximumNumberOfPeople = src.maximumNumberOfPeople
		, numberOfOtherRoomsWhereGuestsCanSleep = src.numberOfOtherRoomsWhereGuestsCanSleep
		, minimumDaysOfStay = src.minimumDaysOfStay
		, propertyHashKey = src.propertyHashKey
		, lastUpdated = GETDATE()
		-- don't want to update these yet, they'll be set by the relevant merge procs..
		--, amenitiesChecksum = src.amenitiesChecksum
		--, photosChecksum = src.photosChecksum
		--, ratesChecksum = src.ratesChecksum
		
	-- DNE, so insert		
	WHEN NOT MATCHED BY TARGET THEN INSERT (sourceId, runId, externalId, thumbnailUrl, externalURL, [description], name, regionName, typeOfProperty, postcode, regionId, cityId
		, cityName, countryCode, latitude, longitude, checkInFrom, checkOutBefore, sizeOfSpaceInSqm, sizeOfSpaceInSqft, cancellationPolicy
		, minimumPricePerNight, currencyCode, numberOfProperBedrooms, numberOfBathrooms, [floor], reviewsCount, averageRating
		, maximumNumberOfPeople, numberOfOtherRoomsWhereGuestsCanSleep, minimumDaysOfStay, propertyHashKey, amenitiesChecksum, photosChecksum, ratesChecksum
		) VALUES (src.sourceId, src.runId, src.externalId, src.thumbnailUrl, src.externalURL, src.[description], src.name, src.regionName, src.typeOfProperty, src.postcode, src.regionId, src.cityId
		, src.cityName, src.countryCode, src.latitude, src.longitude, src.checkInFrom, src.checkOutBefore, src.sizeOfSpaceInSqm, src.sizeOfSpaceInSqft, src.cancellationPolicy
		, src.minimumPricePerNight, src.currencyCode, src.numberOfProperBedrooms, src.numberOfBathrooms, src.[floor], src.reviewsCount, src.averageRating
		, src.maximumNumberOfPeople, src.numberOfOtherRoomsWhereGuestsCanSleep, src.minimumDaysOfStay, src.propertyHashKey, src.amenitiesChecksum, src.photosChecksum, src.ratesChecksum
		)
		
	-- not in live table, so delete
	WHEN NOT MATCHED BY SOURCE THEN DELETE

	-- capture changes for deployment and so can insert amenities and photos (below)
	OUTPUT @runId, $action, ISNULL(INSERTED.sourceId, DELETED.sourceId), ISNULL(INSERTED.propertyId, DELETED.propertyId), ISNULL(INSERTED.externalId, DELETED.externalId)
	INTO changeControl.tab_property_change (runId, [action], sourceId, propertyId, externalId);

	-- log counts
	INSERT import.tab_runLog ( runId, messageType, messageContent) 
	SELECT @runId, 'info'
	, messageContent = 'tab_property ' + [action] + ':' + LTRIM(STR(COUNT(1)))
	FROM changeControl.tab_property_change
	WHERE runId = @runId
	GROUP BY [action];
	
END