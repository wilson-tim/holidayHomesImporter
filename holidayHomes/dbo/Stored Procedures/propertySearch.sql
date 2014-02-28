-- =============================================
-- Author:	James Privett
-- Create date: 09/12/2013
-- Description:	Search for a property
--
-- History
--	2014-01-08 MC added nullable params, dynamic order by (needs more), totalCount, OFFSET and FETCH pagination
--  2014-01-08 JP added pro.sourceId, pro.externalId to select statement
--  2014-01-10 JP added pro.minimumPricePerNight to select statement
-- =============================================
CREATE PROCEDURE [dbo].[propertySearch]
-- Add the parameters for the stored procedure here
  @searchCriteria VARCHAR(150) = NULL
, @typeOfProperty VARCHAR(15) = NULL
, @sleeps int
, @Page int
, @RecsPerPage int
, @orderBy VARCHAR(15) = 'default'
, @orderDESC BIT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Determine the first record and last record 
	DECLARE @FirstRec int, @LastRec int

	SELECT @FirstRec = (@Page - 1) * @RecsPerPage
	SELECT @LastRec = (@Page * @RecsPerPage + 1);

	-- here is the main select
	SELECT totalCount = COUNT(1) OVER ()
	, rowNum = ROW_NUMBER() OVER (ORDER BY CASE
		   WHEN @orderBy = 'beds' THEN POWER(-1, @orderDESC) * pro.maximumNumberOfPeople
		   WHEN @orderBy = 'rating' THEN POWER(-1, @orderDESC) * ISNULL(pro.averageRating, 0.1)
		   WHEN @orderBy = 'price' THEN POWER(-1, @orderDESC) * ISNULL(pro.minimumPricePerNight, 100000)
		   ELSE -pro.propertyId
		END
	)
	, pro.name, pro.[description], pro.latitude, pro.longitude, pro.propertyId, pro.externalURL, pro.numberOfProperBedrooms
	, pro.maximumNumberOfPeople, pro.averageRating, pho.url, pro.countryCode, pro.cityName, pro.sourceId, pro.externalId, pro.regionName, pro.minimumPricePerNight, pro.currencyCode, '' AS partner, '' AS internalURL, '' AS urlSafeName
	FROM tab_property pro
	CROSS APPLY (
		SELECT  TOP 1 tab_photo.url
		FROM    tab_photo
		WHERE   tab_photo.propertyId = pro.propertyId
	) pho
	WHERE ( @searchCriteria IS NULL OR pro.cityName like @searchCriteria OR pro.regionName like @searchCriteria )
	AND ( @typeOfProperty IS NULL OR pro.typeOfProperty = @typeOfProperty )
	AND pro.maximumNumberOfPeople >= isNull(@sleeps, 1)
	ORDER BY rowNum
	OFFSET (@RecsPerPage * (@Page - 1)) ROWS
	FETCH NEXT @RecsPerPage ROWS ONLY;

END