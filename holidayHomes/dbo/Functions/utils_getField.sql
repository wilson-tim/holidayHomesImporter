CREATE FUNCTION dbo.utils_getField
(
	@rowdata varchar(500),
	@delim varchar(5),
	@fieldno integer
)  
RETURNS varchar(500)
AS  
BEGIN 
    DECLARE @ctr int,
	        @result varchar(500),
			@data varchar(500);

	/* Preserve any space characters, they might be delimiters
	SET @rowdata = LTRIM(RTRIM(@rowdata));
	*/
	SET @delim   = UPPER(LTRIM(RTRIM(@delim)));
	IF @delim = '\S'
	BEGIN
		SET @delim = ' ';
	END
	
    SET @ctr = 1;
    SET @result = '';

    WHILE (CHARINDEX(@delim, @rowdata)>0) AND @ctr <= @fieldno
    BEGIN
        SET @data = LTRIM(RTRIM(SUBSTRING(@rowdata, 1, CHARINDEX(@delim, @rowdata) - 1)));

        SET @rowdata = SUBSTRING(@rowdata, CHARINDEX(@delim, @rowdata) + LEN(@delim), LEN(@rowdata));
		IF @ctr = @fieldno
		BEGIN
			SET @result = @data;
		END
		SET @ctr = @ctr + 1;
    END
	
    SET @data = LTRIM(RTRIM(@rowdata));
	IF @ctr = @fieldno
	BEGIN
		SET @result = @data;
	END

	RETURN @result;
END