CREATE TABLE [dbo].[tab_propertyKeywords] (
    [propertyId]      BIGINT         NOT NULL,
    [keywords]        NVARCHAR (MAX) NULL,
    [keywordsSoundex] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_tab_propertyKeywords_propertyId] PRIMARY KEY CLUSTERED ([propertyId] ASC)
);




