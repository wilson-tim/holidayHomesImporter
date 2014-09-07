/*****************************************************************************
** dbo.proc_createNewProperty
** stored procedure
**
** Description
** Create a new property record and associated amenity, photo and rate records
** on the build and production databases
**
** Parameters
** @xmlString = xml document containing data for new property record and child records (required)
**
** Returned
** Return value 0 (success), otherwise -1 (failure)
**
** History
** 16/08/2014  TW  New
** 17/08/2014  TW  Continued development
** 23/08/2014  TW  Continued development
** 25/08/2014  TW  Continued development
**
*****************************************************************************/
--IF OBJECT_ID (N'dbo.proc_createNewProperty', N'P') IS NOT NULL
--    DROP PROCEDURE dbo.proc_createNewProperty;
--GO
CREATE PROCEDURE dbo.proc_createNewProperty
	    @xmlString VARCHAR(MAX)
	  , @propertyId BIGINT OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE
		  @xmlDoc XML
		, @errortext VARCHAR(500)
		, @sourceId INT
		, @runId INT
--		, @propertyId BIGINT
		, @externalId NVARCHAR(100)
		, @propertyCount INT
		, @property2amenityCount INT
		, @photoCount INT
		, @rateCount INT

	-- tab_property
		, @externalUrl NVARCHAR(2000)
		, @thumbnailUrl NVARCHAR(2000)
		, @name NVARCHAR(255)
		, @description NVARCHAR(4000)
		, @regionName NVARCHAR(255)
		, @typeOfProperty NVARCHAR(50)
		, @postcode NVARCHAR(255)
		, @regionId INT
		, @cityId INT
		, @cityName NVARCHAR(255)
		, @stateName NVARCHAR(255)
		, @countryCode NVARCHAR(2)
		, @latitude FLOAT
		, @longitude FLOAT
		, @checkInFrom TIME(7)
		, @checkOutBefore TIME(7)
		, @sizeOfSpaceInSqm INT
		, @sizeOfSpaceInSqft INT
		, @cancellationPolicy NVARCHAR(255)
		, @minimumPricePerNight INT
		, @propertyCurrencyCode NVARCHAR(3)
		, @numberOfProperBedrooms INT
		, @numberOfBathrooms INT
		, @floor NVARCHAR(255)
		, @reviewsCount INT
		, @averageRating FLOAT
		, @maximumNumberOfPeople INT
		, @numberOfOtherRoomsWhereGuestsCanSleep INT
		, @minimumDaysOfStay INT

	-- tab_amenity
		, @amenityValue NVARCHAR(50)

	-- tab_photo
		, @position INT
		, @url NVARCHAR(255)

	-- tab_rate
		, @periodType NVARCHAR(255)
		, @from FLOAT
		, @to FLOAT
		, @rateCurrencyCode NVARCHAR(3)

	;

	-- Convert the passed XML string to XML data type
	BEGIN TRY
		SET @xmlDoc = CAST(@xmlString AS XML);
	END TRY
	BEGIN CATCH
		-- Any errors arising are likely to be due to incorrect encoding
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

/*
** OK, ready to start now, initialise a new import run
*/
	BEGIN TRANSACTION createNewProperty;

	-- 10 = Compare and Share Limited
	SET @sourceId = 10;

	SET @propertyCount = 0;
	SET @property2amenityCount = 0;
	SET @photoCount = 0;
	SET @rateCount = 0;

	BEGIN TRY
		INSERT holidayHomes_build.import.tab_run
			(
			  rootFolder
			, runDescription
			)
		VALUES
			(
			  'manual'
			, 'import ' + LTRIM(RTRIM(CONVERT(VARCHAR(20), GETDATE(), 120)))
			);

		SET @runId = @@IDENTITY;
	END TRY
	BEGIN CATCH
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	BEGIN TRY
		INSERT holidayHomes_build.import.tab_runLog
			(
			  runId
			, messageType
			, messageContent
			)
		VALUES
			(
			  @runId
			, 'info'
			, 'Importing XML string length ' + LTRIM(RTRIM(STR(LEN(@xmlString))))
			);
	END TRY
	BEGIN CATCH
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	BEGIN TRY
		INSERT holidayHomes_build.import.tab_runLog
			(
			  runId
			, messageType
			, messageContent
			)
		VALUES
			(
			  @runId
			, 'info'
			, 'Run Started'
			);
	END TRY
	BEGIN CATCH
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

