<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="no" />
	<!-- Remove whitespace (default) -->
	<xsl:strip-space elements="*"/>

<!--
	04/03/2014  TW  New XSL file for FlipKey data import
	                Correcting XML record structure inconsistency
	05/03/2014  TW  Sort out duplicate naming of property_calendar nodes
	31/03/2014  MC  removed <?xml declaration as was causing error
	12/05/2014  TW  Transform only the data required for importing
	                and ignore the rest
					(to reduce the checking and testing workload)
	13/05/2014  TW  New elements handicap_adapted, elder_elevator, children_over_five
	29/05/2014  TW  Remove whitespace, remove 'type' attribute from all elements
	25/10/2014  TW  Additional replacements to transform revised photo schema elements back to original naming
	17/05/2015  TW  property_attributes/score not importing reliably, and data not used ultimately, so replace data with 0.00
-->
	
<!-- Copy every line as is, except where it matches the conditions below -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="property_data/property/property_details">
<!-- Ignore the property_details node -->
	  <xsl:apply-templates/>
    </xsl:template>
<!-- Extract and rename the contents of the property_details node -->
    <xsl:template match="property_data/property/property_details/handicap_adapted">
	  	  <detailsHandicap_adapted><xsl:apply-templates select="@*|node()" /></detailsHandicap_adapted>
    </xsl:template>
    <xsl:template match="property_data/property/property_details/elder_elevator">
	  	  <detailsElder_elevator><xsl:apply-templates select="@*|node()" /></detailsElder_elevator>
    </xsl:template>
    <xsl:template match="property_data/property/property_details/children_over_five">
	  	  <detailsChildren_over_five><xsl:apply-templates select="@*|node()" /></detailsChildren_over_five>
    </xsl:template>
    <xsl:template match="property_data/property/property_details/check_in">
	  	  <detailsCheck_in><xsl:apply-templates select="@*|node()" /></detailsCheck_in>
    </xsl:template>
    <xsl:template match="property_data/property/property_details/check_out">
	  	  <detailsCheck_out><xsl:apply-templates select="@*|node()" /></detailsCheck_out>
    </xsl:template>
    <xsl:template match="property_data/property/property_details/name">
	  	  <detailsName><xsl:apply-templates select="@*|node()" /></detailsName>
    </xsl:template>
    <xsl:template match="property_data/property/property_details/bathroom_count">
	  	  <detailsBathroom_count><xsl:apply-templates select="@*|node()" /></detailsBathroom_count>
    </xsl:template>
    <xsl:template match="property_data/property/property_details/bedroom_count">
	  	  <detailsBedroom_count><xsl:apply-templates select="@*|node()" /></detailsBedroom_count>
    </xsl:template>
    <xsl:template match="property_data/property/property_details/currency">
	  	  <detailsCurrency><xsl:apply-templates select="@*|node()" /></detailsCurrency>
    </xsl:template>
    <xsl:template match="property_data/property/property_details/elder">
	  	  <detailsElder><xsl:apply-templates select="@*|node()" /></detailsElder>
    </xsl:template>
    <xsl:template match="property_data/property/property_details/handicap">
	  	  <detailsHandicap><xsl:apply-templates select="@*|node()" /></detailsHandicap>
    </xsl:template>
    <xsl:template match="property_data/property/property_details/minimum_stay">
	  	  <detailsMinimum_stay><xsl:apply-templates select="@*|node()" /></detailsMinimum_stay>
    </xsl:template>
    <xsl:template match="property_data/property/property_details/occupancy">
	  	  <detailsOccupancy><xsl:apply-templates select="@*|node()" /></detailsOccupancy>
    </xsl:template>
    <xsl:template match="property_data/property/property_details/pet">
	  	  <detailsPet><xsl:apply-templates select="@*|node()" /></detailsPet>
    </xsl:template>
    <xsl:template match="property_data/property/property_details/smoking">
	  	  <detailsSmoking><xsl:apply-templates select="@*|node()" /></detailsSmoking>
    </xsl:template>
    <xsl:template match="property_data/property/property_details/unit_size">
	  	  <detailsUnit_size><xsl:apply-templates select="@*|node()" /></detailsUnit_size>
    </xsl:template>
    <xsl:template match="property_data/property/property_details/url">
	  	  <detailsUrl><xsl:apply-templates select="@*|node()" /></detailsUrl>
    </xsl:template>
    <xsl:template match="property_data/property/property_details/unit_size_units">
	  	  <detailsUnit_size_units><xsl:apply-templates select="@*|node()" /></detailsUnit_size_units>
    </xsl:template>
    <xsl:template match="property_data/property/property_details/property_type">
	  	  <detailsProperty_type><xsl:apply-templates select="@*|node()" /></detailsProperty_type>
    </xsl:template>
    <xsl:template match="property_data/property/property_details/children">
	  	  <detailsChildren><xsl:apply-templates select="@*|node()" /></detailsChildren>
    </xsl:template>

	<xsl:template match="property_data/property/property_descriptions">
		<xsl:for-each select="property_description">
			<xsl:if test="type = 'property'">
				<propertyDescription><xsl:value-of select="description"/></propertyDescription>
			</xsl:if>
        </xsl:for-each>
	</xsl:template>

    <xsl:template match="property_data/property/property_flags">
    </xsl:template>
		
    <xsl:template match="property_data/property/property_addresses">
