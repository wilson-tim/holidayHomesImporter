-- =============================================
-- Author:	Tim Wilson
-- Create date: 10/04/2014
-- Description:	Facet counts for propertyAreaSearch
--
-- History
--  2014-04-10 TW new
--  2014-04-11 TW optimised
-- =============================================
CREATE PROCEDURE [dbo].[propertyAreaSearchFacetCounts]
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
AS
BEGIN
 -- SET NOCOUNT ON added to prevent extra result sets from
 -- interfering with SELECT statements.
 SET NOCOUNT ON;

 DECLARE @sourceId int
	, @conversion decimal(10,4)
	, @centralLatLongGeo geography;

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
	    facts.propertyFacetId
	  , facts.propertyFacetName
	  , facts.facetId
	  , facts.facetName
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
	 WHERE
	  ( @typeOfProperty IS NULL OR pro.typeOfProperty = @typeOfProperty )
	  AND ( pro.maximumNumberOfPeople >= @sleeps )
	  AND ( @maxSleeps IS NULL OR pro.maximumNumberOfPeople <= @maxSleeps )
	  AND ( @numberOfBedrooms IS NULL OR numberOfProperBedrooms = @numberOfBedrooms )
	  AND
	   (
	   @sourceId IS NULL
	   OR
	   sourceId = @sourceId
	   OR
	   (
	   @sourceId = 0 AND sourceId IN
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
	 ) mainselect
-- Using 'INNER JOIN dbo.tab_propertyFacts facts' instead of LEFT OUTER JOIN to avoid WHERE
-- WHERE mainselect.propertyFacetId IS NOT NULL
 GROUP BY mainselect.propertyFacetId, mainselect.facetId
 ORDER BY mainselect.propertyFacetId, mainselect.facetId

END
