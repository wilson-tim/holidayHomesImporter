-- =============================================
-- Author:	Tim Wilson
-- Create date: 06/08/2014
-- Description:	Facet counts for propertyAreaKeywordSearch
--
-- Parameters
-- @searchCriteria     search string (optional)
-- @keywords           list of keywords, space delimited (optional)
-- @typeOfProperty     type of property (optional)
-- @countryCode        country code, ISO 3166-1 alpha-2 (optional)
-- @localCurrencyCode  local currency code, ISO 4217 (optional)(default value 'GBP')
-- @sleeps             number of beds (optional)(default value 1)
-- @maxSleeps          maximum number of beds (optional)
-- @numberOfBedrooms   number of bedrooms (optional)
-- @sourceIds          list of partner ids, comma delimited (optional)
-- @minPrice           minimum rate in GBP (optional)(default value 1)
-- @maxPrice           maximum rate in GBP (optional)(default value 10000)
-- @centralLatitude    central latitude value 
-- @centralLongitude   central longitude value
-- @swLatitude         area SW corner latitude
-- @swLongitude        area SW corner longitude
-- @neLatitude         area NE corner latitude
-- @neLongitude        area NE corner longitude
-- @radius             radius value
-- @imperial           if 1 then radius value is in miles, else if 0 then radius value is in kilometres
-- @amenityFacets      comma delimited string of 1 or more amenity facet ids (optional)
-- @specReqFacets      comma delimited string of 1 or more special requirement facet ids (optional)
-- @propertyTypeFacets comma delimited string of 1 or more property type facet ids (optional)
--
-- Parameters
-- @searchCriteria     search string (see below)
-- @keywords           list of keywords, space delimited (see below)
-- @typeOfProperty     type of property (optional)(default value NULL)
-- @countryCode        country code, ISO 3166-1 alpha-2 (optional)(default value NULL)
-- @localCurrencyCode  local currency code, ISO 4217 (optional)(default value 'GBP')
-- @sleeps             number of beds (optional)(default value 1)
-- @maxSleeps          maximum number of beds (optional)(default value NULL)
-- @numberOfBedrooms   number of bedrooms (optional)(default value NULL)
-- @sourceIds          list of partner ids, comma delimited (optional)(default value NULL)
-- @minPrice           minimum rate in GBP (optional)(default value 1)
-- @maxPrice           maximum rate in GBP (optional)(default value 10000)
-- @centralLatitude    central latitude value (see below)
-- @centralLongitude   central longitude value (see below)
-- @swLatitude         area SW corner latitude (see below)
-- @swLongitude        area SW corner longitude (see below)
-- @neLatitude         area NE corner latitude (see below)
-- @neLongitude        area NE corner longitude (see below)
-- @radius             radius value (see below)
-- @imperial           if 1 then radius value is in miles, else if 0 then radius value is in kilometres
-- @amenityFacets      comma delimited string of 1 or more amenity facet ids (optional)(default value NULL)
-- @specReqFacets      comma delimited string of 1 or more special requirement facet ids (optional)(default value NULL)
-- @propertyTypeFacets comma delimited string of 1 or more property type facet ids (optional)(default value NULL)
--
-- Must pass either or both @searchCriteria and @keywords, @searchCriteria is required if @radius > 0
--
-- Must pass @radius > 0 and @centralLatitude and @centralLongitude (radius search)
-- OR
-- pass @radius = 0 / @radius = NULL and @swLatitude and @swLongitude and @neLatitude and @neLongitude (area search)
--
-- History
--	2014-08-06 TW new stored procedure
--  2014-08-08 TW continued development
-- =============================================
CREATE PROCEDURE [dbo].[propertyAreaKeywordSearchFacetCounts]
-- Add the parameters for the stored procedure here
  @searchCriteria VARCHAR(150) = NULL
