--------------------------------------------------------------------------------------------
--	2014-01-24 MC
--	changeControl.proc_changeData_merge_rate_to_dbo
--  
--  updates dbo.tab_rate for newly uploaded change data
--	control table changeControl.tab_rate_change has records for 'INSERT', 'UPDATE' and 'DELETE'
--	data has been pre-uploaded to changeData.tab_rate to optimise the merge
--		
-- history
--	2014-01-16 created
--  2014-07-15 TW property record archiving feature
--------------------------------------------------------------------------------------------
CREATE PROCEDURE [changeControl].[proc_changeData_merge_rate_to_dbo]
AS
BEGIN
	-- temp table to capture changes for summary output
	DECLARE @tmp_rate_changed TABLE ([action] NVARCHAR(10) NOT NULL, rateId BIGINT NULL);


	MERGE INTO dbo.tab_rate AS rate
	USING (
		SELECT rc.[action], rc.rateId, rc.propertyId, r.periodType, r.[from], r.[to], r.currencyCode, r.runId, pp.isActive
		FROM changeControl.tab_rate_change rc
		LEFT OUTER JOIN changeData.tab_rate r
		ON r.rateId = rc.rateId
		LEFT OUTER JOIN dbo.tab_property pp
		ON pp.propertyId = rc.propertyId
	) AS src ([action], rateId, propertyId, periodType, [from], [to], currencyCode, runId, isActive)
	ON src.rateId = rate.rateId

	WHEN NOT MATCHED BY TARGET AND src.[action] = 'INSERT' THEN INSERT (rateId, propertyId, periodType, [from], [to], currencyCode, runId)
	VALUES (src.rateId, src.propertyId, src.periodType, src.[from], src.[to], src.currencyCode, src.runId)

	WHEN MATCHED AND src.[action] = 'UPDATE' THEN UPDATE
	SET propertyId = src.propertyId
	, periodType = src.periodType
	, [from] = src.[from]
	, [to] = src.[to]
	, currencyCode = src.currencyCode
	, runId = src.runId

	-- Property archiving feature - only DELETE if the parent property record is currently active
	WHEN MATCHED AND src.[action] = 'DELETE' AND src.isActive = 1 THEN DELETE

	-- capture changes for logging output
	OUTPUT $action, ISNULL(INSERTED.rateId, DELETED.rateId)
	INTO @tmp_rate_changed ([action], rateId);

	IF NOT EXISTS (SELECT * FROM @tmp_rate_changed)
		SELECT messageContent = 'PROD dbo.tab_rate: no actions';
	ELSE
		-- return select statement of rows so can be logged
		SELECT messageContent = 'PROD dbo.tab_rate ' + [action] + ':' + LTRIM(STR(COUNT(rateId)))
		FROM @tmp_rate_changed
		GROUP BY [action];

END