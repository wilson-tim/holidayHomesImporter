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
, @sourceId int = NULL
, @localCurrencyCode nvarchar(3) = 'GBP'

AS

BEGIN

	SET NOCOUNT ON;

	DECLARE
		  @localRate float
		, @searchString varchar(8000)
		, @searchStringSoundex varchar(8000);

	SELECT @searchString = CONVERT(varchar(8000), COALESCE(item, '') + ' ')
	FROM
		(
		SELECT 'FORMSOF(INFLECTIONAL, ' + split.Item + ') AND '
		FROM dbo.SplitString(@keywords, ' ') AS split
		FOR XML PATH('')
		) searchStringSelect (item)
	;
	SET @searchString = LEFT(@searchString, LEN(@searchString) - 4);

	SELECT @searchStringSoundex = CONVERT(varchar(8000), COALESCE(item, '') + ' ')
	FROM
		(
		SELECT SOUNDEX(split.Item) + ' AND '
		FROM dbo.SplitString(@keywords, ' ') AS split
		WHERE LEN(split.Item) > 2
			AND SOUNDEX(split.Item) <> '0000'
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
	FROM
	(
		SELECT
			  pk.propertyId
			, pk.keywords
			, pk.keywordsSoundex
			, ct.[RANK]
		FROM dbo.tab_propertyKeywords pk
		INNER JOIN CONTAINSTABLE(
			  dbo.tab_propertyKeywords
			, keywords
			, @searchString
			) ct
		ON ct.[KEY] = pk.propertyId

		UNION

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

	ORDER BY [RANK] DESC, p.name
	;

END

GO