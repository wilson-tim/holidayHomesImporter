-- =============================================
-- Author:	Tim Wilson
-- Create date: 12/06/2014
-- Description:	search for a property using keywords
--
-- Parameters
-- @searchCriteria     list of keywords, space delimited (required)
-- @typeOfProperty     type of property (optional)
-- @countryCode        country code, ISO 3166-1 alpha-2 (optional)
-- @localCurrencyCode  local currency code, ISO 4217 (optional)(default value 'GBP')
-- @sleeps             number of beds (optional)(default value 1)
-- @maxSleeps          maximum number of beds (optional)
-- @numberOfBedrooms   number of bedrooms (optional)
-- @sourceIds          list of partner ids, comma delimited (optional)
-- @minPrice           minimum rate in GBP (optional)(default value 1)
-- @maxPrice           maximum rate in GBP (optional)(default value 10000)
-- @Page INT           page number (required)
-- @RecsPerPage INT    number of records per page (required)
--
-- Result set
-- Property details ordered by descending rank
-- Where rank > 1000 then match is on text
-- Where rank <= 1000 then match is on soundex
--
-- History
--	2014-06-12 TW New
--  2014-07-08 TW Added additional parameters per dbo.propertySearch
--  2014-07-18 TW Added additional where condition for isActive flag
-- =============================================

CREATE PROCEDURE [dbo].[propertyKeywordSearch]
  @searchCriteria VARCHAR(8000)
, @typeOfProperty VARCHAR(15) = NULL
, @countryCode VARCHAR(2) = NULL
, @localCurrencyCode NVARCHAR(3) = 'GBP'
, @sleeps INT = 1
, @maxSleeps INT = NULL
, @numberOfBedrooms INT = NULL
, @sourceIds VARCHAR(200) = NULL
, @minPrice INT = 1
, @maxPrice INT = 10000
, @Page INT
, @RecsPerPage INT

AS

BEGIN

	SET NOCOUNT ON;

	DECLARE
		  @localRate FLOAT
		, @searchString VARCHAR(8000)
		, @searchStringSoundex VARCHAR(8000)
		, @sourceIdCount INT;

	SELECT @searchString = CONVERT(VARCHAR(8000), COALESCE(item, '') + ' ')
	FROM
		(
		SELECT 'FORMSOF(INFLECTIONAL, ' + split.Item + ') AND '
		FROM dbo.SplitString(@searchCriteria, ' ') AS split
		WHERE 2 < LEN(split.Item)
		FOR XML PATH('')
		) searchStringSelect (item)
	;
	SET @searchString = LEFT(@searchString, LEN(@searchString) - 4);

	SELECT @searchStringSoundex = CONVERT(VARCHAR(8000), COALESCE(item, '') + ' ')
	FROM
		(
		SELECT SOUNDEX(split.Item) + ' AND '
		FROM dbo.SplitString(@searchCriteria, ' ') AS split
		WHERE 2 < LEN(split.Item)
			AND '0000' <> SOUNDEX(split.Item)
		FOR XML PATH('')
		) searchStringSoundexSelect (item)
	;
	SET @searchStringSoundex = LEFT(@searchStringSoundex, LEN(@searchStringSoundex) - 4);

	IF @localCurrencyCode = '' OR @localCurrencyCode IS NULL
	BEGIN
		SET @localCurrencyCode = 'GBP';
	END

	IF @localCurrencyCode IS NOT NULL AND @localCurrencyCode <> ''
	BEGIN
		SELECT @localRate = rate
		FROM dbo.utils_currencyLookup
		WHERE id = 'GBP'
			AND localId = @localCurrencyCode;
	END
	ELSE
	BEGIN
		SET @localRate = 1;
	END

	SET @sleeps = ISNULL(@sleeps, 1);
 
	IF @sourceIds IS NULL OR @sourceIds = ''
	BEGIN
	SET @sourceIds = '';
	END 
 
	SET @sourceIdCount = LEN(@sourceIds) - LEN(REPLACE(@sourceIds, ',', ''));
	IF LEN(@sourceIds) > 0
	BEGIN
	SET @sourceIdCount = @sourceIdCount + 1;
	END

	IF @minPrice IS NOT NULL
	BEGIN
	SET @minPrice = (@minPrice / @localRate);
	END
	IF @maxPrice IS NOT NULL
	BEGIN
	SET @maxPrice = (@maxPrice / @localRate);
	END

	SELECT
		  totalCount = COUNT(1) OVER ()
		, p.name
		, p.[description]
		, p.latitude
		, p.longitude
		, p.propertyId
		, p.externalURL
		, p.numberOfProperBedrooms
		, p.maximumNumberOfPeople
		, p.averageRating
		, ISNULL(p.thumbnailUrl, pho.url) AS url
		, p.countryCode
		, p.cityName
		, p.sourceId
		, p.externalId
		, p.regionName
		, p.minimumPricePerNight
		, p.currencyCode
		, minimumPricePerNightLocal =
			CASE
				WHEN
					(
					p.minimumPricePerNight IS NULL
					OR
					ABS(p.minimumPricePerNight) = 0
					OR
					p.currencyCode IS NULL
					OR
					currency.rate IS NULL
					OR
					currency.rate = 0
					)
					THEN 0
				ELSE
					(p.minimumPricePerNight / currency.rate)
			END
		, resultsListIds.[rank]
		, '' AS [partner]
		, '' AS internalURL
		, '' AS urlSafeName
		, '' AS logoURL
		, '' AS partnerId
