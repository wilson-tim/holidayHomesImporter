--------------------------------------------------------------------------------------------
--	2014-01-24 MC
--	changeControl.proc_changeData_merge_photo_to_dbo
--  
--  updates dbo.tab_photo for newly uploaded change data
--	control table changeControl.tab_photo_change has records for 'INSERT', 'UPDATE' and 'DELETE'
--	data has been pre-uploaded to changeData.tab_photo to optimise the merge
--		
-- history
--	2014-01-16 created
--  2014-07-15 TW property record archiving feature
--------------------------------------------------------------------------------------------
CREATE PROCEDURE [changeControl].[proc_changeData_merge_photo_to_dbo]
AS
BEGIN

	-- temp table to capture changes for summary output
	DECLARE @tmp_photo_changed TABLE ([action] NVARCHAR(10) NOT NULL, photoId BIGINT NULL);

	MERGE INTO dbo.tab_photo AS photo
	USING (
		SELECT phc.[action], phc.photoId, phc.propertyId, ph.position, ph.url, ph.runId, pp.isActive
		FROM changeControl.tab_photo_change phc
		LEFT OUTER JOIN changeData.tab_photo ph
		ON ph.photoId = phc.photoId
		LEFT OUTER JOIN dbo.tab_property pp
		ON pp.propertyId = phc.propertyId
	) AS src ([action], photoId, propertyId, position, url, runId, isActive)
	ON src.photoId = photo.photoId

	WHEN NOT MATCHED BY TARGET AND src.[action] = 'INSERT' THEN INSERT (photoId, propertyId, position, url, runId)
	VALUES (src.photoId, src.propertyId, src.position, src.url, src.runId)

	WHEN MATCHED AND src.[action] = 'UPDATE' THEN UPDATE
	SET propertyId = src.propertyId
	, position = src.position
	, url = src.url
	, runId = src.runId

	-- Property archiving feature - only DELETE if the parent property record is currently active or is not physically present
	WHEN MATCHED AND src.[action] = 'DELETE' AND (src.isActive = 1 OR src.isActive IS NULL) THEN DELETE

	-- capture changes for logging output
	OUTPUT $action, ISNULL(INSERTED.photoId, DELETED.photoId)
	INTO @tmp_photo_changed ([action], photoId);

	IF NOT EXISTS (SELECT * FROM @tmp_photo_changed)
		SELECT messageContent = 'PROD dbo.tab_photo: no actions';
	ELSE
		-- return select statement of rows so can be logged
		SELECT messageContent = 'PROD dbo.tab_photo ' + [action] + ':' + LTRIM(STR(COUNT(photoId)))
		FROM @tmp_photo_changed
		GROUP BY [action];

END