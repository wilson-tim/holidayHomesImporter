-- =============================================
-- Author:	Tim Wilson
-- Create date: 12/06/2014
-- Description:	search for a property using keywords
--
-- History
--	2014-06-12 TW New
-- =============================================

CREATE PROCEDURE [dbo].[propertyKeywordSearch]
  @keywords VARCHAR(8000) = NULL
, @sourceId INT = NULL
, @localCurrencyCode NVARCHAR(3) = 'GBP'
, @numberOfRecords INT = 1000

AS

BEGIN

	SET NOCOUNT ON;

	DECLARE
		  @localRate FLOAT
		, @searchString VARCHAR(8000)
		, @searchStringSoundex VARCHAR(8000);

	SELECT @searchString = CONVERT(VARCHAR(8000), COALESCE(item, '') + ' ')
	FROM
		(
		SELECT 'FORMSOF(INFLECTIONAL, ' + split.Item + ') AND '
		FROM dbo.SplitString(@keywords, ' ') AS split
		WHERE 2 < LEN(split.Item)
		FOR XML PATH('')
		) searchStringSelect (item)
	;
	SET @searchString = LEFT(@searchString, LEN(@searchString) - 4);

	SELECT @searchStringSoundex = CONVERT(VARCHAR(8000), COALESCE(item, '') + ' ')
	FROM
		(
		SELECT SOUNDEX(split.Item) + ' AND '
		FROM dbo.SplitString(@keywords, ' ') AS split
		WHERE 2 < LEN(split.Item)
			AND '0000' <> SOUNDEX(split.Item)
		FOR XML PATH('')
		) searchStringSoundexSelect (item)
	;
	SET @searchStringSoundex = LEFT(@searchStringSoundex, LEN(@searchStringSoundex) - 4);

	IF @localCurrencyCode = '' OR @localCurrencyCode IS NULL
	BEGIN
		SET @localCurrencyCode = 'GBP';
	END

	IF @localCurrencyCode IS NOT NULL AND @localCurrencyCode <> ''
	BEGIN
		SELECT @localRate = rate
		FROM dbo.utils_currencyLookup
		WHERE id = 'GBP'
			AND localId = @localCurrencyCode;
	END
	ELSE
	BEGIN
		SET @localRate = 1;
	END

	IF @numberOfRecords = 0 OR @numberOfRecords IS NULL
	BEGIN
		SET @numberOfRecords = 1000;
	END

	SELECT
		TOP (@numberOfRecords)
		  propertyId
		, sourceId
		, runId
		, externalId
		, name
		, typeOfProperty
		, [description]
		, externalURL
		, thumbnailUrl
		, regionName
		, cityName
		, stateName
		, postcode
		, cityId
		, regionId
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
		, minimumPricePerNightLocal
		, keywords
		, keywordsSoundex
		, [RANK]
	FROM
	(
		SELECT
			  p.propertyId
			, p.sourceId
			, p.runId
			, p.externalId
			, p.name
			, p.typeOfProperty
			, p.[description]
			, p.externalURL
			, ISNULL(p.thumbnailUrl, pho.url) AS thumbnailUrl
			, p.regionName
			, p.cityName
			, p.stateName
			, p.postcode
			, p.cityId
			, p.regionId
			, p.countryCode
			, p.latitude
			, p.longitude
			, p.checkInFrom
			, p.checkOutBefore
			, p.sizeOfSpaceInSqm
			, p.sizeOfSpaceInSqft
			, p.cancellationPolicy
			, p.minimumPricePerNight
			, p.currencyCode
			, p.numberOfProperBedrooms
			, p.numberOfBathrooms
			, p.[floor]
			, p.reviewsCount
			, p.averageRating
			, p.maximumNumberOfPeople
			, p.numberOfOtherRoomsWhereGuestsCanSleep
			, p.minimumDaysOfStay
			, p.dateCreated
			, p.lastUpdated
			, p.propertyHashKey
			, p.amenitiesChecksum
			, p.photosChecksum
			, p.ratesChecksum
			, minimumPricePerNightLocal =
				CASE
					WHEN
						(
						p.minimumPricePerNight IS NULL
						OR
						ABS(p.minimumPricePerNight) = 0
						OR
						p.currencyCode IS NULL
						OR
						currency.rate IS NULL
						OR
						currency.rate = 0
						)
						THEN 0
					ELSE
						(p.minimumPricePerNight / currency.rate)
				END
			, keywords
			, keywordsSoundex
			, [RANK]
			, rownum = ROW_NUMBER() OVER (PARTITION BY p.propertyId ORDER BY [RANK] DESC, p.name ASC)
		FROM
		(
			SELECT
				  pk.propertyId
				, pk.keywords
				, pk.keywordsSoundex
				, ct.[RANK] * 1000
			FROM dbo.tab_propertyKeywords pk
			INNER JOIN CONTAINSTABLE(
				  dbo.tab_propertyKeywords
				, keywords
				, @searchString
				) ct
			ON ct.[KEY] = pk.propertyId

			UNION ALL

			SELECT
				  pk.propertyId
				, pk.keywords
				, pk.keywordsSoundex
				, ct.[RANK]
			FROM dbo.tab_propertyKeywords pk
			INNER JOIN CONTAINSTABLE(
				  dbo.tab_propertyKeywords
				, keywordsSoundex
				, @searchStringSoundex
				) ct
			ON ct.[KEY] = pk.propertyId
		) resultsList (propertyId, keywords, keywordsSoundex, [RANK])

		INNER JOIN dbo.tab_property p
		ON p.propertyId = resultsList.propertyId

		OUTER APPLY
		(
			SELECT TOP 1 dbo.tab_photo.url
			FROM dbo.tab_photo
			WHERE dbo.tab_photo.propertyId = p.propertyId
			ORDER BY dbo.tab_photo.position
		) pho

		LEFT OUTER JOIN dbo.utils_currencyLookup currency
		ON currency.id = p.currencyCode
			AND currency.localId = @localCurrencyCode

		WHERE
			(
			(p.sourceId = @sourceId AND @sourceId IS NOT NULL AND @sourceId <> '')
			OR
			(@sourceId IS NULL OR @sourceId = '')
			)

	) rownumSelect

	WHERE rownum = 1

	ORDER BY [RANK] DESC, propertyId ASC
	;

END

GO