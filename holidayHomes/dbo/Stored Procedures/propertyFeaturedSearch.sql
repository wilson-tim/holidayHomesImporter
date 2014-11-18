-- =============================================
-- Author:		James Privett
-- Create date: 09/15/2014
-- Description:	Return a query of featured properties
-- =============================================
CREATE PROCEDURE [dbo].[propertyFeaturedSearch] 
	  @searchCriteria VARCHAR(150)
	, @countryCode VARCHAR(2) = NULL
	, @centralLatitude float
	, @centralLongitude float
	, @imperial bit = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE	
	  @conversion decimal(10,4)
	, @centralLatLongGeo geography
	;

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

	SELECT top(8) pro.name
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
		, ((geography::STGeomFromText('POINT(' + CONVERT(varchar(100), pro.longitude) + ' ' + CONVERT(varchar(100), pro.latitude) + ')', 4326)).STDistance(@centralLatLongGeo) / @conversion) AS distance
		, '' AS partner
		, '' AS internalURL
		, '' AS urlSafeName
		, '' AS logoURL
		FROM tab_property pro 
		INNER JOIN tab_propertyFeatured fea on fea.externalId = pro.externalId AND fea.sourceId = pro.sourceId
		CROSS APPLY
			(
			SELECT  TOP 1 tab_photo.url
			FROM    tab_photo
			WHERE   tab_photo.propertyId = pro.propertyId
			) pho
	WHERE pro.countryCode = ISNULL(@countryCode,countryCode)
	AND (@searchCriteria IS NULL OR pro.cityName LIKE @searchCriteria OR pro.regionName LIKE @searchCriteria )
	AND pro.latitude IS NOT NULL
	AND pro.longitude IS NOT NULL
	GROUP BY pro.name
		, pro.description
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
	ORDER BY
		CASE
			WHEN (pro.latitude IS NOT NULL AND pro.longitude IS NOT NULL AND @centralLatitude IS NOT NULL AND @centralLongitude IS NOT NULL) THEN
				((geography::STGeomFromText('POINT(' + CONVERT(varchar(100), pro.longitude) + ' ' + CONVERT(varchar(100), pro.latitude) + ')', 4326)).STDistance(geography::STGeomFromText('POINT(' + CONVERT(varchar(100), @centralLongitude) + ' ' + CONVERT(varchar(100), @centralLatitude) + ')', 4326)))
			ELSE
				-- Use a suitable number depending on whether you want properties without lat / long at the top or bottom of the results list
				999999
		END
		ASC;

END