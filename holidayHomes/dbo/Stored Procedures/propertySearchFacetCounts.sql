-- =============================================
-- Author:	Tim Wilson
-- Create date: 10/04/2014
-- Description:	Facet counts for propertySearch
--
-- History
--  2014-04-10 TW new
--  2014-04-11 TW optimised
--  2014-04-16 TW added faceted search criteria parameters @amenityFacets, @specReqFacets, @propertyTypeFacets
--                (each passed as comma delimited lists, e.g. '1,7,10')
-- =============================================
CREATE PROCEDURE [dbo].[propertySearchFacetCounts]
-- Add the parameters for the stored procedure here
  @searchCriteria VARCHAR(150) = NULL
, @typeOfProperty VARCHAR(15) = NULL
, @countryCode VARCHAR(2) = NULL
, @localCurrencyCode nvarchar(3) = 'GBP'
, @sleeps int = 1
, @maxSleeps int = NULL
, @numberOfBedrooms int = NULL
, @sourceIds varchar(200) = NULL
, @minPrice int = 1
, @maxPrice int = 10000
, @amenityFacets varchar(200) = NULL
, @specReqFacets varchar(200) = NULL
, @propertyTypeFacets varchar(200) = NULL
AS
BEGIN
 -- SET NOCOUNT ON added to prevent extra result sets from
 -- interfering with SELECT statements.
 SET NOCOUNT ON;

 DECLARE @sourceId int
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

 SET @sleeps = ISNULL(@sleeps, 1);

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
	 SELECT  -- could have DISTINCT here but ROW_NUMBER() OVER... seems to be faster
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

	 LEFT OUTER JOIN dbo.utils_currencyLookup currency
	 ON currency.id = currencyCode AND currency.localId = @localCurrencyCode
	 OUTER APPLY (
		-- In conjunction with the WHERE clause below
		-- this OUTER APPLY in fact operates as a conditional CROSS APPLY
		-- condition is TRUE if one or more facet ids are passed

		-- INTERSECT enforces AND logic across amenities, special requirements and property types

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

		INTERSECT

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

		INTERSECT

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
	 ) outerApplyFacts  -- end of OUTER APPLY
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
		(
		SELECT split.Item FROM dbo.SplitString(@sourceIds, ',') AS split
		)
   )
   AND
   (
   -- No facet selections passed, ignore OUTER APPLY on dbo.tab_propertyFacts
   @totalFacetCount = 0
   OR
   -- Facet selections passed, filter OUTER APPLY on dbo.tab_propertyFacts to simulate CROSS APPLY
   (@totalFacetCount > 0 AND outerApplyFacts.propertyId IS NOT NULL)
   )
   ) mainselect
-- Using 'INNER JOIN dbo.tab_propertyFacts facts' instead of LEFT OUTER JOIN to avoid WHERE
-- WHERE mainselect.propertyFacetId IS NOT NULL
 WHERE mainselect.rownum = 1
 GROUP BY mainselect.propertyFacetId, mainselect.facetId
 ORDER BY mainselect.propertyFacetId, mainselect.facetId

END
GO
