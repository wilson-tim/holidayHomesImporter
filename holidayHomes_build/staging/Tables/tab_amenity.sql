CREATE TABLE [staging].[tab_amenity] (
    [amenityId]    BIGINT        IDENTITY (1, 1) NOT NULL,
    [amenityValue] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_staging_tab_amenity] PRIMARY KEY CLUSTERED ([amenityId] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX__staging_amenity_amenityValue]
    ON [staging].[tab_amenity]([amenityValue] ASC);

