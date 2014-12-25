<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ex="http://exslt.org/dates-and-times"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:output method="xml" />

	<xsl:variable name="now" select="ex:seconds()" />
	<xsl:variable name='maxLevel' select='/restedToons/maxLevel'/>

	<xsl:template match="/">
		<feed xmlns="http://www.w3.org/2005/Atom">

			<title>Rested Users</title>
			<subtitle>My Rested Chars</subtitle>
			<id>http://www.zz9-za.com/~opus/chars/atom</id>
			<link rel='alternate' type='text/html' hreflang='en' href='http://www.zz9-za.com/~opus/chars'/>
			<link rel='self' type='application/atom+xml' hreflang='en' href='http://www.zz9-za.com/~opus/chars/atom'/>
			<generator>xslt</generator>
			<updated/>
		<xsl:for-each select="restedToons/c">
			<xsl:sort data-type='number' order='ascending' select='@updated'/>
			<xsl:apply-templates select='.'/>
		</xsl:for-each>
		</feed>
	</xsl:template>

	<xsl:template match="c">
		<xsl:variable name='sincePlayed' select="$now - @updated"/>
		<xsl:variable name='PCgained' select='$sincePlayed * /restedToons/resting'/>
		<xsl:variable name='restedText'>
			<xsl:choose>
				<xsl:when test='@lvlNow = $maxLevel'>Max Level</xsl:when>
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
		<entry>
		<title>
			<xsl:value-of select='@cn'/>
			<xsl:text> - </xsl:text>
			<xsl:value-of select='@rn'/>
			<xsl:text> (Level </xsl:text>
			<xsl:value-of select='@lvlNow'/>
			<xsl:text>::</xsl:text>
			<xsl:value-of select='@faction'/>
			<xsl:text>::</xsl:text>
			<xsl:value-of select='@race'/>
			<xsl:text> - </xsl:text>
			<xsl:value-of select='@class'/>
			<xsl:text>) iLvl(</xsl:text>
			<xsl:value-of select='@iLvl'/>
			<xsl:text>) is </xsl:text>
			<xsl:value-of select='$restedText'/>
		</title>
		<link rel='alternate' type='text/html' href='http://www.zz9-za.com/~opus/chars' title='char link' />
		<id isPermaLink='false'>
			<xsl:value-of select='@cn'/>
			<xsl:value-of select='@rn'/>
			<xsl:value-of select='@lvlNow'/>
			<xsl:value-of select='@iLvl'/>
			<xsl:value-of select='$restedText'/>
		</id>
		<published>
			<xsl:value-of select='$pubDate'/>
		</published>
		<content type="html" xml:lang="en">
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
		</content>
		</entry>
	</xsl:template>

</xsl:stylesheet>
