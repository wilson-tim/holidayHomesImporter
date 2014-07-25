--------------------------------------------------------------------------------------------
--	2014-01-24 MC
--	changeControl.proc_changeData_merge_property2amenity_to_dbo
--  
--  updates dbo.tab_property2amenity for newly uploaded change data
--	control table changeControl.tab_property2amenity_change has records for 'INSERT', 'UPDATE' and 'DELETE'
--	data has been pre-uploaded to changeData.tab_property2amenity to optimise the merge
--		
--	notes
--		could simply use control table as has all columns, 
--			but joining data table for consistency and in case want to add columns to p2a in future...
--
-- history
--	2014-01-16 created
--  2014-07-15 TW property record archiving feature
--------------------------------------------------------------------------------------------
CREATE PROCEDURE [changeControl].[proc_changeData_merge_property2amenity_to_dbo]
AS
BEGIN

	-- temp table to capture changes for summary output
	DECLARE @tmp_property2amenity_changed TABLE ([action] NVARCHAR(10) NOT NULL, propertyId BIGINT NULL, amenityId BIGINT NULL);

	MERGE INTO dbo.tab_property2amenity AS p2a
	USING (
		SELECT p2ac.[action], p2ac.propertyId, p2ac.amenityId, p2a.runId, pp.isActive
		FROM changeControl.tab_property2amenity_change p2ac
		LEFT OUTER JOIN changeData.tab_property2amenity p2a
		ON p2a.propertyId = p2ac.propertyId
		AND p2a.amenityId= p2ac.amenityId
		LEFT OUTER JOIN dbo.tab_property pp
		ON pp.propertyId = p2ac.propertyId
	) AS src ([action], propertyId, amenityId, runId, isActive)
	ON src.propertyId = p2a.propertyId
	AND src.amenityId = p2a.amenityId

	WHEN NOT MATCHED BY TARGET  AND src.[action] = 'INSERT' THEN INSERT (propertyId, amenityId, runId)
	VALUES (src.propertyId, src.amenityId, src.runId)

	WHEN MATCHED AND src.[action] = 'UPDATE' THEN UPDATE
	SET runId = src.runId

	-- Property archiving feature - only DELETE if the parent property record is currently active or is not physically present
	WHEN MATCHED AND src.[action] = 'DELETE' AND (src.isActive = 1 OR src.isActive IS NULL) THEN DELETE

	OUTPUT $action, ISNULL(INSERTED.propertyId, DELETED.propertyId), ISNULL(INSERTED.amenityId, DELETED.amenityId)
	INTO @tmp_property2amenity_changed ([action], propertyId, amenityId);

	IF NOT EXISTS (SELECT * FROM @tmp_property2amenity_changed)
		SELECT messageContent = 'PROD dbo.tab_property2amenity: no actions';
	ELSE
		-- return select statement of rows so can be logged
		SELECT messageContent = 'PROD dbo.tab_property2amenity ' + [action] + ':' + LTRIM(STR(COUNT(propertyId)))
		FROM @tmp_property2amenity_changed
		GROUP BY [action];

END