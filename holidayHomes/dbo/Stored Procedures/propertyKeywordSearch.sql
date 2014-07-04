-- =============================================
-- Author:	Tim Wilson
-- Create date: 12/06/2014
-- Description:	search for a property using keywords
--
-- History
--	2014-06-12 TW New
-- =============================================

CREATE PROCEDURE [dbo].[propertyKeywordSearch]
  @keywords VARCHAR(8000) = NULL
, @sourceId INT = NULL
, @localCurrencyCode NVARCHAR(3) = 'GBP'
, @Page int
, @RecsPerPage int

AS

BEGIN

	SET NOCOUNT ON;

	DECLARE
		  @localRate FLOAT
		, @searchString VARCHAR(8000)
		, @searchStringSoundex VARCHAR(8000);

	SELECT @searchString = CONVERT(VARCHAR(8000), COALESCE(item, '') + ' ')
	FROM
		(
		SELECT 'FORMSOF(INFLECTIONAL, ' + split.Item + ') AND '
		FROM dbo.SplitString(@keywords, ' ') AS split
		WHERE 2 < LEN(split.Item)
		FOR XML PATH('')
		) searchStringSelect (item)
	;
	SET @searchString = LEFT(@searchString, LEN(@searchString) - 4);

	SELECT @searchStringSoundex = CONVERT(VARCHAR(8000), COALESCE(item, '') + ' ')
	FROM
		(
		SELECT SOUNDEX(split.Item) + ' AND '
		FROM dbo.SplitString(@keywords, ' ') AS split
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

	SELECT
		  p.name
		, p.[description]
		, p.latitude
		, p.longitude
		, p.externalURL
		, p.numberOfProperBedrooms
		, p.maximumNumberOfPeople
		, p.averageRating
		, ISNULL(p.thumbnailUrl, pho.url) AS thumbnailUrl
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
		(
		(p.sourceId = @sourceId AND @sourceId IS NOT NULL AND @sourceId <> '')
		OR
		(@sourceId IS NULL OR @sourceId = '')
		)

	ORDER BY [RANK] DESC, resultsListIds.propertyId ASC
	OFFSET (@RecsPerPage * (@Page - 1)) ROWS
	FETCH NEXT @RecsPerPage ROWS ONLY
	;

END

GO