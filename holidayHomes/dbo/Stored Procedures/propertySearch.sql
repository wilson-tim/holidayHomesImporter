-- =============================================
-- Author:	James Privett
-- Create date: 09/12/2013
-- Description:	Search for a property
--
-- History
--	2014-01-08 MC added nullable params, dynamic order by (needs more), totalCount, OFFSET and FETCH pagination
--  2014-01-08 JP added pro.sourceId, pro.externalId to select statement
--  2014-01-10 JP added pro.minimumPricePerNight to select statement
--  2014-02-20 TW added parameter sourceIds (null or single sourceId or comma delimited list of sourceIds)
--                requires the utils_numbers table
--  2014-03-07 TW added parameter numberOfBedrooms
--  2014-03-13 JP added parameter countryCode
--  2014-04-04 TW price order now uses prices converted to GBP (using new table utils_currencyLookup)
--                added parameter localCurrencyCode
--  2014-04-08 JP added parameter maxSleeps
--  2014-04-14 TW added parameters minPrice, maxPrice (both in GBP)
--  2014-04-15 TW added faceted search criteria parameters @amenityFacets, @specReqFacets, @propertyTypeFacets
--                (each passed as comma delimited lists, e.g. '1,7,10')
-- =============================================
CREATE PROCEDURE [dbo].[propertySearch]
-- Add the parameters for the stored procedure here
  @searchCriteria VARCHAR(150) = NULL
, @typeOfProperty VARCHAR(15) = NULL
, @countryCode VARCHAR(2) = NULL
, @localCurrencyCode nvarchar(3) = 'GBP'
, @sleeps int = 1
, @maxSleeps int = NULL
, @numberOfBedrooms int = NULL
, @sourceIds varchar(MAX) = NULL
, @minPrice int = 1
, @maxPrice int = 10000
, @Page int
, @RecsPerPage int
, @orderBy VARCHAR(15) = 'beds'
, @orderDESC BIT = 0
AS
BEGIN
 -- SET NOCOUNT ON added to prevent extra result sets from
 -- interfering with SELECT statements.
 SET NOCOUNT ON;

 DECLARE @sourceId int
	, @localRate float;

 IF @sourceIds IS NOT NULL AND CHARINDEX(',', @sourceIds, 0) = 0
 BEGIN
  SET @sourceId = CAST(@sourceIds AS int);
 END

 IF @sourceIds IS NOT NULL AND CHARINDEX(',', @sourceIds, 0) > 0
 BEGIN
  SET @sourceId = 0;
 END

