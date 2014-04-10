CREATE TABLE [dbo].[tab_amenityFacetsLookup](
	[amenityId] [bigint] NOT NULL,
	[amenityFacetId] [int] NOT NULL,
 CONSTRAINT [PK_tab_amenityFacetsLookup] PRIMARY KEY CLUSTERED 
(
	[amenityId] ASC,
	[amenityFacetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
