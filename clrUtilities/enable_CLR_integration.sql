-- 03/03/2014 TW Enable CLR integration in MS SQL Server

sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'clr enabled', 1;
GO
RECONFIGURE;
GO
