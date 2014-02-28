-- =============================================
-- Author:		James Privett
-- Create date: 20/12/2013
-- Description:	Generate random property results (for when you hit the site for the first time)
-- =============================================
CREATE PROCEDURE dbo.propertyRandomSearch
@countryCode VARCHAR(2) = NULL
AS
BEGIN
	SELECT top(10) pro.name, pro.description, pro.latitude, pro.longitude, pro.propertyId, pro.externalURL, pro.numberOfProperBedrooms, pro.maximumNumberOfPeople, pro.averageRating, pho.url, pro.countryCode, pro.cityName, pro.sourceId, pro.externalId, pro.regionName, pro.minimumPricePerNight, pro.currencyCode, '' AS partner, '' AS internalURL, '' AS urlSafeName
		FROM tab_property pro 
		CROSS APPLY
			(
			SELECT  TOP 1 tab_photo.url
			FROM    tab_photo
			WHERE   tab_photo.propertyId = pro.propertyId
			) pho
	WHERE pro.countryCode = ISNULL(@countryCode,countryCode)
	GROUP BY pro.name, pro.description, pro.latitude, pro.longitude, pro.propertyId, pro.externalURL, pro.numberOfProperBedrooms, pro.maximumNumberOfPeople, pro.averageRating, pho.url, pro.countryCode, pro.cityName, pro.sourceId, pro.externalId, pro.regionName, pro.minimumPricePerNight, pro.currencyCode
	order by newid()
END