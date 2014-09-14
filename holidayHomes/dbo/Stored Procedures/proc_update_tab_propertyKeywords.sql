
--------------------------------------------------------------------------------------------
--	2014-06-10 TW
--	dbo.proc_update_tab_propertyKeywords
--  
--  updates the tab_propertyKeywords table
--  this data table supports the keywords search functionality
--		
-- History
--	2014-06-10 TW New
--  2014-06-12 TW trims, replaces, concat() MSSQL2012 function
--  2014-06-23 TW removed trims, replaces as these are now dealt with by cleanString() during the import
--  2014-06-25 TW no longer using CTE to select source data
--  2014-09-09 TW only select active properties (so propertyKeywordSearch CONTAINSTABLE selects only active properties)
--------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[proc_update_tab_propertyKeywords]
AS
BEGIN

	MERGE INTO dbo.tab_propertyKeywords AS targetKeywords
	USING
	(
		SELECT
			  propertyId
			/*
			, externalId
			, name
			, [description]
			, cityName
			, regionName
			, stateName
			, countryCode
			, countryName
			, typeOfProperty
			, amenityValues
			*/
			, keywords
			, keywordsSoundex
		FROM
		(
			SELECT
				  p.propertyId
				/*
				, p.externalId
				, p.name
				, p.[description]
				, p.cityName
				, p.regionName
				, p.stateName
				, p.countryCode
				, c.countryName
				, p.typeOfProperty
				, amenitySelect.amenityValues
				*/
				, keywords = CONCAT
				(
				  p.name
				, ' '
				, p.cityname
				, ' '
				, p.regionName
				, ' '
				, p.statename
				, ' '
				, p.countryCode
				, ' '
				, c.countryName
				, ' '
				, p.typeOfProperty
				, ' '
				, amenitySelect.amenityValues
				, ' '
				, p.[description]
				)
				FROM dbo.tab_property p
				OUTER APPLY (
					SELECT CONVERT(VARCHAR(60), COALESCE(a.amenityValue, '') + ' ')
					FROM dbo.tab_property2amenity p2a
					INNER JOIN dbo.tab_amenity a
					ON a.amenityId = p2a.amenityId
					WHERE p2a.propertyId = p.propertyId
					FOR XML PATH('')
					) amenitySelect (amenityValues)
				LEFT OUTER JOIN holidayHomes_build.import.tab_country c
				ON c.countryCode2 = ISNULL(p.countryCode, '')
				-- Only select active properties
				WHERE isActive = 1
		) innerselect
		OUTER APPLY (
			SELECT CONVERT(VARCHAR(10), COALESCE(item , '') + ' ')
			FROM
			(
				SELECT DISTINCT SOUNDEX(split.Item) AS item
				FROM dbo.SplitString(keywords, ' ') AS split
				WHERE 2 < LEN(split.Item)
					AND '0000' <> SOUNDEX(item)
			) soundexSelect
			FOR XML PATH('')
			) sx (keywordsSoundex)
	) sourceKeywords (propertyId, keywords, keywordsSoundex)
	ON sourceKeywords.propertyId = targetKeywords.propertyId

	-- changed data
	WHEN MATCHED AND
		(
			ISNULL(targetKeywords.keywords, '') <> ISNULL(sourceKeywords.keywords, '')
			OR
			ISNULL(targetKeywords.keywordsSoundex, '') <> ISNULL(sourceKeywords.keywordsSoundex, '')
		)
		THEN UPDATE SET
			  targetKeywords.keywords = sourceKeywords.keywords
			, targetKeywords.keywordsSoundex = sourceKeywords.keywordsSoundex

	-- new data
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
				(
				  propertyId
				, keywords
				, keywordsSoundex
				)
			VALUES
				(
				  sourceKeywords.propertyId
				, sourceKeywords.keywords
				, sourceKeywords.keywordsSoundex
				)

	-- deleted data
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE
	;

END
GO