--------------------------------------------------------------------------------------------
--	2014-04-09 TW
--	dbo.proc_updateHomeAwayLatLong
--  
--  updates HomeAway latitude and longitude data from homeAwayCoords table (populated by automated screen scrape)
--  this is a workaround until a similar update step in the HomeAway XML data feed import goes live
--		
-- History
--	2014-04-09 TW New
--  2014-05-12 TW Ignore bad data (impossible latitude and longitude values)
--------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[proc_updateHomeAwayLatLong]
AS
BEGIN

	UPDATE dbo.tab_property
	SET dbo.tab_property.latitude = h.latitude
		, dbo.tab_property.longitude = h.longitude
		, dbo.tab_property.propertyHashKey = HASHBYTES ('MD5'
		, ISNULL(thumbnailUrl, 'NA') + '|'
		+ ISNULL(externalURL, 'NA') + '|'
		+ ISNULL([description], 'NA') + '|'
		+ ISNULL(name, 'NA') + '|'
		+ ISNULL(regionName, 'NA') + '|'
		+ ISNULL(typeOfProperty, 'NA') + '|'
		+ ISNULL(postcode, 'NA') + '|'
		+ ISNULL(CAST(regionId AS NVARCHAR), 'NA') + '|'
		+ ISNULL(CAST(cityId AS NVARCHAR), 'NA') + '|'
		+ ISNULL(cityName, 'NA') + '|'
		+ ISNULL(stateName, 'NA') + '|'
		+ ISNULL(countryCode, 'NA') + '|'
		+ ISNULL(CAST(h.latitude AS NVARCHAR), 'NA') + '|'
		+ ISNULL(CAST(h.longitude AS NVARCHAR), 'NA') + '|'
		+ ISNULL(CAST(checkInFrom AS NVARCHAR), 'NA') + '|'
		+ ISNULL(CAST(checkOutBefore AS NVARCHAR), 'NA') + '|'
		+ ISNULL(CAST(sizeOfSpaceInSqm AS NVARCHAR), 'NA') + '|'
		+ ISNULL(CAST(sizeOfSpaceInSqft AS NVARCHAR), 'NA') + '|'
		+ ISNULL(cancellationPolicy, 'NA') + '|'
		+ ISNULL(CAST(minimumPricePerNight AS NVARCHAR), 'NA') + '|'
		+ ISNULL(currencyCode, 'NA') + '|'
		+ ISNULL(CAST(numberOfProperBedrooms AS NVARCHAR), 'NA') + '|'
		+ ISNULL(CAST(numberOfBathrooms AS NVARCHAR), 'NA') + '|'
		+ ISNULL([floor], 'NA') + '|'
		+ ISNULL(CAST(reviewsCount AS NVARCHAR), 'NA') + '|'
		+ ISNULL(CAST(averageRating AS NVARCHAR), 'NA') + '|'
		+ ISNULL(CAST(maximumNumberOfPeople AS NVARCHAR), 'NA') + '|'
		+ ISNULL(CAST(numberOfOtherRoomsWhereGuestsCanSleep AS NVARCHAR), 'NA') + '|'
		+ ISNULL(CAST(minimumDaysOfStay AS NVARCHAR), 'NA')
		)
	FROM dbo.tab_property p
	INNER JOIN dbo.homeAwayCoords h
	ON
		(
		h.externalId = p.externalId
		AND ISNULL(h.latitude, 0) <> 0
		AND ISNULL(h.longitude, 0) <> 0
		-- ignore bad data
		AND ABS(ISNULL(h.latitude, 0)) <= 90
		AND ABS(ISNULL(h.longitude, 0)) <= 180
		)
	WHERE p.sourceId = 2
		AND ISNULL(p.latitude, 0) <> h.latitude
		AND ISNULL(p.longitude, 0) <> h.longitude
	;

	-- Just in case...
	UPDATE dbo.tab_property
	SET   latitude  = NULL
		, longitude = NULL
	WHERE ABS(ISNULL(latitude, 0)) > 90 OR ABS(ISNULL(longitude, 0)) > 180
	;

END
GO