-- simplest is
-- replace: empty

IF EXISTS (SELECT * FROM sys.synonyms WHERE name = 'tab_property') DROP SYNONYM dbo.tab_property;
GO
IF EXISTS (SELECT * FROM sys.synonyms WHERE name = 'tab_property2amenity') DROP SYNONYM dbo.tab_property2amenity;
GO
IF EXISTS (SELECT * FROM sys.synonyms WHERE name = 'tab_amenity') DROP SYNONYM dbo.tab_amenity;
GO
IF EXISTS (SELECT * FROM sys.synonyms WHERE name = 'tab_photo') DROP SYNONYM dbo.tab_photo;
GO
IF EXISTS (SELECT * FROM sys.synonyms WHERE name = 'tab_rate') DROP SYNONYM dbo.tab_rate;
GO

CREATE SYNONYM dbo.tab_property FOR holidayHomes_empty.dbo.tab_property;
GO
CREATE SYNONYM dbo.tab_property2amenity FOR holidayHomes_empty.dbo.tab_property2amenity;
GO
CREATE SYNONYM dbo.tab_amenity FOR holidayHomes_empty.dbo.tab_amenity;
GO
CREATE SYNONYM dbo.tab_photo FOR holidayHomes_empty.dbo.tab_photo;
GO
CREATE SYNONYM dbo.tab_rate FOR holidayHomes_empty.dbo.tab_rate;
GO