<!-- Ignore the property_addresses node -->
	  <xsl:apply-templates/>
    </xsl:template>
<!-- Extract and rename the contents of the property_addresses node -->
    <xsl:template match="property_data/property/property_addresses/location_name">
	  	  <addressLocation_name><xsl:apply-templates select="@*|node()" /></addressLocation_name>
    </xsl:template>
    <xsl:template match="property_data/property/property_addresses/new_location_id">
	  	  <addressNew_location_id><xsl:apply-templates select="@*|node()" /></addressNew_location_id>
    </xsl:template>
    <xsl:template match="property_data/property/property_addresses/city">
	  	  <addressCity><xsl:apply-templates select="@*|node()" /></addressCity>
    </xsl:template>
    <xsl:template match="property_data/property/property_addresses/zip">
	  	  <addressZip><xsl:apply-templates select="@*|node()" /></addressZip>
    </xsl:template>
    <xsl:template match="property_data/property/property_addresses/address1">
	  	  <addressAddress1><xsl:apply-templates select="@*|node()" /></addressAddress1>
    </xsl:template>
    <xsl:template match="property_data/property/property_addresses/address2">
	  	  <addressAddress2><xsl:apply-templates select="@*|node()" /></addressAddress2>
    </xsl:template>
    <xsl:template match="property_data/property/property_addresses/longitude">
	  	  <addressLongitude><xsl:apply-templates select="@*|node()" /></addressLongitude>
    </xsl:template>
    <xsl:template match="property_data/property/property_addresses/latitude">
	  	  <addressLatitude><xsl:apply-templates select="@*|node()" /></addressLatitude>
    </xsl:template>
    <xsl:template match="property_data/property/property_addresses/precision">
	  	  <addressPrecision><xsl:apply-templates select="@*|node()" /></addressPrecision>
    </xsl:template>
    <xsl:template match="property_data/property/property_addresses/show_exact_address">
	  	  <addressShow_exact_address><xsl:apply-templates select="@*|node()" /></addressShow_exact_address>
    </xsl:template>
    <xsl:template match="property_data/property/property_addresses/state">
	  	  <addressState><xsl:apply-templates select="@*|node()" /></addressState>
    </xsl:template>
    <xsl:template match="property_data/property/property_addresses/subregion">
	  	  <addressSubregion><xsl:apply-templates select="@*|node()" /></addressSubregion>
    </xsl:template>
    <xsl:template match="property_data/property/property_addresses/country">
	  	  <addressCountry><xsl:apply-templates select="@*|node()" /></addressCountry>
    </xsl:template>

    <xsl:template match="property_data/property/property_rate_summary">
