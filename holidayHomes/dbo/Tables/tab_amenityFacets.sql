CREATE TABLE [dbo].[tab_amenityFacets](
	[amenityFacetId] [int] NOT NULL,
	[amenityFacetName] [nvarchar](50) NOT NULL,
	[amenitySpecial] [bit] NULL,
 CONSTRAINT [PK_tab_amenityFacets] PRIMARY KEY NONCLUSTERED 
(
	[amenityFacetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