/*
** Read in property data
*/

	IF OBJECT_ID('tempdb..#tempTab_Property') IS NOT NULL
	BEGIN
		DROP TABLE #tempTab_Property;
	END

	BEGIN TRY
		SELECT 
 			  xmldoc.xmlRecord.value('externalId[1]','NVARCHAR(100)') AS 'externalId'
 			, xmldoc.xmlRecord.value('externalURL[1]','NVARCHAR(2000)') AS 'externalURL'
 			, xmldoc.xmlRecord.value('thumbnailURL[1]','NVARCHAR(2000)') AS 'thumbnailURL'
 			, xmldoc.xmlRecord.value('name[1]','NVARCHAR(255)') AS 'name'
 			, xmldoc.xmlRecord.value('description[1]','NVARCHAR(4000)') AS 'description'
 			, xmldoc.xmlRecord.value('regionName[1]','NVARCHAR(255)') AS 'regionName'
 			, xmldoc.xmlRecord.value('typeOfProperty[1]','NVARCHAR(50)') AS 'typeOfProperty'
 			, xmldoc.xmlRecord.value('postcode[1]','NVARCHAR(255)') AS 'postcode'
 			, xmldoc.xmlRecord.value('regionId[1]','INT') AS 'regionId'
 			, xmldoc.xmlRecord.value('cityId[1]','INT') AS 'cityId'
 			, xmldoc.xmlRecord.value('cityName[1]','NVARCHAR(255)') AS 'cityName'
 			, xmldoc.xmlRecord.value('stateName[1]','NVARCHAR(255)') AS 'stateName'
 			, xmldoc.xmlRecord.value('countryCode[1]','NVARCHAR(2)') AS 'countryCode'
 			, xmldoc.xmlRecord.value('latitude[1]','FLOAT') AS 'latitude'
 			, xmldoc.xmlRecord.value('longitude[1]','FLOAT') AS 'longitude'
 			, xmldoc.xmlRecord.value('checkInFrom[1]','TIME(7)') AS 'checkInFrom'
 			, xmldoc.xmlRecord.value('checkOutBefore[1]','TIME(7)') AS 'checkOutBefore'
 			, xmldoc.xmlRecord.value('sizeOfSpaceInSqm[1]','INT') AS 'sizeOfSpaceInSqm'
 			, xmldoc.xmlRecord.value('sizeOfSpaceInSqft[1]','INT') AS 'sizeOfSpaceInSqft'
 			, xmldoc.xmlRecord.value('cancellationPolicy[1]','NVARCHAR(255)') AS 'cancellationPolicy'
 			, xmldoc.xmlRecord.value('minimumPricePerNight[1]','INT') AS 'minimumPricePerNight'
 			, xmldoc.xmlRecord.value('propertyCurrencyCode[1]','NVARCHAR(3)') AS 'propertyCurrencyCode'
 			, xmldoc.xmlRecord.value('numberOfProperBedrooms[1]','INT') AS 'numberOfProperBedrooms'
 			, xmldoc.xmlRecord.value('numberOfBathrooms[1]','INT') AS 'numberOfBathrooms'
 			, xmldoc.xmlRecord.value('floor[1]','NVARCHAR(255)') AS 'floor'
 			, xmldoc.xmlRecord.value('reviewsCount[1]','INT') AS 'reviewsCount'
 			, xmldoc.xmlRecord.value('averageRating[1]','FLOAT') AS 'averageRating'
 			, xmldoc.xmlRecord.value('maximumNumberOfPeople[1]','INT') AS 'maximumNumberOfPeople'
 			, xmldoc.xmlRecord.value('numberOfOtherRoomsWhereGuestsCanSleep[1]','INT') AS 'numberOfOtherRoomsWhereGuestsCanSleep'
 			, xmldoc.xmlRecord.value('minimumDaysOfStay[1]','INT') AS 'minimumDaysOfStay'
			, NULL AS sourceId
			, NULL AS propertyHashKey
			, NULL AS amenitiesChecksum
			, NULL AS photosChecksum
			, NULL AS ratesChecksum
		INTO #tempTab_Property
		FROM @xmlDoc.nodes('/properties/property') AS xmldoc(xmlRecord);

		SET @propertyCount = @@ROWCOUNT;
	END TRY
	BEGIN CATCH
		SET @errortext = ERROR_MESSAGE();
		GOTO ERROREXIT;
	END CATCH

	IF @propertyCount < 1
	BEGIN
		SET @errortext = 'No property row found';
		GOTO errorexit;
	END

	IF @propertyCount > 1
	BEGIN
		SET @errortext = 'Multiple property rows found';
		GOTO errorexit;
	END