<!-- Ignore the property_rate_summary node -->
	  <xsl:apply-templates/>
    </xsl:template>
<!-- Extract and rename the contents of the property_rate_summary node -->
    <xsl:template match="property_data/property/property_rate_summary/day_max_rate">
    </xsl:template>
    <xsl:template match="property_data/property/property_rate_summary/day_min_rate">
	  	  <rateDay_min_rate><xsl:apply-templates select="@*|node()" /></rateDay_min_rate>
    </xsl:template>
    <xsl:template match="property_data/property/property_rate_summary/minimum_length">
	  	  <rateMinimum_length><xsl:apply-templates select="@*|node()" /></rateMinimum_length>
    </xsl:template>
    <xsl:template match="property_data/property/property_rate_summary/month_max_rate">
    </xsl:template>
    <xsl:template match="property_data/property/property_rate_summary/month_min_rate">
	  	  <rateMonth_min_rate><xsl:apply-templates select="@*|node()" /></rateMonth_min_rate>
    </xsl:template>
    <xsl:template match="property_data/property/property_rate_summary/week_max_rate">
    </xsl:template>
    <xsl:template match="property_data/property/property_rate_summary/week_min_rate">
	  	  <rateWeek_min_rate><xsl:apply-templates select="@*|node()" /></rateWeek_min_rate>
    </xsl:template>
    <xsl:template match="property_data/property/property_rate_summary/user_day_max_rate">
    </xsl:template>
    <xsl:template match="property_data/property/property_rate_summary/user_day_min_rate">
    </xsl:template>
    <xsl:template match="property_data/property/property_rate_summary/user_month_max_rate">
    </xsl:template>
    <xsl:template match="property_data/property/property_rate_summary/user_month_min_rate">
    </xsl:template>
    <xsl:template match="property_data/property/property_rate_summary/user_week_max_rate">
    </xsl:template>
    <xsl:template match="property_data/property/property_rate_summary/user_week_min_rate">
    </xsl:template>

	<xsl:template match="property_data/property/property_attributes">
<!-- Ignore this node -->	
	  <xsl:apply-templates/>
    </xsl:template>
	<xsl:template match="property_data/property/property_attributes/modified">
	    <xsl:if test="*"> 
<!-- Ignore this node if it has child(ren) -->	
	      <xsl:apply-templates/>
        </xsl:if>
		<xsl:if test="not(property_attributes/modified)">
<!-- Use this node -->	
		    <attributesModified><xsl:apply-templates select="@*|node()" /></attributesModified>
			<attributesIs_revgen></attributesIs_revgen>
			<attributesService_level_id></attributesService_level_id>
	    </xsl:if>
    </xsl:template>
    <xsl:template match="property_data/property/property_attributes/modified/property_flags">
<!-- Ignore this node -->	
	  <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="property_data/property/property_attributes/modified/property_flags">
	    <attributesIs_revgen><xsl:value-of select="is_revgen"/></attributesIs_revgen>
    </xsl:template>
    <xsl:template match="property_data/property/property_attributes/modified/property_attributes">
	    <attributesModified><xsl:value-of select="modified"/></attributesModified>
	    <attributesService_level_id><xsl:value-of select="service_level_id"/></attributesService_level_id>
    </xsl:template>
    <xsl:template match="property_data/property/property_attributes/user_id">
	  	  <attributesUser_id><xsl:apply-templates select="@*|node()" /></attributesUser_id>
    </xsl:template>
    <xsl:template match="property_data/property/property_attributes/direct">
	  	  <attributesDirect><xsl:apply-templates select="@*|node()" /></attributesDirect>
    </xsl:template>
    <xsl:template match="property_data/property/property_attributes/score">
	  	  <attributesScore>0.00</attributesScore>
    </xsl:template>
    <xsl:template match="property_data/property/property_attributes/user_group_id">
	  	  <attributesUser_group_id><xsl:apply-templates select="@*|node()" /></attributesUser_group_id>
    </xsl:template>
    <xsl:template match="property_data/property/property_attributes/frontdesk_id">
	  	  <attributesFrontdesk_id><xsl:apply-templates select="@*|node()" /></attributesFrontdesk_id>
    </xsl:template>
    <xsl:template match="property_data/property/property_attributes/property_id">
	  	  <attributesProperty_id><xsl:apply-templates select="@*|node()" /></attributesProperty_id>
    </xsl:template>

