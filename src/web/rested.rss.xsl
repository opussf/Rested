<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ex="http://exslt.org/dates-and-times"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:output method="xml" />

	<xsl:variable name="now" select="ex:seconds()" />

	<xsl:template match="/">
		<rss version="2.0">
		<channel>
			<title>Rested Users</title>
			<link>http://www.zz9-za.com/~opus/chars</link>
			<description>My Rested Chars</description>
			<generator>xslt</generator>
			<ttl>30</ttl>
		<xsl:for-each select="restedToons/c">
			<xsl:sort data-type='number' order='ascending' select='@updated'/>
			<xsl:apply-templates select='.'/>
		</xsl:for-each>
		</channel>
		</rss>
	</xsl:template>

	<xsl:template match="c">
		<xsl:variable name='sincePlayed' select="$now - @updated"/>
		<xsl:variable name='PCgained' select='$sincePlayed * /restedToons/resting'/>
		<xsl:variable name='restedText'>
			<xsl:choose>
				<xsl:when test='@lvlNow = 85'>Max Level</xsl:when>
				<xsl:when test='(@restedPC + $PCgained) &gt; 150'>Fully Rested</xsl:when>
				<xsl:otherwise>Resting</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name='lvlPC' select="(@xpNow div @xpMax)"/>
		<xsl:variable name='xslDate' select='ex:add("1970-01-01T00:00:00", ex:duration(@updated))'/>
		<xsl:variable name='pubDate'>
			<xsl:value-of select="concat(ex:day-abbreviation($xslDate), ', ',
				format-number(ex:day-in-month($xslDate), '00'), ' ',
				ex:month-abbreviation($xslDate), ' ', ex:year($xslDate), ' ',
				format-number(ex:hour-in-day($xslDate), '00'), ':',
				format-number(ex:minute-in-hour($xslDate), '00'), ':',
				format-number(ex:second-in-minute($xslDate), '00'), ' GMT')"/>
		</xsl:variable>
		<item>
		<title>
			<xsl:value-of select='@cn'/>
			<xsl:text> - </xsl:text>
			<xsl:value-of select='@rn'/>
			<xsl:text> (Level </xsl:text>
			<xsl:value-of select='@lvlNow'/>
			<xsl:text>::</xsl:text>
			<xsl:value-of select='@race'/>
			<xsl:text> - </xsl:text>
			<xsl:value-of select='@class'/>
			<xsl:text>) iLvl(</xsl:text>
			<xsl:value-of select='@iLvl'/>
			<xsl:text>) is </xsl:text>
			<xsl:value-of select='$restedText'/>
		</title>
		<link>http://www.zz9-za.com/~opus/chars</link>
		<guid isPermaLink='false'>
			<xsl:value-of select='@cn'/>
			<xsl:value-of select='@rn'/>
			<xsl:value-of select='@lvlNow'/>
			<xsl:value-of select='@iLvl'/>
			<xsl:value-of select='$restedText'/>
		</guid>
		<pubDate>
			<xsl:value-of select='$pubDate'/>
		</pubDate>
		<description>
			<xsl:value-of select="@cn"/><xsl:text> of </xsl:text><xsl:value-of select="@rn"/>
			<xsl:text> is a level </xsl:text><xsl:value-of select='@lvlNow'/>
			<xsl:text> </xsl:text><xsl:value-of select='@race'/>
			<xsl:text> </xsl:text><xsl:value-of select='@class'/>
			<xsl:text>, and is </xsl:text><xsl:value-of select='$restedText'/>.
			<xsl:text>&lt;br/&gt;The average item Level of equiped gear is: </xsl:text>
			<xsl:value-of select='@iLvl'/>
			<!--xsl:value-of select='format-number($PCgained, "#.0")'/ -->
<!--
			<xsl:value-of select='@lvlNow + $lvlPC'/>  <xsl:value-of select='@updated'/>
-->
		</description>
		</item>
	</xsl:template>

</xsl:stylesheet>
