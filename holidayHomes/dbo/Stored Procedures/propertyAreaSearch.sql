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
--  2014-03-13 TW added parameter countryCode
--  2014-03-27 TW added parameters for latitude / longitude / radius / imperial units
--  2014-03-28 TW renamed as propertyAreaSearch to preserve the original propertySearch
--  2014-04-02 TW include properties without latitude and longitude in geographic search results
--  2014-04-03 TW revision of 02/02/2014 was not quite right
--  2014-04-04 TW price order now uses prices converted to GBP (using new table utils_currencyLookup)
--                added parameter localCurrencyCode
--  2014-04-08 JP added parameter maxSleeps
-- =============================================
CREATE PROCEDURE [dbo].[propertyAreaSearch]
-- Add the parameters for the stored procedure here
  @searchCriteria VARCHAR(150)
, @typeOfProperty VARCHAR(15) = NULL
, @countryCode VARCHAR(2) = NULL
, @localCurrencyCode nvarchar(3) = 'GBP'
, @sleeps int = 1
, @maxSleeps int = NULL
, @numberOfBedrooms int = NULL
, @sourceIds varchar(MAX) = NULL
, @centralLatitude float
, @centralLongitude float
, @swLatitude float = 0
, @swLongitude float = 0
, @neLatitude float = 0
, @neLongitude float = 0
, @radius decimal(18,2)
, @imperial bit = 0
, @Page int
, @RecsPerPage int
, @orderBy VARCHAR(15) = 'distance'
, @orderDESC BIT = 0
AS
BEGIN
 -- SET NOCOUNT ON added to prevent extra result sets from
 -- interfering with SELECT statements.
 SET NOCOUNT ON;

 DECLARE @sourceId int
	, @conversion decimal(10,4);

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
	IF @centralLatitude IS NOT NULL
	BEGIN
		SET @orderBy = 'distance'
	END
 ELSE
	BEGIN
		SET @orderBy = 'beds'
	END
 END

 IF @imperial = 1
 BEGIN
	SET @conversion = 1609.344;
 END
 ELSE
 BEGIN
	SET @conversion = 1000.000;
 END

 IF @localCurrencyCode = '' OR @localCurrencyCode IS NULL
 BEGIN
	SET @localCurrencyCode = 'GBP'
 END

 -- all the slow stuff on the outside working on the smallest possible dataset
 SELECT
  totalCount = COUNT(1) OVER ()
  , rowNum = ROW_NUMBER() OVER
   (ORDER BY CASE
    WHEN @orderBy = 'distance'
		AND
		(latitude IS NULL OR longitude IS NULL) 
		THEN POWER(-1, @orderDESC) * 999
    WHEN @orderBy = 'distance'
		AND
		(latitude IS NOT NULL AND longitude IS NOT NULL)
		THEN POWER(-1, @orderDESC) * (geodata.STDistance(geography::STGeomFromText('POINT(' + CONVERT(varchar(100), @centralLongitude) + ' ' + CONVERT(varchar(100), @centralLatitude) + ')', 4326)) / @conversion)
    WHEN @orderBy = 'beds'     THEN POWER(-1, @orderDESC) * maximumNumberOfPeople 
    WHEN @orderBy = 'rating'   THEN POWER(-1, @orderDESC) * ISNULL(averageRating, 0.1)
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
  , name
  , [description]
  , latitude
  , longitude
  , propertyId
  , externalURL
  , numberOfProperBedrooms
  , maximumNumberOfPeople
  , averageRating
  , url
  , countryCode
  , cityName
  , sourceId
  , externalId
  , regionName
  , minimumPricePerNight
  , currencyCode
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
  , (geodata.STDistance(geography::STGeomFromText('POINT(' + CONVERT(varchar(100), @centralLongitude) + ' ' + CONVERT(varchar(100), @centralLatitude) + ')', 4326)) / @conversion) AS distance
  , [partner]
  , internalURL
  , urlSafeName
  , logoURL
 FROM
	 (
	 -- here is the main select
	 SELECT
	  pro.name
	  , pro.[description]
	  , pro.latitude
	  , pro.longitude
	  , pro.propertyId
	  , pro.externalURL
	  , pro.numberOfProperBedrooms
	  , pro.maximumNumberOfPeople
	  , pro.averageRating
	  , ISNULL(pro.thumbnailUrl, pho.url) AS url
	  , pro.countryCode
	  , pro.cityName
	  , pro.sourceId
	  , pro.externalId
	  , pro.regionName
	  , pro.minimumPricePerNight
	  , pro.currencyCode
	  , latlong.geodata
	  , '' AS [partner]
	  , '' AS internalURL
	  , '' AS urlSafeName
	  , '' AS logoURL
	 FROM dbo.tab_property pro
	 INNER JOIN dbo.tab_propertyLatLong latlong
	 ON pro.propertyId = latlong.propertyId
	 OUTER APPLY (
	  SELECT  TOP 1 tab_photo.url
	  FROM    tab_photo
	  WHERE   tab_photo.propertyId = pro.propertyId
	 ) pho
	 WHERE
	  ( @typeOfProperty IS NULL OR pro.typeOfProperty = @typeOfProperty )
	  AND ( pro.maximumNumberOfPeople >= ISNULL(@sleeps, 1) )
	  AND ( @maxSleeps IS NULL OR pro.maximumNumberOfPeople <= @maxSleeps )
	  AND ( @numberOfBedrooms IS NULL OR numberOfProperBedrooms = @numberOfBedrooms )
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
	  AND
		(
			(
			-- Condition for including records with NULL latitude / longitude
			(pro.latitude IS NULL OR pro.longitude IS NULL)
			AND
			(
			-- searchCriteria is required
			((pro.cityName LIKE @searchCriteria OR pro.regionName LIKE @searchCriteria ) AND (pro.latitude IS NULL AND pro.longitude IS NULL))
			AND
			-- countryCode is optional
			(@countryCode IS NULL OR (pro.countryCode = @countryCode AND (pro.latitude IS NULL AND pro.longitude IS NULL)))
			)
			)
		OR
			(
			-- Radius not passed: restrict to bounding box of min / max latitude and longitude
			(pro.latitude IS NOT NULL AND pro.longitude IS NOT NULL)
			AND
			(@radius IS NULL OR @radius = 0)
			AND
			@swLatitude <= pro.Latitude
			AND
			@neLatitude >= pro.Latitude
			AND
			@swLongitude <= pro.Longitude
			AND
			@neLongitude >= pro.Longitude
			)
		OR
			(
			-- Radius passed: restrict to radial distance from central latitude and longitude
			(pro.latitude IS NOT NULL AND pro.longitude IS NOT NULL)
			AND
			@radius >= (latlong.geodata.STDistance(geography::STGeomFromText('POINT(' + CONVERT(varchar(100), @centralLongitude) + ' ' + CONVERT(varchar(100), @centralLatitude) + ')', 4326)) / @conversion)
			)
		)
	 ) mainselect
 LEFT OUTER JOIN dbo.utils_currencyLookup currency
 ON currency.id = currencyCode AND currency.localId = @localCurrencyCode
 ORDER BY rowNum
 OFFSET (@RecsPerPage * (@Page - 1)) ROWS
 FETCH NEXT @RecsPerPage ROWS ONLY;

END
GO