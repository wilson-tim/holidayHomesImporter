﻿
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
--------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[proc_update_tab_propertyKeywords]
AS
BEGIN

	WITH keywords_CTE ( propertyId, keywords, keywordsSoundex )
	AS
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
					SELECT CONVERT(varchar(MAX), COALESCE(a.amenityValue, '') + ' ')
					FROM dbo.tab_property2amenity p2a
					INNER JOIN dbo.tab_amenity a
					ON a.amenityId = p2a.amenityId
					WHERE p2a.propertyId = p.propertyId
					FOR XML PATH('')
					) amenitySelect (amenityValues)
				LEFT OUTER JOIN holidayHomes_build.import.tab_country c
				ON c.countryCode2 = ISNULL(p.countryCode, '')
		) innerselect
		OUTER APPLY (
			SELECT CONVERT(varchar(MAX), COALESCE(item , '') + ' ')
			FROM
			(
				SELECT DISTINCT SOUNDEX(split.Item) AS item
				FROM dbo.SplitString(keywords, ' ') AS split
				WHERE 2 < LEN(split.Item)
					AND '0000' <> SOUNDEX(item)
			) soundexSelect
			FOR XML PATH('')
			) sx (keywordsSoundex)
		)

	MERGE INTO dbo.tab_propertyKeywords AS keywords
	USING keywords_CTE
	ON keywords_CTE.propertyId = keywords.propertyId

	-- changed data
	WHEN MATCHED AND
		(
			ISNULL(keywords.keywords, '') <> ISNULL(keywords_CTE.keywords, '')
			OR
			ISNULL(keywords.keywordsSoundex, '') <> ISNULL(keywords_CTE.keywordsSoundex, '')
		)
		THEN UPDATE SET
			  keywords.keywords = keywords_CTE.keywords
			, keywords.keywordsSoundex = keywords_CTE.keywordsSoundex

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
				  keywords_CTE.propertyId
				, keywords_CTE.keywords
				, keywords_CTE.keywordsSoundex
				)

	-- deleted data
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE
	;

END
GO