/*
** Read in amenity data
*/

	IF OBJECT_ID('tempdb..#tempTab_Property2Amenity') IS NOT NULL
	BEGIN
		DROP TABLE #tempTab_Property2Amenity;
	END

	BEGIN TRY
		SELECT 
 			  xmldoc.xmlRecord.value('amenityValue[1]','NVARCHAR(50)') AS 'amenityValue'
			, NULL AS sourceId
			, NULL AS externalId
			, NULL AS amenityId
		INTO #tempTab_Property2Amenity
		FROM @xmlDoc.nodes('/properties/property/amenities/amenity') AS xmldoc(xmlRecord);

		SET @property2amenityCount = @@ROWCOUNT;
	END TRY
	BEGIN CATCH
		SET @errortext = ERROR_MESSAGE();
		GOTO ERROREXIT;
	END CATCH

/*
** Read in photo data
*/

	IF OBJECT_ID('tempdb..#tempTab_Photo') IS NOT NULL
	BEGIN
		DROP TABLE #tempTab_Photo;
	END

	BEGIN TRY
		SELECT 
 			  xmldoc.xmlRecord.value('position[1]','INT') AS 'position'
 			, xmldoc.xmlRecord.value('url[1]','NVARCHAR(255)') AS 'url'
			, NULL AS sourceId
			, NULL AS externalId
		INTO #tempTab_Photo
		FROM @xmlDoc.nodes('/properties/property/photos/photo') AS xmldoc(xmlRecord);

		SET @photoCount = @@ROWCOUNT;
	END TRY
	BEGIN CATCH
		SET @errortext = ERROR_MESSAGE();
		GOTO ERROREXIT;
	END CATCH

/*
** Read in rate data
*/

	IF OBJECT_ID('tempdb..#tempTab_Rate') IS NOT NULL
	BEGIN
		DROP TABLE #tempTab_Rate;
	END

	BEGIN TRY
		SELECT 
 			  xmldoc.xmlRecord.value('periodType[1]','NVARCHAR(255)') AS 'periodType'
 			, xmldoc.xmlRecord.value('from[1]','FLOAT') AS 'from'
 			, xmldoc.xmlRecord.value('to[1]','FLOAT') AS 'to'
 			, xmldoc.xmlRecord.value('rateCurrencyCode[1]','NVARCHAR(3)') AS 'rateCurrencyCode'
			, NULL AS sourceId
			, NULL AS externalId
		INTO #tempTab_Rate
		FROM @xmlDoc.nodes('/properties/property/rates/rate') AS xmldoc(xmlRecord);

		SET @rateCount = @@ROWCOUNT;
	END TRY
	BEGIN CATCH
		SET @errortext = ERROR_MESSAGE();
		GOTO ERROREXIT;
	END CATCH

/*
** Update build holidayHomes tables
** This will generate the propertyId, externalId, hash key and check sums, amongst other processing
*/

