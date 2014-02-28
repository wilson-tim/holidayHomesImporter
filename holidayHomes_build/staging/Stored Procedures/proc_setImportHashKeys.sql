 --------------------------------------------------------------------------------------------
--	2013-12-14 MC
--	staging.proc_setImportHashKeys
--  
--  Calculates hash keys and checksums for the imported data to speed up and simplify comparisons
--	Replacing NULLs with zeros to simplify matching further
--
-- notes
--	A good article explaining the below code here: http://www.bidn.com/blogs/TomLannen/bidn-blog/2265/using-hashbytes-to-compare-columns
--------------------------------------------------------------------------------------------
CREATE PROCEDURE staging.proc_setImportHashKeys
  @runId INT
AS
BEGIN

	-- hasbytes calculated column for ease of detecting row changes
	UPDATE staging.tab_property 
	SET propertyHashKey = HASHBYTES ('MD5'
	, ISNULL(thumbnailUrl, 'NA') + '|'
	+ ISNULL(externalURL, 'NA') + '|'
	+ ISNULL([description], 'NA') + '|'
	+ ISNULL(name, 'NA') + '|'
	+ ISNULL(regionName, 'NA') + '|'
	+ ISNULL(typeOfProperty, 'NA') + '|'
	+ ISNULL(postcode, 'NA') + '|'
	+ ISNULL(CAST(regionId AS NVARCHAR), 'NA') + '|'
	+ ISNULL(CAST(cityId AS NVARCHAR), 'NA') + '|'
	+ ISNULL(cityName, 'NA') + '|'
	+ ISNULL(stateName, 'NA') + '|'
	+ ISNULL(countryCode, 'NA') + '|'
	+ ISNULL(CAST(latitude AS NVARCHAR), 'NA') + '|'
	+ ISNULL(CAST(longitude AS NVARCHAR), 'NA') + '|'
	+ ISNULL(CAST(checkInFrom AS NVARCHAR), 'NA') + '|'
	+ ISNULL(CAST(checkOutBefore AS NVARCHAR), 'NA') + '|'
	+ ISNULL(CAST(sizeOfSpaceInSqm AS NVARCHAR), 'NA') + '|'
	+ ISNULL(CAST(sizeOfSpaceInSqft AS NVARCHAR), 'NA') + '|'
	+ ISNULL(cancellationPolicy, 'NA') + '|'
	+ ISNULL(CAST(minimumPricePerNight AS NVARCHAR), 'NA') + '|'
	+ ISNULL(currencyCode, 'NA') + '|'
	+ ISNULL(CAST(numberOfProperBedrooms AS NVARCHAR), 'NA') + '|'
	+ ISNULL(CAST(numberOfBathrooms AS NVARCHAR), 'NA') + '|'
	+ ISNULL([floor], 'NA') + '|'
	+ ISNULL(CAST(reviewsCount AS NVARCHAR), 'NA') + '|'
	+ ISNULL(CAST(averageRating AS NVARCHAR), 'NA') + '|'
	+ ISNULL(CAST(maximumNumberOfPeople AS NVARCHAR), 'NA') + '|'
	+ ISNULL(CAST(numberOfOtherRoomsWhereGuestsCanSleep AS NVARCHAR), 'NA') + '|'
	+ ISNULL(CAST(minimumDaysOfStay AS NVARCHAR), 'NA')
	);

	--aggregate checksum for the amenities
	UPDATE p
	SET amenitiesChecksum = ISNULL(agg.amenitiesChecksum, 0)
	FROM staging.tab_property p
	LEFT OUTER JOIN (
		SELECT sourceId, externalId
		, amenitiesChecksum = ISNULL(CAST(CHECKSUM_AGG(CHECKSUM(ISNULL(amenityId, 0))) AS BIGINT), 0)
		FROM staging.tab_property2amenity p2a
		GROUP BY sourceId, externalId
	) agg
	ON agg.sourceId = p.sourceId
	AND agg.externalId = p.externalId;

	--aggregate checksum for the photos
	UPDATE p
	SET photosChecksum = ISNULL(agg.photosChecksum, 0)
	FROM staging.tab_property p
	LEFT OUTER JOIN (
		SELECT sourceId, externalId
		, photosChecksum = ISNULL(CAST(CHECKSUM_AGG(ISNULL(position, -1)) AS BIGINT), 0)
							+ ISNULL(CAST(CHECKSUM_AGG(CHECKSUM(ISNULL(url, 'NA'))) AS BIGINT), 0)
		FROM staging.tab_photo
		GROUP BY sourceId, externalId
	) agg
	ON agg.sourceId = p.sourceId
	AND agg.externalId = p.externalId;

	--aggregate checksum for the rates
	UPDATE p
	SET ratesChecksum = ISNULL(agg.ratesChecksum, 0)
	FROM staging.tab_property p
	LEFT OUTER JOIN (
		SELECT sourceId, externalId
		, ratesChecksum = ISNULL(CAST(CHECKSUM_AGG(CHECKSUM(ISNULL(periodType, 'NA'))) AS BIGINT), 0)
							+ ISNULL(CAST(CHECKSUM_AGG(CHECKSUM(ISNULL([from], 0))) AS BIGINT), 0)
							+ ISNULL(CAST(CHECKSUM_AGG(CHECKSUM(ISNULL([to], 0))) AS BIGINT), 0)
							+ ISNULL(CAST(CHECKSUM_AGG(CHECKSUM(ISNULL(currencyCode, 'NA'))) AS BIGINT), 0)
		FROM staging.tab_rate
		GROUP BY sourceId, externalId
	) agg
	ON agg.sourceId = p.sourceId
	AND agg.externalId = p.externalId;

END

