<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
  <xsl:output method="text" version="1.0" encoding="utf-8" indent="no"/>
  <xsl:template match="/">
    <xsl:text>propertyId;unitId;url;thumbnailUrl;headline;description;propertyType;bedrooms;sleeps;bathrooms;city;state;country;postalCode</xsl:text>
    <xsl:text>&#13;&#10;</xsl:text>

    <xsl:for-each select="*[local-name()='feed']/*[local-name()='entry']/*[local-name()='content']/*[local-name()='listing']/*[local-name()='data']">
      <xsl:value-of select="../@propertyId"/>
      <xsl:text>;</xsl:text>
      <xsl:value-of select="../@unitId"/>
      <xsl:text>;"</xsl:text>
      <xsl:value-of select="../@url"/>
      <xsl:text>";"</xsl:text>
      <xsl:value-of select="../@thumbnailUrl"/>
      <xsl:text>";"</xsl:text>
      <xsl:value-of select="../headline"/>
      <xsl:text>";"</xsl:text>
      <xsl:value-of select="../description"/>
      <xsl:text>";"</xsl:text>
      <xsl:value-of select="@propertyType"/>
      <xsl:text>";</xsl:text>
      <xsl:value-of select="@bedrooms"/>
      <xsl:text>;</xsl:text>
      <xsl:value-of select="@sleeps"/>
      <xsl:text>;</xsl:text>
      <xsl:value-of select="@bathrooms"/>
      <xsl:text>;"</xsl:text>
      <xsl:value-of select="@city"/>
      <xsl:text>";"</xsl:text>
      <xsl:value-of select="@state"/>
      <xsl:text>";"</xsl:text>
      <xsl:value-of select="@country"/>
      <xsl:text>";"</xsl:text>
      <xsl:value-of select="@postalCode"/>
      <xsl:text>"</xsl:text>
      <xsl:text>&#13;&#10;</xsl:text>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
