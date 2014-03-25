 --------------------------------------------------------------------------------------------
--	2013-12-16 MC
--	waytostay.proc_concatenateFloors
--  
--  multiple floors can be supplied for a single apartment feed (feed can contain number_of_apartments > 1 on different floors)
--		so this proc concatenates them using a recursive CTE
--	
--	2014-01-17 MC recursive CTE was very slow, so split into single entry insert and multi-entry resursive CTE
--------------------------------------------------------------------------------------------
CREATE PROCEDURE [waytostay].[proc_concatenateFloors]
  @runId INT
, @fileId INT
AS
BEGIN

	-- The recursive CTE is expensive, so count floors, do simple insert then restrict CTE concat
	DECLARE @tmp_floorCount TABLE 
	( sourceId INT
	, runId INT
	, fileId INT
	, basic_information_id INT
	, floors_id INT
	, floorCount INT
	);

	INSERT @tmp_floorCount ( sourceId, runId, fileId, basic_information_id, floors_id, floorCount )
	SELECT bi2f.sourceId
	, bi2f.runId
	, bi2f.fileId
	, bi2f.basic_information_id
	, bi2f.floors_id
	, floorCount = count(f.floors_id) 
		FROM waytostay.imp_floors bi2f  
		LEFT OUTER JOIN waytostay.imp_floor f
			ON f.runId = bi2f.runId
			AND f.fileId = bi2f.fileId
			AND f.floors_id = bi2f.floors_id
		WHERE bi2f.runId = @runId
		AND bi2f.fileId = @fileId
		GROUP BY bi2f.sourceId, bi2f.runId, bi2f.fileId, bi2f.basic_information_id, bi2f.floors_id;


	-- insert the single floor entries first
	INSERT waytostay.imp_concatfloors ( sourceId, runId, fileId, basic_information_id, concatfloors)
	SELECT f.sourceId, f.runId, f.fileId, fc.basic_information_id, f.[floor]
	FROM @tmp_floorCount fc
	INNER JOIN waytostay.imp_floor f
		ON f.runId = fc.runId
		AND f.fileId = fc.fileId
		AND f.floors_id = fc.floors_id
	WHERE fc.floorCount = 1


	;WITH partitioned AS
	(
		SELECT fc.sourceId, fc.runId, fc.fileId, fc.basic_information_id, f.[floor]
		, ROW_NUMBER() OVER (PARTITION BY fc.basic_information_id, fc.fileId ORDER BY f.[floor]) AS iteration
		, COUNT(*) OVER (PARTITION BY fc.basic_information_id, fc.fileId) AS maxRow
		FROM @tmp_floorCount fc
		INNER JOIN waytostay.imp_floor f
			ON f.runId = fc.runId
			AND f.fileId = fc.fileId
			AND f.floors_id = fc.floors_id
		WHERE fc.runId = @runId
		AND fc.fileId = @fileId
		AND fc.floorCount > 1
	),
	concatenated AS
	(
		SELECT sourceId, runId, fileId, basic_information_id, CAST([floor] AS NVARCHAR(255)) AS concatFloors, [floor], iteration, maxRow 
		FROM partitioned WHERE iteration = 1

		UNION ALL

		SELECT 
			p.sourceId, p.runId, p.fileId, p.basic_information_id, CAST(c.concatFloors + ', ' + p.[floor] AS NVARCHAR(255)), p.[floor], p.iteration, p.maxRow
		FROM partitioned AS p
			INNER JOIN concatenated AS c 
				ON c.runId = p.runId
				AND c.fileId = p.fileId
				AND c.basic_information_id = p.basic_information_id
				AND p.iteration = c.iteration + 1
	)
	INSERT waytostay.imp_concatfloors ( sourceId, runId, fileId, basic_information_id, concatfloors)
	SELECT sourceId, runId, fileId, basic_information_id, concatFloors
	FROM concatenated
	WHERE iteration = maxRow
	OPTION (MAXRECURSION 5000);

END
