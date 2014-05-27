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
--  2014-04-11 TW optimised: new variable @centralLatLongGeo
--  2014-04-14 TW added parameters minPrice, maxPrice (both in GBP)
--  2014-04-15 TW added faceted search criteria parameters @amenityFacets, @specReqFacets, @propertyTypeFacets
--                (each passed as comma delimited lists, e.g. '1,7,10')
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
, @sourceIds varchar(200) = NULL
, @minPrice int = 1
, @maxPrice int = 10000
, @centralLatitude float
, @centralLongitude float
, @swLatitude float = 0
, @swLongitude float = 0
, @neLatitude float = 0
, @neLongitude float = 0
, @radius decimal(18,2)
, @imperial bit = 0
, @amenityFacets varchar(200) = NULL
, @specReqFacets varchar(200) = NULL
, @propertyTypeFacets varchar(200) = NULL
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
	, @conversion decimal(10,4)
	, @centralLatLongGeo geography
	, @localRate float
	, @amenityFacetCount int
	, @specReqFacetCount int
	, @propertyTypeFacetCount int
	, @totalFacetCount int
	, @sourceIdCount int;

 IF @sourceIds IS NULL OR @sourceIds = ''
 BEGIN
	SET @sourceIds = '';
 END 
 
 SET @sourceIdCount = LEN(@sourceIds) - LEN(REPLACE(@sourceIds, ',', ''));
 IF LEN(@sourceIds) > 0
 BEGIN
	SET @sourceIdCount = @sourceIdCount + 1;
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

 IF @centralLatitude IS NOT NULL AND @centralLongitude IS NOT NULL
 BEGIN
	SET @centralLatLongGeo = geography::STGeomFromText('POINT(' + CONVERT(varchar(100), @centralLongitude) + ' ' + CONVERT(varchar(100), @centralLatitude) + ')', 4326);
 END

 SET @sleeps = ISNULL(@sleeps, 1);

 IF @radius IS NULL
 BEGIN
	SET @radius = 0;
 END

 IF @localCurrencyCode = '' OR @localCurrencyCode IS NULL
 BEGIN
	SET @localCurrencyCode = 'GBP'
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

 IF @amenityFacets IS NULL OR @amenityFacets = ''
 BEGIN
	SET @amenityFacets = '';
 END 
 
 SET @amenityFacetCount = LEN(@amenityFacets) - LEN(REPLACE(@amenityFacets, ',', ''));
 IF LEN(@amenityFacets) > 0
 BEGIN
	SET @amenityFacetCount = @amenityFacetCount + 1;
 END

 IF @specReqFacets IS NULL OR @specReqFacets = ''
 BEGIN
	SET @specReqFacets = '';
 END 
 
 SET @specReqFacetCount = LEN(@specReqFacets) - LEN(REPLACE(@specReqFacets, ',', ''));
 IF LEN(@specReqFacets) > 0
 BEGIN
	SET @specReqFacetCount = @specReqFacetCount + 1;
 END

 IF @propertyTypeFacets IS NULL OR @propertyTypeFacets = ''
 BEGIN
	SET @propertyTypeFacets = '';
 END 
 
 SET @propertyTypeFacetCount = LEN(@propertyTypeFacets) - LEN(REPLACE(@propertyTypeFacets, ',', ''));
 IF LEN(@propertyTypeFacets) > 0
 BEGIN
	SET @propertyTypeFacetCount = @propertyTypeFacetCount + 1;
 END

 SET @totalFacetCount = @amenityFacetCount + @specReqFacetCount + @propertyTypeFacetCount;

 IF @minPrice IS NOT NULL
 BEGIN
	SET @minPrice = (@minPrice / @localRate);
 END
 IF @maxPrice IS NOT NULL
 BEGIN
	SET @maxPrice = (@maxPrice / @localRate);
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
  , (geodata.STDistance(@centralLatLongGeo) / @conversion) AS distance
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
	  , (geography::STGeomFromText('POINT(' + CONVERT(varchar(100), pro.longitude) + ' ' + CONVERT(varchar(100), pro.latitude) + ')', 4326)) AS geodata
	  , '' AS [partner]
	  , '' AS internalURL
	  , '' AS urlSafeName
	  , '' AS logoURL
	 FROM dbo.tab_property pro
	 /* VERY SLOW
	 INNER JOIN dbo.tab_propertyLatLong latlong
	 ON pro.propertyId = latlong.propertyId
	 */
	 OUTER APPLY (
	  SELECT  TOP 1 dbo.tab_photo.url
	  FROM    dbo.tab_photo
	  WHERE   dbo.tab_photo.propertyId = pro.propertyId
	 ) pho
	 LEFT OUTER JOIN dbo.utils_currencyLookup curr
	 ON curr.id = currencyCode AND curr.localId = @localCurrencyCode
	 WHERE
	  ( @countryCode IS NULL OR pro.countryCode = @countryCode )
	  AND ( @typeOfProperty IS NULL OR pro.typeOfProperty = @typeOfProperty )
      AND ( @sleeps IS NULL OR pro.maximumNumberOfPeople >= @sleeps  )
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
			curr.rate IS NULL
			OR
			curr.rate = 0
			)
			OR
			(
			@minPrice <= (minimumPricePerNight / curr.rate)
			AND
			@maxPrice >= (minimumPricePerNight / curr.rate)
			)
		)
	  AND
	   (
       @sourceIdCount = 0
       OR
       sourceId IN
		    (
		    SELECT split.Item FROM dbo.SplitString(@sourceIds, ',') AS split
		    )
	   )
	  AND
		(
			(
			-- Conditions for including records with NULL latitude / longitude
			(pro.latitude IS NULL OR pro.longitude IS NULL)
			AND
			-- Not a map area search if radius passed
			(@radius > 0)
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
			(@radius = 0)
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
			/* VERY SLOW
			@radius >= (latlong.geodata.STDistance(@centralLatLongGeo) / @conversion)
			*/
			@radius >= (geography::STGeomFromText('POINT(' + CONVERT(varchar(100), pro.longitude) + ' ' + CONVERT(varchar(100), pro.latitude) + ')', 4326).STDistance(@centralLatLongGeo) / @conversion)
			)
		)
	  -- Enforce AND logic across amenities, special requirements and property types
	  AND
		(
		@amenityFacetCount = 0
		OR
		--pro.propertyId IN
			(
			-- AND logic within amenity categories
			SELECT COUNT(pf.propertyId)
			FROM dbo.tab_propertyFacts pf
			WHERE pro.propertyId = pf.propertyId
				AND propertyFacetId = 1
				AND (
					--(@amenityFacets <> '' AND facetId IN (SELECT split.Item FROM dbo.SplitString(@amenityFacets, ',') AS split))
					(facetId IN (SELECT split.Item FROM dbo.SplitString(@amenityFacets, ',') AS split))
					--CHARINDEX(',' + LTRIM(RTRIM(STR(facetId))) + ',', ',' + @amenityFacets + ',') > 0
					--OR
					--@amenityFacets = ''
					)
			-- GROUP BY... HAVING... enforces match on all ids (AND) within @amenityFacets
			GROUP BY pf.propertyId
			HAVING (
				COUNT(DISTINCT facetId) = @amenityFacetCount
				--AND
				--@amenityFacets <> ''
				--)
				--OR
				--(@amenityFacets = '')
				)
			) > 0
		)
	  AND
		(
		@specReqFacetCount = 0
		OR
		--pro.propertyId IN
			(
			-- AND logic within special requirements categories
			SELECT COUNT(pf.propertyId)
			FROM dbo.tab_propertyFacts pf
			WHERE pro.propertyId = pf.propertyId
				AND propertyFacetId = 2
				AND (
					--(@specReqFacets <> '' AND facetId IN (SELECT split.Item FROM dbo.SplitString(@specReqFacets, ',') AS split))
					(facetId IN (SELECT split.Item FROM dbo.SplitString(@specReqFacets, ',') AS split))
					--CHARINDEX(',' + LTRIM(RTRIM(STR(facetId))) + ',', ',' + @specReqFacets + ',') > 0
					--OR
					--@specReqFacets = ''
					)
			-- GROUP BY... HAVING... enforces match on all ids (AND) within @specReqFacets
			GROUP BY pf.propertyId
			HAVING (
				COUNT(DISTINCT facetId) = @specReqFacetCount
				--AND 
				--@specReqFacets <> ''
				--)
				--OR
				--(@specReqFacets = '')
				)
			) > 0
		)
	  AND
		(
		@propertyTypeFacetCount = 0
		OR
		pro.propertyId IN
			(
			-- OR logic within property type categories
			SELECT pf.propertyId
			FROM dbo.tab_propertyFacts pf
			WHERE pro.propertyId = pf.propertyId
				AND propertyFacetId = 3
				AND (
					--(@propertyTypeFacets <> '' AND facetId IN (SELECT split.Item FROM dbo.SplitString(@propertyTypeFacets, ',') AS split))
					(facetId IN (SELECT split.Item FROM dbo.SplitString(@propertyTypeFacets, ',') AS split))
					--CHARINDEX(',' + LTRIM(RTRIM(STR(facetId))) + ',', ',' + @propertyTypeFacets + ',') > 0
					--OR
					--@propertyTypeFacets = ''
					)
			-- no GROUP BY... HAVING... so can match any id (OR) within @propertyTypeFacets
			)
		)
	) mainselect
 LEFT OUTER JOIN dbo.utils_currencyLookup currency
 ON currency.id = currencyCode AND currency.localId = @localCurrencyCode
 ORDER BY rowNum
 OFFSET (@RecsPerPage * (@Page - 1)) ROWS
 FETCH NEXT @RecsPerPage ROWS ONLY;

END
