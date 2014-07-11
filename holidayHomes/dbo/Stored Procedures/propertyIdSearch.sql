-- =============================================
-- Author:	Tim Wilson
-- Create date: 06/06/2014
-- Description:	Return property data result set for a passed list of property externalIds
--
-- History
--	2014-06-06 TW New
--  2014-06-11 JP added currency conversion logic
--	2014-07-11 JP added parameter numberOfBedrooms
--	2014-07-11 JP added parameter maxSleeps
--	2014-07-11 JP added parameter sleeps
--	2014-07-11 JP added parameter typeOfProperty
--  2014-07-11 TW revised parameter @sourceId to @sourceIds
--                and enabled a comma delimited list of partner ids to be passed
-- =============================================

CREATE PROCEDURE [dbo].[propertyIdSearch]
  @externalIds VARCHAR(MAX)
, @sourceIds VARCHAR(200) = NULL
, @localCurrencyCode NVARCHAR(3) = 'GBP'
, @numberOfBedrooms INT = NULL
, @sleeps INT = 1
, @maxSleeps INT = NULL
, @typeOfProperty VARCHAR(15) = NULL

AS

BEGIN

	SET NOCOUNT ON;

	DECLARE @localRate FLOAT
		, @sourceId INT
		, @sourceIdCount INT;

	IF @sourceIds IS NULL OR @sourceIds = ''
	BEGIN
	SET @sourceIds = '';
	END 
 
	SET @sourceIdCount = LEN(@sourceIds) - LEN(REPLACE(@sourceIds, ',', ''));
	IF LEN(@sourceIds) > 0
	BEGIN
	SET @sourceIdCount = @sourceIdCount + 1;
	END

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
		, ISNULL(p.thumbnailUrl, pho.url) AS thumbnailUrl
		, p.externalURL
		, p.[description]
		, p.[name]
		, p.regionName
		, p.typeOfProperty
		, p.postcode
		, p.regionId
		, p.cityId
		, p.cityName
		, p.stateName
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
	FROM dbo.tab_property p
	INNER JOIN dbo.SplitString(@externalIds, ',') AS split
	ON split.Item = p.externalId
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
	    ( @numberOfBedrooms IS NULL OR numberOfProperBedrooms = @numberOfBedrooms )
	AND ( @sleeps IS NULL OR maximumNumberOfPeople >= @sleeps )
	AND ( @maxSleeps IS NULL OR maximumNumberOfPeople <= @maxSleeps )
	AND ( @typeOfProperty IS NULL OR typeOfProperty = @typeOfProperty )
	AND
		(
		@sourceIdCount = 0
		OR
		sourceId IN
			(
			SELECT split.Item FROM dbo.SplitString(@sourceIds, ',') AS split
			)
		)
	;
END

GO