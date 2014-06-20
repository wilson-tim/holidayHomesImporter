-----------------------------------------------------------------------------------------------------
-- import.proc_registerFile
--	Retrieves or creates a tab_file entry for a given sourceId, fullPath
--
-- Returns: @fileId as both recordset and return value
--
-- 2012-05-21 MJC v01 created
-----------------------------------------------------------------------------------------------------
CREATE PROCEDURE import.proc_registerFile
  @sourceId int
, @fullPath varchar(800)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @fileId int
	DECLARE @fileName varchar(255)

	SELECT @fileId = fileId FROM import.tab_file WHERE sourceId = @sourceId AND fullPath = @fullPath

	IF @fileId IS NULL 
	BEGIN
		SET @fileName = substring(@fullPath, len(@fullPath) - charindex('\', reverse(@fullPath)) + 2, len(@fullPath))
		
		INSERT import.tab_file (sourceId, fullPath, [fileName]) VALUES (@sourceId, @fullPath, @fileName)

		SET @fileId = scope_identity()
	END
	ELSE
	BEGIN
		UPDATE import.tab_file
		SET lastAccessedDate = GETDATE()
		WHERE fileId = @fileId
	END

	SET NOCOUNT OFF

	SELECT @fileId as fileId

	RETURN @fileId
END
