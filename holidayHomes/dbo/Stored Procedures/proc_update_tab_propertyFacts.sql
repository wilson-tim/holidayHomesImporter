
--------------------------------------------------------------------------------------------
--	2014-04-10 TW
--	dbo.proc_update_tab_propertyFacts
--  
--  updates the tab_propertyFacts table
--  this is the denormalised data table which supports the faceted search functionality
--		
-- History
--	2014-04-10 TW New
--  2014-05-21 TW Using child table dbo.tab_propertyTypeFacetsLookup
--------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[proc_update_tab_propertyFacts]
AS
BEGIN

	WITH facts_CTE ( propertyId, propertyFacetId, propertyFacetName, facetId, facetName, dataId )
	AS
		(
		-- amenities
		SELECT dbo.tab_property.propertyId
		, 1 AS propertyFacetId
		, dbo.tab_propertyFacets.propertyFacetName
		, dbo.tab_amenityFacetsLookup.amenityFacetId AS facetId
		, dbo.tab_amenityFacets.amenityFacetName AS facetName
		, dbo.tab_property2amenity.amenityId AS dataId
		FROM dbo.tab_property
		INNER JOIN dbo.tab_propertyFacets
		ON dbo.tab_propertyFacets.propertyFacetId = 1
		LEFT OUTER JOIN dbo.tab_property2amenity
		ON dbo.tab_property2amenity.propertyId = dbo.tab_property.propertyID
		LEFT OUTER JOIN dbo.tab_amenityFacetsLookup
		ON dbo.tab_amenityFacetsLookup.amenityId = dbo.tab_property2amenity.amenityId
		INNER JOIN dbo.tab_amenityFacets
		ON dbo.tab_amenityFacets.amenityFacetId = dbo.tab_amenityFacetsLookup.amenityFacetId
		AND dbo.tab_amenityFacets.amenitySpecial = 0

		UNION

		-- special requirements
		SELECT dbo.tab_property.propertyId
		, 2 AS propertyFacetId
		, dbo.tab_propertyFacets.propertyFacetName
		, dbo.tab_amenityFacetsLookup.amenityFacetId AS facetId
		, dbo.tab_amenityFacets.amenityFacetName AS facetName
		, dbo.tab_property2amenity.amenityId AS dataId
		FROM dbo.tab_property
		INNER JOIN dbo.tab_propertyFacets
		ON dbo.tab_propertyFacets.propertyFacetId = 2
		LEFT OUTER JOIN dbo.tab_property2amenity
		ON dbo.tab_property2amenity.propertyId = dbo.tab_property.propertyID
		LEFT OUTER JOIN dbo.tab_amenityFacetsLookup
		ON dbo.tab_amenityFacetsLookup.amenityId = dbo.tab_property2amenity.amenityId
		INNER JOIN dbo.tab_amenityFacets
		ON dbo.tab_amenityFacets.amenityFacetId = dbo.tab_amenityFacetsLookup.amenityFacetId
		AND dbo.tab_amenityFacets.amenitySpecial = 1

		UNION

		-- property types
		-- (best solution given that there is no property types child table in the current design)
		/*
		SELECT dbo.tab_property.propertyId
		, 3 AS propertyFacetId
		, dbo.tab_propertyFacets.propertyFacetName
		, dbo.tab_propertyTypeFacets.propertyTypeFacetId AS facetId
		, dbo.tab_propertyTypeFacets.propertyTypeFacetName AS facetName
		, dbo.tab_propertyTypeFacets.propertyTypeFacetId AS dataId
		FROM dbo.tab_property
		INNER JOIN dbo.tab_propertyFacets
		ON dbo.tab_propertyFacets.propertyFacetId = 3
		INNER JOIN dbo.tab_propertyTypeFacets
		ON dbo.tab_property.typeOfProperty LIKE dbo.tab_propertyTypeFacets.propertyTypeFacetName + '%'
		*/
		-- Using child table dbo.tab_propertyTypeFacetsLookup
		SELECT dbo.tab_property.propertyId
		, 3 AS propertyFacetId
		, dbo.tab_propertyFacets.propertyFacetName
		, dbo.tab_propertyTypeFacetsLookup.propertyTypeFacetId AS facetId
		, dbo.tab_propertyTypeFacets.propertyTypeFacetName AS facetName
		, dbo.tab_propertyTypeFacetsLookup.propertyTypeFacetId AS facetName
		FROM dbo.tab_property
		INNER JOIN dbo.tab_propertyFacets
		ON dbo.tab_propertyFacets.propertyFacetId = 3
		LEFT OUTER JOIN dbo.tab_propertyTypeFacetsLookup
		ON dbo.tab_property.typeOfProperty LIKE dbo.tab_propertyTypeFacetsLookup.propertyType
		INNER JOIN dbo.tab_propertyTypeFacets
		ON dbo.tab_propertyTypeFacetsLookup.propertyTypeFacetId = dbo.tab_propertyTypeFacets.propertyTypeFacetId
		WHERE dbo.tab_propertyTypeFacetsLookup.propertyTypeFacetId IS NOT NULL
		)

	MERGE INTO dbo.tab_propertyFacts AS facts
	USING facts_CTE 
	ON facts_CTE.propertyId = facts.propertyId
		AND facts_CTE.propertyFacetId = facts.propertyFacetId
		AND facts_CTE.facetId = facts.facetId
		AND facts_CTE.dataId = facts.dataId

	-- changed data
	WHEN MATCHED AND
		(
		ISNULL(facts.propertyFacetName, '') <> ISNULL(facts_CTE.PropertyFacetName, '')
		AND
		ISNULL(facts.facetName, '') <> ISNULL(facts_CTE.facetName, '')
		)
		THEN
		UPDATE SET
			  facts.propertyFacetName = facts_CTE.PropertyFacetName
			, facts.facetName = facts_CTE.facetName

	-- new data
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
			(
			  propertyId
			, propertyFacetId
			, propertyFacetName
			, facetId
			, facetName
			, dataId
			)
		VALUES
			(
			  facts_CTE.propertyId
			, facts_CTE.propertyFacetId
			, facts_CTE.propertyFacetName
			, facts_CTE.FacetId
			, facts_CTE.FacetName
			, facts_CTE.dataId
			)

	-- deleted data
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE
	;

END
GO