-- property
	BEGIN TRY
		INSERT INTO holidayHomes_build.holidayHomes.tab_property
			(
			  sourceId
			, runId
			, externalId
			, thumbnailUrl
			, externalURL
			, [description]
			, name
			, regionName
			, typeOfProperty
			, postcode
			, regionId
			, cityId
			, cityName
			, countryCode
			, latitude
			, longitude
			, checkInFrom
			, checkOutBefore
			, sizeOfSpaceInSqm
			, sizeOfSpaceInSqft
			, cancellationPolicy
			, minimumPricePerNight
			, currencyCode
			, numberOfProperBedrooms
			, numberOfBathrooms
			, [floor]
			, reviewsCount
			, averageRating
			, maximumNumberOfPeople
			, numberOfOtherRoomsWhereGuestsCanSleep
			, minimumDaysOfStay
			, dateCreated
			)
		SELECT
			  sourceId = @sourceId
			, runId = @runId
			, externalId = CAST(NEWID() AS NVARCHAR(100)) -- temporary externalId value
			, thumbnailUrl
			, externalURL
			, [description]
			, name
			, regionName
			, typeOfProperty
			, postcode
			, regionId
			, cityId
			, cityName
			, countryCode
			, latitude
			, longitude
			, checkInFrom
			, checkOutBefore
			, sizeOfSpaceInSqm
			, sizeOfSpaceInSqft
			, cancellationPolicy
			, minimumPricePerNight
			, propertyCurrencyCode
			, numberOfProperBedrooms
			, numberOfBathrooms
			, [floor]
			, reviewsCount
			, averageRating
			, maximumNumberOfPeople
			, numberOfOtherRoomsWhereGuestsCanSleep
			, minimumDaysOfStay
			, GETDATE()
		FROM #tempTab_Property;

		SET @propertyId = @@IDENTITY;
	END TRY
	BEGIN CATCH
		SET @errortext = ERROR_MESSAGE();
		GOTO ERROREXIT;
	END CATCH

	SELECT @externalId = externalId
		, @thumbnailUrl = thumbnailURL
	FROM #tempTab_Property;

-- Assuming for the time being that we are always creating a new property
/*
	IF @externalId IS NULL OR @externalId = 0
	BEGIN
		SET @externalId = LTRIM(RTRIM(STR(@propertyId)));
	END
*/
	SET @externalId = LTRIM(RTRIM(STR(@propertyId)));

	IF @thumbnailUrl IS NULL OR @thumbnailUrl = ''
	BEGIN
		SELECT TOP 1 @thumbnailurl = url
		FROM #tempTab_Photo
		ORDER BY position;
	END

	BEGIN TRY
		UPDATE holidayHomes_build.holidayHomes.tab_property
		SET
			  sourceID = @sourceId
			, externalId = @externalId
			, thumbnailUrl = @thumbnailUrl
			WHERE propertyId = @propertyId;
	END TRY
	BEGIN CATCH
		SET @errortext = ERROR_MESSAGE();
		GOTO ERROREXIT;
	END CATCH

	IF @property2amenityCount > 0
	BEGIN
		UPDATE #tempTab_Property2Amenity
		SET
			  sourceID = @sourceId
			, externalId = @externalId
			, amenityId = ah.amenityId
		FROM #tempTab_Property2Amenity p2a
		INNER JOIN holidayHomes_build.holidayHomes.tab_amenity ah
		ON ah.amenityValue = p2a.amenityValue;
	END

	IF @photoCount > 0
	BEGIN
		UPDATE #tempTab_Photo
		SET
			  sourceID = @sourceId
			,  externalId = @externalId;
	END

	IF @rateCount > 0
	BEGIN
		UPDATE #tempTab_Rate
		SET
			  sourceID = @sourceId
			,  externalId = @externalId;
	END