, @keywords VARCHAR(8000) = NULL
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
	, @sourceIdCount int
	, @searchString VARCHAR(8000)
	, @searchStringSoundex VARCHAR(8000)
	;

 IF @sourceIds IS NULL OR @sourceIds = ''
 BEGIN
	SET @sourceIds = '';
 END 
 
 SET @sourceIdCount = LEN(@sourceIds) - LEN(REPLACE(@sourceIds, ',', ''));
 IF LEN(@sourceIds) > 0
 BEGIN
	SET @sourceIdCount = @sourceIdCount + 1;
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

 IF @keywords <> '' AND @keywords IS NOT NULL
 BEGIN
	 -- Remove round brackets, etc. from @keywords
	 SET @keywords = REPLACE(REPLACE(REPLACE(REPLACE(@keywords, '(', ''), ')', ''), ';', ''), '''', '');

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

	 SET @searchStringSoundex = LEFT(@searchStringSoundex, LEN(@searchStringSoundex) - 4)

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
		  , MAX(facts.propertyFacetName) AS propertyFacetName
		  , facts.facetId
		  , MAX(facts.facetName) AS facetName
		  --, rownum = ROW_NUMBER() OVER (PARTITION BY facts.propertyId, facts.propertyFacetId, facts.facetId ORDER BY facts.dataId)
	 
		 FROM dbo.tab_propertyFacts facts

		 INNER JOIN dbo.tab_property pro
		 ON pro.propertyId = facts.propertyId
	 
		 /*
		 FROM dbo.tab_property pro

		 INNER JOIN dbo.tab_propertyFacts facts
		 ON pro.propertyId = facts.propertyId
		 */
		 /* VERY SLOW (see below)
		 INNER JOIN dbo.tab_propertyLatLong latlong
		 ON latlong.propertyId = facts.propertyId
		 */
		 INNER JOIN
			(SELECT
				  propertyId
				, [rank]
				, rownum = ROW_NUMBER() OVER (PARTITION BY propertyId ORDER BY [RANK] DESC)
			FROM
				(
					-- Text search (with boosted rank value)
					SELECT
						  pk.propertyId
--						, pk.keywords
--						, pk.keywordsSoundex
						, ct.[RANK] * 1000
					FROM dbo.tab_propertyKeywords pk
					INNER JOIN CONTAINSTABLE(
						  dbo.tab_propertyKeywords
						, keywords
						, @searchString
						) ct
					ON ct.[KEY] = pk.propertyId

					UNION ALL

					-- Soundex search
					SELECT
						  pk.propertyId
--						, pk.keywords
--						, pk.keywordsSoundex
						, ct.[RANK]
					FROM dbo.tab_propertyKeywords pk
					INNER JOIN CONTAINSTABLE(
						  dbo.tab_propertyKeywords
						, keywordsSoundex
						, @searchStringSoundex
						) ct
					ON ct.[KEY] = pk.propertyId
				) resultsList (propertyId, [rank])
			) resultsListIds
		 ON pro.propertyId = resultsListIds.propertyId
			AND resultsListIds.rownum = 1

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
		   isActive = 1
		  AND
		   (
		   @sourceIdCount = 0
		   OR
		   sourceId IN
			   (
			   SELECT split.Item FROM dbo.SplitString(@sourceIds, ',') AS split
			   )
		   --CHARINDEX(',' + LTRIM(RTRIM(STR(sourceId))) + ',', ',' + @sourceIds + ',') > 0
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
			GROUP BY facts.propertyId, facts.propertyFacetId, facts.facetId
		 ) mainselect
	-- Using 'INNER JOIN dbo.tab_propertyFacts facts' instead of LEFT OUTER JOIN to avoid WHERE
	-- WHERE mainselect.propertyFacetId IS NOT NULL
	-- WHERE mainselect.rownum = 1
	 GROUP BY mainselect.propertyFacetId, mainselect.facetId
	 ORDER BY mainselect.propertyFacetId, mainselect.facetId
 END
 ELSE
 BEGIN
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
		  , MAX(facts.propertyFacetName) AS propertyFacetName
		  , facts.facetId
		  , MAX(facts.facetName) AS facetName
		  --, rownum = ROW_NUMBER() OVER (PARTITION BY facts.propertyId, facts.propertyFacetId, facts.facetId ORDER BY facts.dataId)
	 
		 FROM dbo.tab_propertyFacts facts

		 INNER JOIN dbo.tab_property pro
		 ON pro.propertyId = facts.propertyId
	 
		 /*
		 FROM dbo.tab_property pro

		 INNER JOIN dbo.tab_propertyFacts facts
		 ON pro.propertyId = facts.propertyId
		 */
		 /* VERY SLOW (see below)
		 INNER JOIN dbo.tab_propertyLatLong latlong
		 ON latlong.propertyId = facts.propertyId
		 */
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
		   isActive = 1
		  AND
		   (
		   @sourceIdCount = 0
		   OR
		   sourceId IN
			   (
			   SELECT split.Item FROM dbo.SplitString(@sourceIds, ',') AS split
			   )
		   --CHARINDEX(',' + LTRIM(RTRIM(STR(sourceId))) + ',', ',' + @sourceIds + ',') > 0
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
			GROUP BY facts.propertyId, facts.propertyFacetId, facts.facetId
		 ) mainselect
	-- Using 'INNER JOIN dbo.tab_propertyFacts facts' instead of LEFT OUTER JOIN to avoid WHERE
	-- WHERE mainselect.propertyFacetId IS NOT NULL
	-- WHERE mainselect.rownum = 1
	 GROUP BY mainselect.propertyFacetId, mainselect.facetId
	 ORDER BY mainselect.propertyFacetId, mainselect.facetId
 END
 ;

END