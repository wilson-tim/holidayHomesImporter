CREATE FUNCTION dbo.func_getLatLongDistance
(
	@sourceLat float
	, @sourceLong float
	, @targetLat float
	, @targetLong float
	, @imperial bit = 0
)
RETURNS decimal(28,4)
AS
BEGIN
	
	DECLARE @result decimal(28,4)
		, @source geography
		, @target geography
		, @temp varchar(100);
	
	IF @sourceLat IS NULL
		OR @sourceLong IS NULL
		OR @targetLat IS NULL
		OR @targetLong IS NULL
	BEGIN
		SET @result = -1;
	END
	ELSE
	BEGIN
		SET @temp= 'POINT(' + convert(varchar(100), @sourceLong) + ' ' +  convert(varchar(100), @sourceLat) +')';
		SET @source = geography::STGeomFromText(@temp, 4326);

		SET @temp= 'POINT(' + convert(varchar(100), @targetLong) + ' ' +  convert(varchar(100), @targetLat) +')';
		SET @target = geography::STGeomFromText(@temp, 4326);
		
		IF @imperial = 1
		BEGIN
			-- Distance in miles
			SET @result = @source.STDistance(@target)/1609.344;
		END
		ELSE
		BEGIN
			-- Distance in kilometres
			SET @result = @source.STDistance(@target)/1000;
		END
	END

	RETURN (@result);

END