﻿CREATE TABLE [holidayHomes].[tab_property_changedPhotos]
(
	[propertyId] BIGINT NOT NULL , 
    [action] NVARCHAR(10) NOT NULL, 
    [sourceId] INT NOT NULL, 
    [externalId] NVARCHAR(100) NOT NULL, 
    CONSTRAINT [PK_tab_property_changedPhotos] PRIMARY KEY CLUSTERED ([propertyId] ASC, [action] ASC)
)
