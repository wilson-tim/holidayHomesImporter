CREATE TABLE [holidayHomes].[tab_amenity] (
    [amenityId]    BIGINT        NOT NULL,
    [amenityValue] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_amenity] PRIMARY KEY CLUSTERED ([amenityId] ASC)
);

