
CREATE PROCEDURE [dbo].[proc_db_tableusage]
  @nameFilter sysname = null
AS
/*
 * notes: sp_spaceused truncates tablename to 20 chars, hence inclusion of cursor var in insert
 * 
*/
set nocount on

declare   @tablename varchar (255)
	, @lastID int

create table #tmp_tableInfo 
	( tableInfoID int not null identity
	, TableName 	varchar (255)
	, NumRows	int
	, ReservedSpace	varchar (20)
	, DataSpace	varchar (20)
	, IndexSize	varchar (20)
	, UnusedSpace	varchar (20)
	)

declare Curs cursor fast_forward
for
select TABLE_SCHEMA + '.' + TABLE_NAME from INFORMATION_SCHEMA.TABLES where TABLE_TYPE = 'BASE TABLE'
and (@nameFilter is null or TABLE_NAME like '%'+@nameFilter+'%')

OPEN Curs
FETCH Curs INTO	@tablename

WHILE @@FETCH_STATUS = 0
BEGIN
	insert #tmp_tableInfo 
		( TableName
		, NumRows
		, ReservedSpace
		, DataSpace
		, IndexSize
		, UnusedSpace
		)
	exec sp_spaceused @tablename

	select @lastID = max(tableInfoID) from #tmp_tableInfo

	update #tmp_tableInfo set TableName = @tablename where tableInfoID = @lastID
	
	FETCH Curs INTO	@tablename
END
CLOSE Curs

DEALLOCATE Curs

set nocount off

select	  TableName
	, NumRows
	, ReservedSpace = convert(int, left(ReservedSpace, len(ReservedSpace) - 3))
	, DataSpace = convert(int, left(DataSpace, len(DataSpace) - 3))
	, IndexSize = convert(int, left(IndexSize, len(IndexSize) - 3))
	, UnusedSpace = convert(int, left(UnusedSpace, len(UnusedSpace) - 3))
from #tmp_tableInfo
order by len(ReservedSpace) desc, ReservedSpace desc

drop table #tmp_tableInfo