-- property2amenity
	IF @property2amenityCount > 0
	BEGIN
		BEGIN TRY
			INSERT INTO holidayHomes_build.holidayHomes.tab_property2amenity
				(
				  propertyId
				, amenityId
				, runId
				)
			SELECT
				  propertyId = @propertyId
				, ah.amenityId
				, runId = @runId
			FROM #tempTab_Property2Amenity at
			INNER JOIN holidayHomes_build.holidayHomes.tab_amenity ah
			ON ah.amenityValue = at.amenityValue;
		END TRY
		BEGIN CATCH
			SET @errortext = ERROR_MESSAGE();
			GOTO ERROREXIT;
		END CATCH
	END

-- photo
	IF @photoCount > 0
	BEGIN
		BEGIN TRY
			INSERT INTO holidayHomes_build.holidayHomes.tab_photo
				(
				  propertyId
				, position
				, url
				, runId
				)
			SELECT
				  propertyId = @propertyId
				, position
				, url
				, runId = @runId 
			FROM #tempTab_Photo;
		END TRY
		BEGIN CATCH
			SET @errortext = ERROR_MESSAGE();
			GOTO ERROREXIT;
		END CATCH
	END

-- rate
	IF @rateCount > 0
	BEGIN
		BEGIN TRY
			INSERT INTO holidayHomes_build.holidayHomes.tab_rate
				(
				  propertyId
				, periodType
				, [to]
				, [from]
				, currencyCode
				, runId
				)
			SELECT
				  propertyId = @propertyId
				, periodType
				, [to]
				, [from]
				, rateCurrencyCode
				, runId = @runId 
			FROM #tempTab_Rate;
		END TRY
		BEGIN CATCH
			SET @errortext = ERROR_MESSAGE();
			GOTO ERROREXIT;
		END CATCH
	END