--		, keywords
--		, keywordsSoundex
	FROM dbo.tab_property p
	INNER JOIN
		(SELECT
			  propertyId
			, [rank]
			, rownum = ROW_NUMBER() OVER (PARTITION BY propertyId ORDER BY [RANK] DESC)
		FROM
			(
				-- Text search (with boosted rank value)
				SELECT
					  pk.propertyId
--					, pk.keywords
--					, pk.keywordsSoundex
					, ct.[RANK] * 1000
				FROM dbo.tab_propertyKeywords pk
				INNER JOIN CONTAINSTABLE(
					  dbo.tab_propertyKeywords
					, keywords
					, @searchString
					) ct
				ON ct.[KEY] = pk.propertyId

				UNION ALL

				-- Soundex search
				SELECT
					  pk.propertyId
--					, pk.keywords
--					, pk.keywordsSoundex
					, ct.[RANK]
				FROM dbo.tab_propertyKeywords pk
				INNER JOIN CONTAINSTABLE(
					  dbo.tab_propertyKeywords
					, keywordsSoundex
					, @searchStringSoundex
					) ct
				ON ct.[KEY] = pk.propertyId
			) resultsList (propertyId, [rank])
		) resultsListIds
	ON p.propertyId = resultsListIds.propertyId
		AND resultsListIds.rownum = 1

	LEFT OUTER JOIN dbo.utils_currencyLookup currency
	ON currency.id = p.currencyCode
		AND currency.localId = @localCurrencyCode

	OUTER APPLY (
		SELECT  TOP 1 dbo.tab_photo.url
		FROM    dbo.tab_photo
		WHERE   dbo.tab_photo.propertyId = p.propertyId
	) pho

	WHERE
		( @typeOfProperty IS NULL OR p.typeOfProperty = @typeOfProperty )
	AND ( @countryCode IS NULL OR p.countryCode = @countryCode )
	AND ( @sleeps IS NULL OR p.maximumNumberOfPeople >= @sleeps )
	AND ( @maxSleeps IS NULL OR p.maximumNumberOfPeople <= @maxSleeps )
	AND ( @numberOfBedrooms IS NULL OR P.numberOfProperBedrooms = @numberOfBedrooms )
	AND ( isActive = 1 )
	AND
	(
		@sourceIdCount = 0
		OR
		sourceId IN
		(
		SELECT split.Item FROM dbo.SplitString(@sourceIds, ',') AS split
		)
	)
	AND (
		(
		@minPrice IS NULL
		OR
		@maxPrice IS NULL
		OR
		minimumPricePerNight IS NULL
		OR
		ABS(minimumPricePerNight) = 0
		OR
		currencyCode IS NULL
		OR
		currency.rate IS NULL
		OR
		currency.rate = 0
		)
		OR
		(
		@minPrice <= (minimumPricePerNight / currency.rate)
		AND
		@maxPrice >= (minimumPricePerNight / currency.rate)
		)
	)

	ORDER BY [RANK] DESC, resultsListIds.propertyId ASC
	OFFSET (@RecsPerPage * (@Page - 1)) ROWS
	FETCH NEXT @RecsPerPage ROWS ONLY
	;

END

GO