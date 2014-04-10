CREATE TABLE [dbo].[tab_propertyFacts](
	[propertyId] [bigint] NOT NULL,
	[propertyFacetId] [int] NOT NULL,
	[propertyFacetName] [nvarchar](50) NOT NULL,
	[facetId] [int] NOT NULL,
	[facetName] [nvarchar](50) NOT NULL,
	[dataId] [bigint] NOT NULL,
 CONSTRAINT [PK_tab_propertyFacts] PRIMARY KEY CLUSTERED 
(
	[propertyId] ASC,
	[propertyFacetId] ASC,
	[facetId] ASC,
	[dataId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO