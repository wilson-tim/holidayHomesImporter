--------------------------------------------------------------------------------------------
--	2014-01-24 MC
--	changeControl.proc_changeData_merge_amenity_to_dbo
--  
--  updates dbo.amenity for newly uploaded change data
--	control tables changeControl.tab_amenity_change has records for 'INSERT', 'UPDATE' and 'DELETE'
--	data has been pre-uploaded to changeData.tab_amenity to optimise the merge
--		
-- history
--	2014-01-16 created
--------------------------------------------------------------------------------------------
CREATE PROCEDURE [changeControl].[proc_changeData_merge_amenity_to_dbo]
AS
BEGIN

	-- temp table to capture changes for summary output
	DECLARE @tmp_amenity_changed TABLE ([action] NVARCHAR(10) NOT NULL, amenityId BIGINT NULL);

	-- there shouldn't be any deletes, but we'll script it up just in case there's a future need
	--using merge instead of simple insert to to capture output into change table
	MERGE INTO dbo.tab_amenity AS am
	USING (
		SELECT ac.[action], ac.amenityId, a.amenityValue
		FROM changeControl.tab_amenity_change ac
		LEFT OUTER JOIN changeData.tab_amenity a
		ON a.amenityId = ac.amenityId
	) AS src ([action], amenityId, amenityValue)
	ON src.amenityId = am.amenityId

	WHEN NOT MATCHED BY TARGET AND src.[action] = 'INSERT' THEN INSERT (amenityId, amenityValue)
	VALUES (src.amenityId, src.amenityValue)

	WHEN MATCHED AND src.[action] = 'UPDATE' THEN UPDATE
	SET amenityValue = src.amenityValue

	WHEN MATCHED AND src.[action] = 'DELETE' THEN DELETE

	-- capture changes for logging output
	OUTPUT $action, ISNULL(INSERTED.amenityId, DELETED.amenityId)
	INTO @tmp_amenity_changed ([action], amenityId);

	IF NOT EXISTS (SELECT * FROM @tmp_amenity_changed)
		SELECT messageContent = 'PROD dbo.tab_amenity: no actions';
	ELSE
		-- return select statement of rows so can be logged
		SELECT messageContent = 'PROD dbo.tab_amenity ' + [action] + ':' + LTRIM(STR(COUNT(amenityId)))
		FROM @tmp_amenity_changed
		GROUP BY [action];
END