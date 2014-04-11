-- =============================================
-- Author:	Tim Wilson
-- Create date: 10/04/2014
-- Description:	Facet counts for propertySearch
--
-- History
--  2014-04-10 TW new
--  2014-04-11 TW optimised
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
, @sourceIds varchar(MAX) = NULL
AS
BEGIN
 -- SET NOCOUNT ON added to prevent extra result sets from
 -- interfering with SELECT statements.
 SET NOCOUNT ON;

 DECLARE @sourceId int;

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
 WHERE
  ( @searchCriteria IS NULL OR pro.cityName LIKE @searchCriteria OR pro.regionName LIKE @searchCriteria )
  AND ( @countryCode IS NULL OR pro.countryCode = @countryCode )
  AND ( @typeOfProperty IS NULL OR pro.typeOfProperty = @typeOfProperty )
  AND ( pro.maximumNumberOfPeople >= @sleeps )
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
   ) mainselect
-- Using 'INNER JOIN dbo.tab_propertyFacts facts' instead of LEFT OUTER JOIN to avoid WHERE
-- WHERE mainselect.propertyFacetId IS NOT NULL
 GROUP BY mainselect.propertyFacetId, mainselect.facetId
 ORDER BY mainselect.propertyFacetId, mainselect.facetId

END
GO
