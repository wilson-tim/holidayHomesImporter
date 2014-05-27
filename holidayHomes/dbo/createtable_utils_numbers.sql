-- ================================================
-- Author:		Tim Wilson
-- Create date: 20/02/2013
-- Description:	(Re)-create the utils_numbers table
-- ================================================

-- Drop the utils_numbers table if it already exists
IF OBJECT_ID('utils_numbers', N'U') IS NOT NULL
BEGIN
	DROP TABLE utils_numbers;
END

GO

-- Define CTE expression names and columns
WITH
	E00(number) AS (SELECT 1 UNION ALL SELECT 1),
	E02(number) AS (SELECT 1 FROM E00 a, E00 b),
	E04(number) AS (SELECT 1 FROM E02 a, E02 b),
	E08(number) AS (SELECT 1 FROM E04 a, E04 b),
	E16(number) AS (SELECT 1 FROM E08 a, E08 b),
	E32(number) AS (SELECT 1 FROM E16 a, E16 b),
	cteNumbers(number) AS (SELECT ROW_NUMBER() OVER (ORDER BY number) FROM E32)

	-- Outer query to populate the utils_numbers table
	SELECT number
	INTO utils_numbers
	FROM cteNumbers
	WHERE number <= 1000000;

--	SELECT COUNT(*) FROM utils_numbers;

GO
