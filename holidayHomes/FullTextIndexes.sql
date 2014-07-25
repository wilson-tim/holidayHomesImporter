CREATE FULLTEXT INDEX ON [dbo].[tab_propertyKeywords]
    ([keywords] LANGUAGE 1033, [keywordsSoundex] LANGUAGE 1033)
    KEY INDEX [PK_tab_propertyKeywords_propertyId]
    ON [holidayHomesFullTextCatalog]
    WITH CHANGE_TRACKING MANUAL;

