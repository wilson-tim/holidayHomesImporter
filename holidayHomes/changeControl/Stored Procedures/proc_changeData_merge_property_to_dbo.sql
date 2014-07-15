--------------------------------------------------------------------------------------------
--	2014-01-24 MC
--	changeControl.proc_changeData_merge_property_to_dbo
--  
--  updates dbo.tab_property for newly uploaded change data
--	control table changeControl.tab_property_change has records for 'INSERT', 'UPDATE' and 'DELETE'
--	data has been pre-uploaded to changeData.tab_property to optimise the merge
--		
-- history
--	2014-01-16 MC created
--  2014-07-15 TW property record archiving feature
--------------------------------------------------------------------------------------------
CREATE PROCEDURE [changeControl].[proc_changeData_merge_property_to_dbo]
AS
BEGIN
	
	--capture affected sources to restrict merge queries
	DECLARE @tmp_changeDataSource TABLE (sourceId INT NOT NULL PRIMARY KEY)

	INSERT @tmp_changeDataSource (sourceId)
	SELECT DISTINCT sourceId FROM changeControl.tab_property_change;

	-- temp table to capture changes for summary output
	DECLARE @tmp_property_changed TABLE ([action] NVARCHAR(10) NOT NULL, propertyId BIGINT NULL);
	
	--use CTE to restrict target records to just the sources we are dealing with
	WITH prop AS (
		SELECT prop.propertyId, prop.sourceId, prop.runId, prop.externalId, prop.externalURL, prop.[description], prop.name, prop.regionName, prop.typeOfProperty, prop.postcode, prop.regionId, prop.cityId
		, prop.cityName, prop.countryCode, prop.latitude, prop.longitude, prop.checkInFrom, prop.checkOutBefore, prop.sizeOfSpaceInSqm, prop.sizeOfSpaceInSqft, prop.cancellationPolicy
		, prop.minimumPricePerNight, prop.currencyCode, prop.numberOfProperBedrooms, prop.numberOfBathrooms, prop.[floor], prop.reviewsCount, prop.averageRating
		, prop.maximumNumberOfPeople, prop.numberOfOtherRoomsWhereGuestsCanSleep, prop.minimumDaysOfStay, prop.dateCreated, prop.lastUpdated
		, prop.propertyHashKey, prop.amenitiesChecksum, prop.photosChecksum, prop.ratesChecksum, prop.isActive, prop.statusUpdated
		FROM dbo.tab_property prop
		INNER JOIN @tmp_changeDataSource src on src.sourceId = prop.sourceId
	)
	MERGE INTO prop
	USING (
		SELECT pc.[action], pc.propertyId, p.sourceId, p.runId, p.externalId, p.externalURL, p.[description], p.name, p.regionName, p.typeOfProperty, p.postcode, p.regionId, p.cityId
		, p.cityName, p.countryCode, p.latitude, p.longitude, p.checkInFrom, p.checkOutBefore, p.sizeOfSpaceInSqm, p.sizeOfSpaceInSqft, p.cancellationPolicy
		, p.minimumPricePerNight, p.currencyCode, p.numberOfProperBedrooms, p.numberOfBathrooms, p.[floor], p.reviewsCount, p.averageRating
		, p.maximumNumberOfPeople, p.numberOfOtherRoomsWhereGuestsCanSleep, p.minimumDaysOfStay, p.dateCreated, p.lastUpdated
		, p.propertyHashKey, p.amenitiesChecksum, p.photosChecksum, p.ratesChecksum, pp.isActive, pp.statusUpdated
		FROM changeControl.tab_property_change pc
		LEFT OUTER JOIN changeData.tab_property p
		ON p.propertyId = pc.propertyId
		LEFT OUTER JOIN dbo.tab_property pp
		ON pp.propertyId = pc.propertyId
	) AS src ([action], propertyId, sourceId, runId, externalId, externalURL, [description], name, regionName, typeOfProperty, postcode, regionId, cityId
		, cityName, countryCode, latitude, longitude, checkInFrom, checkOutBefore, sizeOfSpaceInSqm, sizeOfSpaceInSqft, cancellationPolicy
		, minimumPricePerNight, currencyCode, numberOfProperBedrooms, numberOfBathrooms, [floor], reviewsCount, averageRating
		, maximumNumberOfPeople, numberOfOtherRoomsWhereGuestsCanSleep, minimumDaysOfStay, dateCreated, lastUpdated
		, propertyHashKey, amenitiesChecksum, photosChecksum, ratesChecksum, isActive, statusUpdated
		)
		ON src.propertyId = prop.propertyId

	-- DNE, so insert		
	WHEN NOT MATCHED BY TARGET AND src.[action] = 'INSERT' THEN INSERT (propertyId, sourceId, runId, externalId, externalURL, [description], name, regionName, typeOfProperty, postcode, regionId, cityId
		, cityName, countryCode, latitude, longitude, checkInFrom, checkOutBefore, sizeOfSpaceInSqm, sizeOfSpaceInSqft, cancellationPolicy
		, minimumPricePerNight, currencyCode, numberOfProperBedrooms, numberOfBathrooms, [floor], reviewsCount, averageRating
		, maximumNumberOfPeople, numberOfOtherRoomsWhereGuestsCanSleep, minimumDaysOfStay, dateCreated, lastUpdated
		, propertyHashKey, amenitiesChecksum, photosChecksum, ratesChecksum, isActive, statusUpdated
		) VALUES (src.propertyId, src.sourceId, src.runId, src.externalId, src.externalURL, src.[description], src.name, src.regionName, src.typeOfProperty, src.postcode, src.regionId, src.cityId
		, src.cityName, src.countryCode, src.latitude, src.longitude, src.checkInFrom, src.checkOutBefore, src.sizeOfSpaceInSqm, src.sizeOfSpaceInSqft, src.cancellationPolicy
		, src.minimumPricePerNight, src.currencyCode, src.numberOfProperBedrooms, src.numberOfBathrooms, src.[floor], src.reviewsCount, src.averageRating
		, src.maximumNumberOfPeople, src.numberOfOtherRoomsWhereGuestsCanSleep, src.minimumDaysOfStay, src.dateCreated, src.lastUpdated
		, src.propertyHashKey, src.amenitiesChecksum, src.photosChecksum, src.ratesChecksum, 1, src.dateCreated
		)

	-- exists but different, so update details
	WHEN MATCHED AND src.[action] = 'UPDATE' THEN UPDATE
		SET sourceId = src.sourceId
		, runId = src.runId
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
		, dateCreated = src.dateCreated
		, lastUpdated = src.lastUpdated
		, amenitiesChecksum = src.amenitiesChecksum
		, photosChecksum = src.photosChecksum
		, ratesChecksum = src.ratesChecksum
		-- Property archiving feature next two columns
		, isActive = 1
		, statusUpdated = 
			CASE
				-- Status unchanged
				WHEN src.isActive = 1 THEN src.statusUpdated
				-- Status changed
				ELSE src.lastUpdated
			END
		
	-- marked for delete
	/* No longer DELETEing, see property archiving UPDATE below
	WHEN MATCHED AND src.[action] = 'DELETE' THEN DELETE
	*/

	-- capture changes for logging output
	OUTPUT $action, ISNULL(INSERTED.propertyId, DELETED.propertyId)
	INTO @tmp_property_changed ([action], propertyId);

	-- Property archiving feature
	UPDATE dbo.tab_property
	SET   isActive = 0
		, statusUpdated = GETDATE()
	OUTPUT 'ARCHIVE', DELETED.propertyId
	INTO @tmp_property_changed ([action], propertyId)
	FROM dbo.tab_property p
	INNER JOIN changeControl.tab_property_change pc
	ON pc.propertyId = p.propertyId
	WHERE pc.[action] = 'DELETE';

	IF NOT EXISTS (SELECT * FROM @tmp_property_changed)
		SELECT messageContent = 'PROD dbo.tab_property: no actions';
	ELSE
		-- return select statement of rows so can be logged
		SELECT messageContent = 'PROD dbo.tab_property ' + [action] + ':' + LTRIM(STR(COUNT(propertyId)))
		FROM @tmp_property_changed
		GROUP BY [action];

END