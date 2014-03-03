<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
  <xsl:output method="text" version="1.0" encoding="utf-8" indent="no"/>
  <xsl:template match="/">
    <xsl:text>name;otherColumns</xsl:text>
    <xsl:text>&#13;&#10;</xsl:text>

    <xsl:for-each select="property_data/property/property_details">
      <xsl:text>"</xsl:text>
      <xsl:value-of select="name"/>
      <xsl:text>"</xsl:text>
      <xsl:text>&#13;&#10;</xsl:text>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
