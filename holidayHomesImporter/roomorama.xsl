<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml"/>

<!--
	26/02/2014  TW  New XSL file for Roomorama data import
-->
	
<!-- Copy every line as is, except where it matches the conditions below -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="room/images/image/image">
<!-- Rename the inner image node -->	
        <imageUrl><xsl:apply-templates select="@*|node()" /></imageUrl>
    </xsl:template>

    <xsl:template match="room/conditions">
<!-- Copy the contents of the conditions node -->	
		<xsl:apply-templates select="@*|node()"/>
    </xsl:template>

    <xsl:template match="room/host">
<!-- Ignore the host node -->
	  <xsl:apply-templates/>
    </xsl:template>
<!-- Extract and rename the contents of the host node -->
    <xsl:template match="room/host/id">
	  	  <hostId><xsl:apply-templates select="@*|node()" /></hostId>
    </xsl:template>
    <xsl:template match="room/host/display">
	  	  <hostDisplay><xsl:apply-templates select="@*|node()" /></hostDisplay>
    </xsl:template>
    <xsl:template match="room/host/certified">
	  	  <hostCertified><xsl:apply-templates select="@*|node()" /></hostCertified>
    </xsl:template>
    <xsl:template match="room/host/url">
	  	  <hostUrl><xsl:apply-templates select="@*|node()" /></hostUrl>
    </xsl:template>

	<xsl:template match="room/services">
<!-- Ignore the services node -->
	  <xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="room/services/cleaning">
<!-- Ignore the cleaning node -->
	  <xsl:apply-templates/>
	</xsl:template>
<!-- Extract and rename the contents of the cleaning node -->
	<xsl:template match="room/services/cleaning/available">
			<cleaningAvailable><xsl:apply-templates select="@*|node()" /></cleaningAvailable>
	</xsl:template>
	<xsl:template match="room/services/cleaning/rate">
			<cleaningRate><xsl:apply-templates select="@*|node()" /></cleaningRate>
	</xsl:template>
	<xsl:template match="room/services/cleaning/required">
			<cleaningRequired><xsl:apply-templates select="@*|node()" /></cleaningRequired>
	</xsl:template>

	<xsl:template match="room/services/airport-pickup">
<!-- Ignore the airport-pickup node -->
	  <xsl:apply-templates/>
	</xsl:template>
<!-- Extract and rename the contents of the airport-pickup node -->
	<xsl:template match="room/services/airport-pickup/available">
			<airport-pickupAvailable><xsl:apply-templates select="@*|node()" /></airport-pickupAvailable>
	</xsl:template>
	<xsl:template match="room/services/airport-pickup/rate">
			<airport-pickupRate><xsl:apply-templates select="@*|node()" /></airport-pickupRate>
	</xsl:template>

	<xsl:template match="room/services/car-rental">
<!-- Ignore the car-rental node -->
	  <xsl:apply-templates/>
	</xsl:template>
<!-- Extract and rename the contents of the car-rental node -->
	<xsl:template match="room/services/car-rental/available">
			<car-rentalAvailable><xsl:apply-templates select="@*|node()" /></car-rentalAvailable>
	</xsl:template>
	<xsl:template match="room/services/car-rental/rate">
			<car-rentalRate><xsl:apply-templates select="@*|node()" /></car-rentalRate>
	</xsl:template>

	<xsl:template match="room/services/concierge">
<!-- Ignore the concierge node -->
	  <xsl:apply-templates/>
	</xsl:template>
<!-- Extract and rename the contents of the concierge node -->
	<xsl:template match="room/services/concierge/available">
			<conciergeAvailable><xsl:apply-templates select="@*|node()" /></conciergeAvailable>
	</xsl:template>
	<xsl:template match="room/services/concierge/rate">
			<conciergeRate><xsl:apply-templates select="@*|node()" /></conciergeRate>
	</xsl:template>

</xsl:stylesheet>