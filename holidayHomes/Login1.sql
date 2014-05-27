CREATE LOGIN cands WITH PASSWORD = 'CompareAndShare2014';
GO
EXEC sp_addsrvrolemember 'cands', 'serveradmin';