-- property final pass
	BEGIN TRY
		UPDATE holidayHomes_build.holidayHomes.tab_property
		SET
			  lastUpdated = dateCreated
			, isActive = 1
			, statusUpdated = dateCreated
			, propertyHashKey = HASHBYTES ('MD5'
				, ISNULL(thumbnailUrl, 'NA') + '|'
				+ ISNULL(externalURL, 'NA') + '|'
				+ ISNULL([description], 'NA') + '|'
				+ ISNULL(name, 'NA') + '|'
				+ ISNULL(regionName, 'NA') + '|'
				+ ISNULL(typeOfProperty, 'NA') + '|'
				+ ISNULL(postcode, 'NA') + '|'
				+ ISNULL(CAST(regionId AS NVARCHAR), 'NA') + '|'
				+ ISNULL(CAST(cityId AS NVARCHAR), 'NA') + '|'
				+ ISNULL(cityName, 'NA') + '|'
				+ ISNULL(stateName, 'NA') + '|'
				+ ISNULL(countryCode, 'NA') + '|'
				+ ISNULL(CAST(latitude AS NVARCHAR), 'NA') + '|'
				+ ISNULL(CAST(longitude AS NVARCHAR), 'NA') + '|'
				+ ISNULL(CAST(checkInFrom AS NVARCHAR), 'NA') + '|'
				+ ISNULL(CAST(checkOutBefore AS NVARCHAR), 'NA') + '|'
				+ ISNULL(CAST(sizeOfSpaceInSqm AS NVARCHAR), 'NA') + '|'
				+ ISNULL(CAST(sizeOfSpaceInSqft AS NVARCHAR), 'NA') + '|'
				+ ISNULL(cancellationPolicy, 'NA') + '|'
				+ ISNULL(CAST(minimumPricePerNight AS NVARCHAR), 'NA') + '|'
				+ ISNULL(currencyCode, 'NA') + '|'
				+ ISNULL(CAST(numberOfProperBedrooms AS NVARCHAR), 'NA') + '|'
				+ ISNULL(CAST(numberOfBathrooms AS NVARCHAR), 'NA') + '|'
				+ ISNULL([floor], 'NA') + '|'
				+ ISNULL(CAST(reviewsCount AS NVARCHAR), 'NA') + '|'
				+ ISNULL(CAST(averageRating AS NVARCHAR), 'NA') + '|'
				+ ISNULL(CAST(maximumNumberOfPeople AS NVARCHAR), 'NA') + '|'
				+ ISNULL(CAST(numberOfOtherRoomsWhereGuestsCanSleep AS NVARCHAR), 'NA') + '|'
				+ ISNULL(CAST(minimumDaysOfStay AS NVARCHAR), 'NA'))
		WHERE propertyId = @propertyId;
	END TRY
	BEGIN CATCH
		SET @errortext = ERROR_MESSAGE();
		GOTO ERROREXIT;
	END CATCH

	--aggregate checksum for the amenities
	BEGIN TRY
		UPDATE p
		SET amenitiesChecksum = ISNULL(agg.amenitiesChecksum, 0)
		FROM holidayHomes_build.holidayHomes.tab_property p
		LEFT OUTER JOIN (
			SELECT sourceId, externalId
			, amenitiesChecksum = ISNULL(CAST(CHECKSUM_AGG(CHECKSUM(ISNULL(amenityId, 0))) AS BIGINT), 0)
			FROM #tempTab_Property2Amenity p2a
			GROUP BY sourceId, externalId
		) agg
		ON agg.sourceId = p.sourceId
		AND agg.externalId = p.externalId
		WHERE p.propertyId = @propertyId;
	END TRY
	BEGIN CATCH
		SET @errortext = ERROR_MESSAGE();
		GOTO ERROREXIT;
	END CATCH

	--aggregate checksum for the photos
	BEGIN TRY
		UPDATE p
		SET photosChecksum = ISNULL(agg.photosChecksum, 0)
		FROM holidayHomes_build.holidayHomes.tab_property p
		LEFT OUTER JOIN (
			SELECT sourceId, externalId
			, photosChecksum = ISNULL(CAST(CHECKSUM_AGG(ISNULL(position, -1)) AS BIGINT), 0)
								+ ISNULL(CAST(CHECKSUM_AGG(CHECKSUM(ISNULL(url, 'NA'))) AS BIGINT), 0)
			FROM #tempTab_Photo
			GROUP BY sourceId, externalId
		) agg
		ON agg.sourceId = p.sourceId
		AND agg.externalId = p.externalId
		WHERE p.propertyId = @propertyId;
	END TRY
	BEGIN CATCH
		SET @errortext = ERROR_MESSAGE();
		GOTO ERROREXIT;
	END CATCH

	--aggregate checksum for the rates
	BEGIN TRY
		UPDATE p
		SET ratesChecksum = ISNULL(agg.ratesChecksum, 0)
		FROM holidayHomes_build.holidayHomes.tab_property p
		LEFT OUTER JOIN (
			SELECT sourceId, externalId
			, ratesChecksum = ISNULL(CAST(CHECKSUM_AGG(CHECKSUM(ISNULL(periodType, 'NA'))) AS BIGINT), 0)
								+ ISNULL(CAST(CHECKSUM_AGG(CHECKSUM(ISNULL([from], 0))) AS BIGINT), 0)
								+ ISNULL(CAST(CHECKSUM_AGG(CHECKSUM(ISNULL([to], 0))) AS BIGINT), 0)
								+ ISNULL(CAST(CHECKSUM_AGG(CHECKSUM(ISNULL(rateCurrencyCode, 'NA'))) AS BIGINT), 0)
			FROM #tempTab_Rate
			GROUP BY sourceId, externalId
		) agg
		ON agg.sourceId = p.sourceId
		AND agg.externalId = p.externalId
		WHERE p.propertyId = @propertyId;
	END TRY
	BEGIN CATCH
		SET @errortext = ERROR_MESSAGE();
		GOTO ERROREXIT;
	END CATCH

/*
** Update build changeControl tables
** These tables are cleared regularly but provide a trail of what has happened to the data recently
*/

