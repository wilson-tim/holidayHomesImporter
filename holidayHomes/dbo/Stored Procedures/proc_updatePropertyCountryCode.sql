--------------------------------------------------------------------------------------------
--	2014-07-14 TW
--	dbo.proc_updatePropertyCountryCode
--  
--  updates property countryCode data from Google API lookup data
--  saved in table dbo.tab_propertyCountryLookup
--  for properties having latitude and longitude data but without countryCode data
--		
-- History
--	2014-07-14 TW New
--------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[proc_proc_updatePropertyCountryCode]
AS
BEGIN

	-- Update country code lookup table with new properties to lookup country codes for
	/*
	INSERT INTO dbo.tab_propertyCountryLookup
		(sourceId, externalId, propertyId, latitude, longitude)
	SELECT p.sourceId, p.externalId, p.propertyId, p.latitude, p.longitude
	FROM dbo.tab_propertyCountryLookup
	LEFT OUTER JOIN dbo.tab_propertyCountryLookup pc
	ON pc.propertyId = p.propertyId
	WHERE pc.propertyId IS NULL
		AND (p.countryCode IS NULL)
		AND (ABS(ISNULL(p.latitude, 0)) <= 90 AND ABS(ISNULL(p.longitude, 0)) <= 180)
	;
	*/
	MERGE INTO dbo.tab_propertyCountryLookup pc
	USING dbo.tab_property p
	ON pc.propertyId = p.propertyId

	WHEN NOT MATCHED BY TARGET
		AND (p.countryCode IS NULL)
		AND (ABS(p.latitude) <= 90 AND ABS(p.longitude) <= 180)
		THEN INSERT (sourceId, externalId, propertyId, latitude, longitude)
		VALUES (p.sourceId, p.externalId, p.propertyId, p.latitude, p.longitude)

	WHEN NOT MATCHED BY SOURCE THEN DELETE
	;

	-- Update property data with new countryCode data
	UPDATE dbo.tab_property
		SET countryCode = pc.countryCode2
	FROM dbo.tab_property p
	INNER JOIN dbo.tab_propertyCountryLookup pc
	ON pc.propertyId = p.propertyId
		AND pc.countryCode2 IS NOT NULL
		AND pc.countryCode2 <> ISNULL(p.countryCode, '')
	WHERE (ABS(p.latitude) <= 90 AND ABS(p.longitude) <= 180)
	;

END
GO