IF @sourceIds IS NULL
 BEGIN
  SET @sourceId = NULL;
 END
 
 IF @orderBy = '' OR @orderBy IS NULL
 BEGIN
	SET @orderBy = 'beds'
 END

 IF @localCurrencyCode = '' OR @localCurrencyCode IS NULL
 BEGIN
	SET @localCurrencyCode = 'GBP'
 END

 SET @sleeps = ISNULL(@sleeps, 1);
 
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

 -- here is the main select
 SELECT totalCount = COUNT(1) OVER ()
  , rowNum = ROW_NUMBER() OVER
   (ORDER BY CASE
    WHEN @orderBy = 'beds' THEN POWER(-1, @orderDESC) * pro.maximumNumberOfPeople 
    WHEN @orderBy = 'rating' THEN POWER(-1, @orderDESC)* ISNULL(pro.averageRating, 0.1)
    WHEN @orderBy = 'price'
		AND
		(
		minimumPricePerNight IS NULL
		OR
		ABS(minimumPricePerNight) = 0
		OR
		currencyCode IS NULL
		OR
		currency.rate IS NULL
		OR
		currency.rate = 0
		)
		THEN POWER(-1, @orderDESC) * 999999
    WHEN @orderBy = 'price'
		AND
		(
		minimumPricePerNight IS NOT NULL
		AND
		ABS(minimumPricePerNight) > 0
		AND
		currencyCode IS NOT NULL
		AND
		currency.rate IS NOT NULL
		AND
		currency.rate > 0
		)
		THEN POWER(-1, @orderDESC) * (minimumPricePerNight / currency.rate)
    ELSE -propertyId
   END) -- end of ORDER BY CASE
  , pro.name
  , pro.[description]
  , pro.latitude
  , pro.longitude
  , pro.propertyId
  , pro.externalURL
  , pro.numberOfProperBedrooms
  , pro.maximumNumberOfPeople
  , pro.averageRating
  , pho.url
  , pro.countryCode
  , pro.cityName
  , pro.sourceId
  , pro.externalId
  , pro.regionName
  , pro.minimumPricePerNight
  , pro.currencyCode
  , minimumPricePerNightLocal =
    CASE
		WHEN
			(
			minimumPricePerNight IS NULL
			OR
			ABS(minimumPricePerNight) = 0
			OR
			currencyCode IS NULL
			OR
			currency.rate IS NULL
			OR
			currency.rate = 0
			)
			THEN 0
		ELSE
			(minimumPricePerNight / currency.rate)
    END
  , '' AS [partner]
  , '' AS internalURL
  , '' AS urlSafeName
  , '' AS logoURL
 FROM tab_property pro
 CROSS APPLY (
  SELECT  TOP 1 tab_photo.url
  FROM    tab_photo
  WHERE   tab_photo.propertyId = pro.propertyId
 ) pho
 LEFT OUTER JOIN dbo.utils_currencyLookup currency
 ON currency.id = currencyCode AND currency.localId = @localCurrencyCode
 WHERE
  ( @searchCriteria IS NULL OR pro.cityName LIKE @searchCriteria OR pro.regionName LIKE @searchCriteria )
  AND ( @countryCode IS NULL OR pro.countryCode = @countryCode )
  AND ( @typeOfProperty IS NULL OR pro.typeOfProperty = @typeOfProperty )
  AND ( pro.maximumNumberOfPeople >= @sleeps )
  AND ( @maxSleeps IS NULL OR pro.maximumNumberOfPeople <= @maxSleeps )
  AND ( @numberOfBedrooms IS NULL OR numberOfProperBedrooms = @numberOfBedrooms )
  AND (
		(
		@minPrice IS NULL
		OR
		@maxPrice IS NULL
		OR
		minimumPricePerNight IS NULL
		OR
		ABS(minimumPricePerNight) = 0
		OR
		currencyCode IS NULL
		OR
		currency.rate IS NULL
		OR
		currency.rate = 0
		)
		OR
		(
		(@minPrice / @localRate) <= (minimumPricePerNight / currency.rate)
		AND
		(@maxPrice / @localRate) >= (minimumPricePerNight / currency.rate)
		)
	)
  AND
   (
   @sourceId IS NULL
   OR
   sourceId = @sourceId
   OR
   sourceId IN
		/*
		* There is no SELECT ... WHERE ... IN (@variable) construct in T-SQL
		* so need to convert @sourceIds into a result set which T-SQL can use.
		* Requires the utils_numbers table
		*/
		/*
		(
		SELECT CAST( SUBSTRING(',' + @sourceIds + ',', number + 1
		 , CHARINDEX(',', ',' + @sourceIds + ',', number + 1) - number -1) AS int )
		FROM utils_numbers
		WHERE ( number <= LEN(',' + @sourceIds + ',') - 1 )
		 AND ( SUBSTRING(',' + @sourceIds + ',', number, 1) = ',' )
		)
		*/
		(
		SELECT split.Item FROM dbo.SplitString(@sourceIds, ',') AS split
		)
   )
 ORDER BY rowNum
 OFFSET (@RecsPerPage * (@Page - 1)) ROWS
 FETCH NEXT @RecsPerPage ROWS ONLY;

END
GO