-- property
	BEGIN TRY
		INSERT INTO holidayHomes_build.changeControl.tab_property_change
			(
			  runId
			, [action]
			, sourceId
			, propertyId
			, externalId
			)
		VALUES
			(
			  @runId
			, 'INSERT'
			, @sourceId
			, @propertyId
			, @externalId
			);
	END TRY
	BEGIN CATCH
		SET @errortext = ERROR_MESSAGE();
		GOTO ERROREXIT;
	END CATCH

-- property2amenity
	IF @property2amenityCount > 0
	BEGIN
		BEGIN TRY
			INSERT INTO holidayHomes_build.changeControl.tab_property2amenity_change
				(
				  runId
				, [action]
				, propertyId
				, amenityId
				)
			SELECT
				  runId = @runId
				, [action] = 'INSERT'
				, propertyId = @propertyId
				, amenityId = amenityId
			FROM holidayHomes_build.holidayHomes.tab_property2amenity
			WHERE propertyId = @propertyId;
		END TRY
		BEGIN CATCH
			SET @errortext = ERROR_MESSAGE();
			GOTO ERROREXIT;
		END CATCH
	END

-- photo
	IF @photoCount > 0
	BEGIN
		BEGIN TRY
			INSERT INTO holidayHomes_build.changeControl.tab_photo_change
				(
				  runId
				, [action]
				, propertyId
				, photoId
				)
			SELECT
				  runId = @runId
				, [action] = 'INSERT'
				, propertyId = @propertyId
				, photoId
			FROM holidayHomes_build.holidayHomes.tab_photo
			WHERE propertyId = @propertyId;
		END TRY
		BEGIN CATCH
			SET @errortext = ERROR_MESSAGE();
			GOTO ERROREXIT;
		END CATCH
	END

-- rate
	IF @rateCount > 0
	BEGIN
		BEGIN TRY
			INSERT INTO holidayHomes_build.changeControl.tab_rate_change
				(
				  runId
				, [action]
				, propertyId
				, rateId
				)
			SELECT
				  runId = @runId
				, [action] = 'INSERT'
				, propertyId = @propertyId
				, rateId
			FROM holidayHomes_build.holidayHomes.tab_rate
			WHERE propertyId = @propertyId;
		END TRY
		BEGIN CATCH
			SET @errortext = ERROR_MESSAGE();
			GOTO ERROREXIT;
		END CATCH
	END

/*
** Update production tables
** Inserting new data directly into the production dbo tables
** Not inserting records on production holidayHomes changeControl and changeData tables
** because these are designed to facilitate the SSIS MERGE processing
** and are cleared before every SSIS import run
** 
*/

-- property
	BEGIN TRY
		INSERT INTO holidayHomes.dbo.tab_property
			(
			  propertyId
			, sourceId
			, runId
			, externalId
			, externalURL
			, [description]
			, name
			, regionName
			, typeOfProperty
			, postcode
			, regionId
			, cityId
			, cityName
			, countryCode
			, latitude
			, longitude
			, checkInFrom
			, checkOutBefore
			, sizeOfSpaceInSqm
			, sizeOfSpaceInSqft
			, cancellationPolicy
			, minimumPricePerNight
			, currencyCode
			, numberOfProperBedrooms
			, numberOfBathrooms
			, [floor]
			, reviewsCount
			, averageRating
			, maximumNumberOfPeople
			, numberOfOtherRoomsWhereGuestsCanSleep
			, minimumDaysOfStay
			, dateCreated
			, lastUpdated
			, propertyHashKey
			, amenitiesChecksum
			, photosChecksum
			, ratesChecksum
			, isActive
			, statusUpdated
			)
		SELECT
			  propertyId
			, sourceId
			, runId
			, externalId
			, externalURL
			, [description]
			, name
			, regionName
			, typeOfProperty
			, postcode
			, regionId
			, cityId
			, cityName
			, countryCode
			, latitude
			, longitude
			, checkInFrom
			, checkOutBefore
			, sizeOfSpaceInSqm
			, sizeOfSpaceInSqft
			, cancellationPolicy
			, minimumPricePerNight
			, currencyCode
			, numberOfProperBedrooms
			, numberOfBathrooms
			, [floor]
			, reviewsCount
			, averageRating
			, maximumNumberOfPeople
			, numberOfOtherRoomsWhereGuestsCanSleep
			, minimumDaysOfStay
			, dateCreated
			, lastUpdated
			, propertyHashKey
			, amenitiesChecksum
			, photosChecksum
			, ratesChecksum
			, isActive
			, statusUpdated
		FROM holidayHomes_build.holidayHomes.tab_property
		WHERE propertyId = @propertyId;
	END TRY
	BEGIN CATCH
		SET @errortext = ERROR_MESSAGE();
		GOTO ERROREXIT;
	END CATCH