<!-- 25/10/2014  TW  Additional replacements to transform revised photo schema elements back to original naming -->
    <xsl:template match="property_data/property/property_photos/property_photo/ta_image">
	  	  <base_url><xsl:apply-templates select="@*|node()" /></base_url>
    </xsl:template>
    <xsl:template match="property_data/property/property_photos/property_photo/ta_image_width">
	  	  <width><xsl:apply-templates select="@*|node()" /></width>
    </xsl:template>
    <xsl:template match="property_data/property/property_photos/property_photo/ta_image_height">
	  	  <height><xsl:apply-templates select="@*|node()" /></height>
    </xsl:template>

<!-- START  12/05/2014  TW  Ignore various nodes / elements -->	
    <xsl:template match="property_data/property/property_bathrooms">
    </xsl:template>

    <xsl:template match="property_data/property/property_bedrooms">
    </xsl:template>

    <xsl:template match="property_data/property/property_calendar">
    </xsl:template>

    <xsl:template match="property_data/property/property_fees">
    </xsl:template>

    <xsl:template match="property_data/property/property_videos">
    </xsl:template>

    <xsl:template match="property_data/property/property_default_rates">
    </xsl:template>

    <xsl:template match="property_data/property/property_themes">
    </xsl:template>

    <xsl:template match="property_data/property/property_calendars">
    </xsl:template>

    <xsl:template match="property_data/property/flagsCalendar_export_url">
    </xsl:template>
    <xsl:template match="property_data/property/flagsRates_updated">
    </xsl:template>
    <xsl:template match="property_data/property/flagsLast_booked_date">
    </xsl:template>
    <xsl:template match="property_data/property/flagsHas_special">
    </xsl:template>
    <xsl:template match="property_data/property/flagsPhotos_updated">
    </xsl:template>
    <xsl:template match="property_data/property/flagsIs_tip">
    </xsl:template>
    <xsl:template match="property_data/property/flagsCalendar_updated">
    </xsl:template>
    <xsl:template match="property_data/property/flagsAlt_photo_test">
    </xsl:template>
    <xsl:template match="property_data/property/flagsAlt_pdp_sprite_filename">
    </xsl:template>

    <xsl:template match="property_data/property/property_special">
    </xsl:template>
    <xsl:template match="property_data/property/property_special/amt_off_per_night">
    </xsl:template>
    <xsl:template match="property_data/property/property_special/amt_off_per_stay">
    </xsl:template>
    <xsl:template match="property_data/property/property_special/currency">
    </xsl:template>
    <xsl:template match="property_data/property/property_special/description">
    </xsl:template>
    <xsl:template match="property_data/property/property_special/title">
    </xsl:template>
    <xsl:template match="property_data/property/property_special/free_stuff_title">
    </xsl:template>
    <xsl:template match="property_data/property/property_special/num_free_nights">
    </xsl:template>
    <xsl:template match="property_data/property/property_special/out_of_num_nights">
    </xsl:template>
    <xsl:template match="property_data/property/property_special/pct_off_rate">
    </xsl:template>
    <xsl:template match="property_data/property/property_special/publish_start_date">
    </xsl:template>
    <xsl:template match="property_data/property/property_special/publish_end_date">
    </xsl:template>
    <xsl:template match="property_data/property/property_special/rental_start_date">
    </xsl:template>
    <xsl:template match="property_data/property/property_special/rental_end_date">
    </xsl:template>
    <xsl:template match="property_data/property/property_special/special_type_description">
    </xsl:template>

<!-- END  12/05/2014  TW  Ignore various nodes / elements -->	

</xsl:stylesheet>