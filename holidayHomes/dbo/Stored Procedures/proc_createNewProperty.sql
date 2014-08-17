/*****************************************************************************
** dbo.proc_createNewProperty
** stored procedure
**
** Description
** Create a new property record and associated amenity, photo and rate records
**
** Parameters
** @xmlString = xml document containing data for new property record and child records (required)
**
** Returned
** Return value 0 (success), otherwise -1 (failure)
**
** History
** 16/08/2014  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.proc_createNewProperty', N'P') IS NOT NULL
    DROP PROCEDURE dbo.proc_createNewProperty;
GO
CREATE PROCEDURE dbo.proc_createNewProperty
	  @xmlString VARCHAR(MAX)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE
		  @xmlDoc XML
		, @errortext VARCHAR(500)
		, @sourceId INT
		, @runId INT
		, @propertyId BIGINT
		, @externalId NVARCHAR(100)

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

	-- Assign @xmlString for testing
	SET @xmlString = '<?xml version="1.0" encoding="utf-8"?><properties><property><externalId>123456</externalId><externalURL>https://affiliate.partner.com/en/properties/123456</externalURL><thumbnailURL/><name>Stockholm city apartment</name><description>Situated in Stockholm city centre, this 2 bedroom apartment accommodates up to 5 guests and starts at just EUR 200 per night.  	 	The apartment is a spacious 130 sqm located on the 7th floor with views over the city, conveniently accessible via an elevator. 	34 guests have stayed in this property. Guests have rated this property 7.94 out of 10 based on 17 reviews. 	The owner will contact you to arrange key collection following your booking.</description><regionName>Stockholm</regionName><typeOfProperty>apartment</typeOfProperty><postcode>12345</postcode><regionId>123456</regionId><cityId>123456</cityId><cityName>Stockholm</cityName><stateName/><countryCode>SE</countryCode><latitude>59.3496411000</latitude><longitude>18.0563422000</longitude><checkInFrom>16:00:00</checkInFrom><checkOutBefore>10:00:00</checkOutBefore><sizeOfSpaceInSqm>130</sizeOfSpaceInSqm><sizeOfSpaceInSqft>1400</sizeOfSpaceInSqft><cancellationPolicy>relaxed</cancellationPolicy><minimumPricePerNight>200</minimumPricePerNight><propertyCurrencyCode>EUR</propertyCurrencyCode><numberOfProperBedrooms>2</numberOfProperBedrooms><numberOfBathrooms>1</numberOfBathrooms><floor>7</floor><reviewsCount>17</reviewsCount><averageRating>7.94</averageRating><maximumNumberOfPeople>5</maximumNumberOfPeople><numberOfOtherRoomsWhereGuestsCanSleep>1</numberOfOtherRoomsWhereGuestsCanSleep><minimumDaysOfStay>5</minimumDaysOfStay><amenities><amenity><amenityValue>children_friendly</amenityValue></amenity><amenity><amenityValue>coffee_maker</amenityValue></amenity><amenity><amenityValue>cooking_utensils</amenityValue></amenity><amenity><amenityValue>cribs_available</amenityValue></amenity><amenity><amenityValue>cutlery</amenityValue></amenity><amenity><amenityValue>dish_washer</amenityValue></amenity><amenity><amenityValue>dryer</amenityValue></amenity><amenity><amenityValue>elevator</amenityValue></amenity><amenity><amenityValue>entire_property</amenityValue></amenity><amenity><amenityValue>freezer</amenityValue></amenity><amenity><amenityValue>fridge</amenityValue></amenity><amenity><amenityValue>glasses</amenityValue></amenity><amenity><amenityValue>guests_can_wash_clothes</amenityValue></amenity><amenity><amenityValue>heating</amenityValue></amenity><amenity><amenityValue>internet_wifi</amenityValue></amenity><amenity><amenityValue>kitchen</amenityValue></amenity><amenity><amenityValue>linens</amenityValue></amenity><amenity><amenityValue>microwave</amenityValue></amenity><amenity><amenityValue>non_smoking_only</amenityValue></amenity><amenity><amenityValue>oven</amenityValue></amenity><amenity><amenityValue>pets_not_allowed</amenityValue></amenity><amenity><amenityValue>plates</amenityValue></amenity><amenity><amenityValue>radio</amenityValue></amenity><amenity><amenityValue>shower</amenityValue></amenity><amenity><amenityValue>terrace</amenityValue></amenity><amenity><amenityValue>toaster</amenityValue></amenity><amenity><amenityValue>towels</amenityValue></amenity><amenity><amenityValue>tv</amenityValue></amenity></amenities><photos><photo><position>1</position><url>http://affiliate.partner.com/photos/images/495737/original.jpg?173474</url></photo><photo><position>2</position><url>http://affiliate.partner.com/photos/images/493758/original.JPG?958475</url></photo><photo><position>3</position><url>http://affiliate.partner.com/photos/images/189928/original.jpg?394856</url></photo></photos><rates><rate><periodType>nightly</periodType><from>200.0000000000</from><rateCurrencyCode>EUR</rateCurrencyCode></rate></rates></property></properties>'
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
	-- 10 = Compare and Share Limited
	SET @sourceId = 10;

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

/*
** Read in property data
*/

	IF OBJECT_ID('tempdb..#tempTab_Property') IS NOT NULL
	BEGIN
		DROP TABLE #tempTab_Property;
	END

	BEGIN TRY
		SELECT 
 			  xmldoc.xmlRecord.value('externalURL[1]','NVARCHAR(2000)') AS 'externalURL'
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
			, NULL AS externalId
			, NULL AS propertyHashKey
			, NULL AS amenitiesChecksum
			, NULL AS photosChecksum
			, NULL AS ratesChecksum
		INTO #tempTab_Property
		FROM @xmlDoc.nodes('/properties/property') AS xmldoc(xmlRecord);
	END TRY
	BEGIN CATCH
		SET @errortext = ERROR_MESSAGE();
		GOTO ERROREXIT;
	END CATCH

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
	INSERT INTO holidayHomes_build.holidayHomes.tab_property
		(
		  sourceId
		, runId
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

	SET @externalId = LTRIM(RTRIM(STR(@propertyId)));

-- property2amenity
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
	INNER JOIN holidayHomes_build.holidayHomes.dbo.tab_amenity ah
	ON ah.amenityValue = at.amenityValue;

-- photo
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

-- rate
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

-- property final pass
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

	--aggregate checksum for the amenities
	UPDATE p
	SET amenitiesChecksum = ISNULL(agg.amenitiesChecksum, 0)
	FROM #tempTab_Property p
	LEFT OUTER JOIN (
		SELECT sourceId, externalId
		, amenitiesChecksum = ISNULL(CAST(CHECKSUM_AGG(CHECKSUM(ISNULL(amenityId, 0))) AS BIGINT), 0)
		FROM #tempTab_Property2Amenity p2a
		GROUP BY sourceId, externalId
	) agg
	ON agg.sourceId = p.sourceId
	AND agg.externalId = p.externalId;

	--aggregate checksum for the photos
	UPDATE p
	SET photosChecksum = ISNULL(agg.photosChecksum, 0)
	FROM #tempTab_Property p
	LEFT OUTER JOIN (
		SELECT sourceId, externalId
		, photosChecksum = ISNULL(CAST(CHECKSUM_AGG(ISNULL(position, -1)) AS BIGINT), 0)
							+ ISNULL(CAST(CHECKSUM_AGG(CHECKSUM(ISNULL(url, 'NA'))) AS BIGINT), 0)
		FROM #tempTab_Photo
		GROUP BY sourceId, externalId
	) agg
	ON agg.sourceId = p.sourceId
	AND agg.externalId = p.externalId;

	--aggregate checksum for the rates
	UPDATE p
	SET ratesChecksum = ISNULL(agg.ratesChecksum, 0)
	FROM #tempTab_Property p
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
	AND agg.externalId = p.externalId;

/*
** Update build changeControl tables
** These tables are cleared regularly but provide a trail of what has happened to the data recently
*/

-- property
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

-- property2amenity
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
	WHERE runId = @runId;

-- photo
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
	WHERE runId = @runId;

-- rate
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
	WHERE runId = @runId;

/*
** Update live tables
*/

-- property

-- property2amenity

-- photo

-- rate

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

normalexit:
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

	RETURN 0;

errorexit:

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