-- property2amenity
	IF @property2amenityCount > 0
	BEGIN
		BEGIN TRY
			INSERT INTO holidayHomes.dbo.tab_property2amenity
				(
				  propertyId
				, amenityId
				, runId
				)
			SELECT
				  propertyId
				, amenityId
				, runId
			FROM holidayHomes_build.holidayHomes.tab_property2amenity
			WHERE propertyId = @propertyId;
		END TRY
		BEGIN CATCH
			SET @errortext = ERROR_MESSAGE();
			GOTO ERROREXIT;
		END CATCH
	END

-- photo
	IF @photoCount > 0
	BEGIN
		BEGIN TRY
			INSERT INTO holidayHomes.dbo.tab_photo
				(
				  photoId
				, propertyId
				, position
				, url
				, runId
				)
			SELECT
				  photoId
				, propertyId
				, position
				, url
				, runId
			FROM holidayHomes_build.holidayHomes.tab_photo
			WHERE propertyId = @propertyId;
		END TRY
		BEGIN CATCH
			SET @errortext = ERROR_MESSAGE();
			GOTO ERROREXIT;
		END CATCH
	END

-- rate
	IF @rateCount > 0
	BEGIN
		BEGIN TRY
			INSERT INTO holidayHomes.dbo.tab_rate
				(
				  rateId
				, propertyId
				, periodType
				, [from]
				, [to]
				, currencyCode
				, runId
				)
			SELECT
				  rateId
				, propertyId
				, periodType
				, [from]
				, [to]
				, currencyCode
				, runId
			FROM holidayHomes_build.holidayHomes.tab_rate
			WHERE propertyId = @propertyId;
		END TRY
		BEGIN CATCH
			SET @errortext = ERROR_MESSAGE();
			GOTO ERROREXIT;
		END CATCH
	END

/*
** Housekeeping
*/

	IF OBJECT_ID('tempdb..#tempTab_Property') IS NOT NULL
	BEGIN
		DROP TABLE #tempTab_Property;
	END

	IF OBJECT_ID('tempdb..#tempTab_Property2Amenity') IS NOT NULL
	BEGIN
		DROP TABLE #tempTab_Property2Amenity;
	END

	IF OBJECT_ID('tempdb..#tempTab_Photo') IS NOT NULL
	BEGIN
		DROP TABLE #tempTab_Photo;
	END

	IF OBJECT_ID('tempdb..#tempTab_Rate') IS NOT NULL
	BEGIN
		DROP TABLE #tempTab_Rate;
	END

/*
** Exit
*/

normalexit:
	IF @@TRANCOUNT > 0
	BEGIN
		COMMIT TRANSACTION createNewProperty;
	END

	INSERT holidayHomes_build.import.tab_runLog
		(
		  runId
		, messageType
		, messageContent
		)
		VALUES
		(
		  @runId
		, 'info'
		, 'Run Finished'
		);

	RETURN @propertyId;

errorexit:
	IF @@TRANCOUNT > 0
	BEGIN
		ROLLBACK TRANSACTION createNewProperty;
	END

	INSERT holidayHomes_build.import.tab_runLog
		(
		  runId
		, messageType
		, messageContent
		)
		VALUES
		(
		  @runId
		, 'info'
		, 'Run Finished with error ' + @errortext
		);

	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END

GO