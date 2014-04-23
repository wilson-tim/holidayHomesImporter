--------------------------------------------------------------------------------------------
--	2014-03-31 TW
--	dbo.proc_updateData_tab_propertyLatLong
--  
--  updates table dbo.tab_propertyLatLong for new / changed / deleted geographic data
--		
-- History
--	2014-03-31 TW New
--------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[proc_updateData_tab_propertyLatLong]
AS
BEGIN

	MERGE dbo.tab_propertyLatLong AS latlong
	USING dbo.tab_property AS property
	ON (latlong.propertyId = property.propertyId)
	-- changed data
	WHEN MATCHED AND (latlong.latitude <> property.latitude OR latlong.longitude <> property.longitude)
		THEN UPDATE SET
			latlong.latitude = property.latitude
			, latlong.longitude = property.longitude
			, latlong.geodata = geography::STGeomFromText('POINT(' + CONVERT(varchar(100), property.longitude) + ' ' + CONVERT(varchar(100), property.latitude) + ')', 4326)
	-- new data
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
			(
			propertyId
			, latitude
			, longitude
			, geodata
			)
		VALUES
			(
			property.propertyId
			, property.latitude
			, property.longitude
			, geography::STGeomFromText('POINT(' + CONVERT(varchar(100), property.longitude) + ' ' + CONVERT(varchar(100), property.latitude) + ')', 4326)
			)
	-- deleted data
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE
	;

END
GO