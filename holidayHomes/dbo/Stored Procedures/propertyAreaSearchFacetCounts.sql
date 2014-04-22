-- =============================================
-- Author:	Tim Wilson
-- Create date: 10/04/2014
-- Description:	Facet counts for propertyAreaSearch
--
-- History
--  2014-04-10 TW new
--  2014-04-11 TW optimised
--  2014-04-15 TW added faceted search criteria parameters @amenityFacets, @specReqFacets, @propertyTypeFacets
--                (each passed as comma delimited lists, e.g. '1,7,10')
-- =============================================
CREATE PROCEDURE [dbo].[propertyAreaSearchFacetCounts]
-- Add the parameters for the stored procedure here
  @searchCriteria VARCHAR(150)
, @typeOfProperty VARCHAR(15) = NULL
, @countryCode VARCHAR(2) = NULL
, @localCurrencyCode nvarchar(3) = 'GBP'
, @sleeps int = 1
, @maxSleeps int = NULL
, @numberOfBedrooms int = NULL
, @sourceIds varchar(MAX) = NULL
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
	, @totalFacetCount int;

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

 IF @centralLatitude IS NOT NULL AND @centralLongitude IS NOT NULL
 BEGIN
	SET @centralLatLongGeo = geography::STGeomFromText('POINT(' + CONVERT(varchar(100), @centralLongitude) + ' ' + CONVERT(varchar(100), @centralLatitude) + ')', 4326);
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

-- SELECTion time...
 SELECT
	  propertyFacetId
	  , MAX(propertyFacetName) AS propertyFacetName
	  , facetId
	  , MAX(facetName) AS facetName
	  , COUNT(*) AS facetCount
 FROM
	 (
	 SELECT
	    facts.propertyId
	  , facts.propertyFacetId
	  , facts.propertyFacetName
	  , facts.facetId
	  , facts.facetName
	  , rownum = ROW_NUMBER() OVER (PARTITION BY facts.propertyId, propertyFacetId, facts.facetId ORDER BY facts.dataId)
	 /*
	 FROM dbo.tab_propertyFacts facts
	 INNER JOIN dbo.tab_property pro
	 ON pro.propertyId = facts.propertyId
	 */
	 
	 FROM dbo.tab_property pro

	 INNER JOIN dbo.tab_propertyFacts facts
	 ON pro.propertyId = facts.propertyId
	 
	 /* VERY SLOW (see below)
	 INNER JOIN dbo.tab_propertyLatLong latlong
	 ON latlong.propertyId = facts.propertyId
	 */
	 LEFT OUTER JOIN dbo.utils_currencyLookup curr
	 ON curr.id = currencyCode AND curr.localId = @localCurrencyCode
	 WHERE
	  ( @typeOfProperty IS NULL OR pro.typeOfProperty = @typeOfProperty )
	  AND ( @sleeps IS NULL OR pro.maximumNumberOfPeople >= @sleeps )
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
			(@minPrice / @localRate) <= (minimumPricePerNight / curr.rate)
			AND
			(@maxPrice / @localRate) >= (minimumPricePerNight / curr.rate)
			)
		)
	  AND
	   (
	   @sourceId IS NULL
	   OR
	   sourceId = @sourceId
	   OR
	   (
	   sourceId IN
		(
		SELECT split.Item FROM dbo.SplitString(@sourceIds, ',') AS split
		)
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
			/* VERY SLOW (see above)
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
		pro.propertyId IN
			(
			-- AND logic within amenity categories
			SELECT pf.propertyId
			FROM dbo.tab_propertyFacts pf
			WHERE pro.propertyId = pf.propertyId
				AND propertyFacetId = 1
				AND (
					(@amenityFacets <> '' AND facetId IN (SELECT split.Item FROM dbo.SplitString(@amenityFacets, ',') AS split))
					OR
					@amenityFacets = ''
					)
			-- GROUP BY... HAVING... enforces match on all ids (AND) within @amenityFacets
			GROUP BY pf.propertyId
			HAVING (
				COUNT(DISTINCT facetId) = @amenityFacetCount
				AND
				@amenityFacets <> ''
				)
				OR
				(@amenityFacets = '')
				)
			)
	  AND
		(
		@specReqFacetCount = 0
		OR
		pro.propertyId IN
			(
			-- AND logic within special requirements categories
			SELECT pf.propertyId
			FROM dbo.tab_propertyFacts pf
			WHERE pro.propertyId = pf.propertyId
				AND propertyFacetId = 2
				AND (
					(@specReqFacets <> '' AND facetId IN (SELECT split.Item FROM dbo.SplitString(@specReqFacets, ',') AS split))
					OR
					@specReqFacets = ''
					)
			-- GROUP BY... HAVING... enforces match on all ids (AND) within @specReqFacets
			GROUP BY pf.propertyId
			HAVING (
				COUNT(DISTINCT facetId) = @specReqFacetCount
				AND 
				@specReqFacets <> ''
				)
				OR
				(@specReqFacets = '')
			)
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
					(@propertyTypeFacets <> '' AND facetId IN (SELECT split.Item FROM dbo.SplitString(@propertyTypeFacets, ',') AS split))
					OR
					@propertyTypeFacets = ''
					)
			-- no GROUP BY... HAVING... so can match any id (OR) within @propertyTypeFacets
			)
		)
	 ) mainselect
-- Using 'INNER JOIN dbo.tab_propertyFacts facts' instead of LEFT OUTER JOIN to avoid WHERE
-- WHERE mainselect.propertyFacetId IS NOT NULL
 WHERE mainselect.rownum = 1
 GROUP BY mainselect.propertyFacetId, mainselect.facetId
 ORDER BY mainselect.propertyFacetId, mainselect.facetId

END
