<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ex="http://exslt.org/dates-and-times"
	xmlns:rc='http://www.zz9-za.com/~opus/chars'>

	<xsl:output method="html"
doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" />
	
	<xsl:variable name="now" select="ex:seconds()" />
	<xsl:variable name="totalChars" select="count(restedToons/c)" />
	<xsl:variable name='maxLevel' select='/restedToons/maxLevel'/>
	<xsl:variable name='maxiLvl'>
		<xsl:for-each select="/restedToons/c">
			<xsl:sort data-type="number" order="descending" select='@iLvl'/>
			<xsl:if test="position()=1"><xsl:value-of select="@iLvl"/></xsl:if>
		</xsl:for-each>
	</xsl:variable>

	<xsl:template match="/">
		<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
		<head>
		<title>Rested Users</title>
		<link type="text/css" rel="stylesheet" href="rested.css"/>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<link href='rss' rel='alternate' type='application/rss+xml' title='Char RSS Feed'/>
		<link href='atom' rel='alternate' type='application/atom+xml' title='Char Atom Feed'/>
		<link rel='icon' type='image/png' href='favicon.png'/>
		<meta http-equiv="refresh" content="300"/>
		<script language="JavaScript">
<xsl:text><![CDATA[
<!--
ns4 = document.layers
ie4 = document.all
nn6 = document.getElementById && !document.all
function hideObject(id) {
   if (ns4) {
      document.id.visibility = "hide";
   }   else if (ie4) {
      document.all[id].style.visibility = "hidden";
   }   else if (nn6) {
      document.getElementById(id).style.visibility = "hidden";
 }
}
function showObject(id) {
   if (ns4) {
      document.id.visibility = "show";
   }   else if (ie4) {
      document.all[id].style.visibility = "visible";
   }   else if (nn6) {
      document.getElementById(id).style.visibility = "visible";
   }
}
//-->
]]></xsl:text>
</script>
		</head>
		<body>
		<div class='restedtop'>
		<div class='header'>
		<span>My Characters from Wow. Recorded by Rested addon.  <a href='about.html'>About</a> this page.</span>
		</div>
		<div class='main'>
		<div class='max'>
		<span>Max Chars (<xsl:value-of select="count(restedToons/c[@lvlNow= $maxLevel])"/>)</span>
		<xsl:for-each select="restedToons/c[@lvlNow= $maxLevel]">
			<xsl:sort data-type='number' order='descending' select='@iLvl'/>
			<xsl:sort data-type='number' order='descending' select='@updated'/>
			<xsl:apply-templates select='.'/>
		</xsl:for-each>
		</div>
		<div class='leveling'>
		<span>Leveling Chars (<xsl:value-of select="count(restedToons/c[@lvlNow!= $maxLevel])"/>)</span>
		<xsl:for-each select="restedToons/c[@lvlNow!= $maxLevel]">
			<xsl:sort data-type='number' order='descending' select='@updated'/>
			<xsl:apply-templates select='.'/>
		</xsl:for-each>
		</div>  <!-- leveling -->
		</div>  <!-- charbars -->
		<div class='stats'>
		<span>Character Stats</span>
		<xsl:call-template name='stats'/>
		</div>  <!-- stats -->
		</div>  <!-- restedtop -->
		</body>
		</html>
	</xsl:template>

	<xsl:template name='stats'>
		<xsl:call-template name='total'/>
		<xsl:call-template name='levels'/>
		<xsl:call-template name='stale'/>
		<xsl:call-template name='faction'/>
		<xsl:call-template name='gender'/>
		<xsl:call-template name='race'/>
		<xsl:call-template name='class'/>
	</xsl:template>

	<xsl:template name='showGroups'>
		<xsl:param name='title'/>
		<xsl:param name='att'/>
		<xsl:param name='a1'/>
		<div class='statsbox'>
			<xsl:apply-templates select="@*"><xsl:with-param name='att'>$att</xsl:with-param></xsl:apply-templates>
			<xsl:value-of select="$title"/><xsl:text>:</xsl:text>
			<xsl:value-of select='$a1'/><xsl:text>(</xsl:text>
			<xsl:value-of select="concat('count(/restedToons/c[', $att, ' = ', $a1, '])')"/> 
			<xsl:value-of select="$att"/>
			<xsl:value-of select='$a1'/>
			<xsl:value-of select="*[name($att) = $a1]"/>
			<xsl:value-of select="name(.)"/>
		</div> <!-- statsbox -->
	</xsl:template>

	<xsl:template name='statEntry'>
		<xsl:param name='title'/>
		<xsl:param name='val'/>

		<xsl:variable name='thisPC' select='$val div $totalChars'/>


		<div class='char'>
		<div class='meter-wrap'>
		<xsl:element name='div'>
			<xsl:attribute name='class'>meter-value</xsl:attribute>
			<xsl:attribute name='style'>background-color: #09f; width: <xsl:value-of select='$thisPC * 100'/>%</xsl:attribute>
			<div class='meter-text'>
				<xsl:value-of select='$title'/>
				<xsl:text> (</xsl:text>
				<xsl:value-of select='$val'/>
				<xsl:text> - </xsl:text>
				<xsl:value-of select="format-number($thisPC, '0.0%')"/>
				<xsl:text>) </xsl:text>
			
			</div>  <!-- meter-text  -->
		</xsl:element> <!-- meter-value  -->
		</div> <!-- meter-wrap -->
		</div> <!-- char -->

	</xsl:template>
		

	<xsl:template name='total'>
		<div class='statsbox' style='width: 100%'>
		<xsl:text>Total:</xsl:text>
		<xsl:value-of select="$totalChars"/>
		</div>
	</xsl:template>

	<xsl:template name='levels'>
		<xsl:variable name='vanillaCount' select="count(/restedToons/c[@lvlNow &lt; '60'])"/>
		<xsl:variable name='vMax' select="count(/restedToons/c[@lvlNow = '60'])"/>
		<xsl:variable name='bcCount' select="count(/restedToons/c[@lvlNow &gt; '60' and @lvlNow &lt;'70'])"/>
		<xsl:variable name='bcMax' select="count(/restedToons/c[@lvlNow = '70'])"/>
		<xsl:variable name='lkCount' select="count(/restedToons/c[@lvlNow &gt; '70' and @lvlNow &lt;'80'])"/>
		<xsl:variable name='lkMax' select="count(/restedToons/c[@lvlNow = '80'])"/>
		<xsl:variable name='catCount' select="count(/restedToons/c[@lvlNow &gt; '80' and @lvlNow &lt;'85'])"/>
		<xsl:variable name='catMax' select="count(/restedToons/c[@lvlNow = '85'])"/>
		<xsl:variable name='mpCount' select="count(/restedToons/c[@lvlNow &gt; '85' and @lvlNow &lt;'90'])"/>
		<xsl:variable name='mpMax' select="count(/restedToons/c[@lvlNow = '90'])"/>
		<xsl:variable name='wdCount' select="count(/restedToons/c[@lvlNow &gt; '90' and @lvlNow &lt;'100'])"/>
		<xsl:variable name='wdMax' select="count(/restedToons/c[@lvlNow = '100'])"/>
		
		<div class='statsbox'>
		<xsl:text>By Levels:</xsl:text>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Vanilla [&lt; 60]</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$vanillaCount'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Vanilla Max [60]</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$vMax'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Burning Crusade [61 - 69]</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$bcCount'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Burning Crusade Max [70]</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$bcMax'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Lich King [71 - 79]</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$lkCount'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Lich King Max [80]</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$lkMax'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Cataclysm [81 - 84]</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$catCount'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Cataclysm Max [85]</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$catMax'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Mists of Pandera [86 - 89]</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$mpCount'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Mists of Pandera Max [90]</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$mpMax'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Warlords of Draenor [91-99]</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$wdCount'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Warlords of Draenor Max [100]</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$wdMax'/></xsl:with-param>
		</xsl:call-template>

		</div>
	</xsl:template>

	<xsl:template name='stale'>
		<xsl:variable name='day1' select='count(/restedToons/c[@updated &gt;= ($now - (86400 * 1))])'/>
		<xsl:variable name='day2' select='count(/restedToons/c[@updated &lt; ($now -(86400*1)) and @updated &gt;= ($now - (86400*2))])'/>
		<xsl:variable name='day3' select='count(/restedToons/c[@updated &lt; ($now -(86430*2)) and @updated &gt;= ($now - (86400*3))])'/>
		<xsl:variable name='day4' select='count(/restedToons/c[@updated &lt; ($now -(86430*3)) and @updated &gt;= ($now - (86400*4))])'/>
		<xsl:variable name='day5' select='count(/restedToons/c[@updated &lt; ($now -(86430*4)) and @updated &gt;= ($now - (86400*5))])'/>
		<xsl:variable name='day6' select='count(/restedToons/c[@updated &lt; ($now -(86430*5)) and @updated &gt;= ($now - (86400*6))])'/>
		<xsl:variable name='day7' select='count(/restedToons/c[@updated &lt; ($now -(86430*6)) and @updated &gt;= ($now - (86400*7))])'/>
		<xsl:variable name='day8' select='count(/restedToons/c[@updated &lt; ($now -(86430*7)) and @updated &gt;= ($now - (86400*8))])'/>
		<xsl:variable name='day9' select='count(/restedToons/c[@updated &lt; ($now -(86430*8)) and @updated &gt;= ($now - (86400*9))])'/>
		<xsl:variable name='stale' select='count(/restedToons/c[@updated &lt; ($now -(86400*9))])'/>

		<div class='statsbox'>
		<xsl:text>By Staleness:</xsl:text>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Last Day</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$day1'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Last 2 Days</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$day2'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Last 3 Days</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$day3'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Last 4 Days</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$day4'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Last 5 Days</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$day5'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Last 6 Days</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$day6'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Last 7 Days</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$day7'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Last 8 Days</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$day8'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Last 9 Days</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$day9'/></xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Stale</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$stale'/></xsl:with-param>
		</xsl:call-template>
		</div>
	</xsl:template>

	<xsl:template name='race'>
		<xsl:variable name='beCount' select="count(/restedToons/c[@race = 'Blood Elf'])"/>
		<xsl:variable name='drCount' select="count(/restedToons/c[@race = 'Draenei'])"/>
		<xsl:variable name='dwCount' select="count(/restedToons/c[@race = 'Dwarf'])"/>
		<xsl:variable name='gnCount' select="count(/restedToons/c[@race = 'Gnome'])"/>
		<xsl:variable name='goCount' select="count(/restedToons/c[@race = 'Goblin'])"/>
		<xsl:variable name='huCount' select="count(/restedToons/c[@race = 'Human'])"/>
		<xsl:variable name='neCount' select="count(/restedToons/c[@race = 'Night Elf'])"/>
		<xsl:variable name='orCount' select="count(/restedToons/c[@race = 'Orc'])"/>
		<xsl:variable name='taCount' select="count(/restedToons/c[@race = 'Tauren'])"/>
		<xsl:variable name='trCount' select="count(/restedToons/c[@race = 'Troll'])"/>
		<xsl:variable name='unCount' select="count(/restedToons/c[@race = 'Undead'])"/>
		<xsl:variable name='woCount' select="count(/restedToons/c[@race = 'Worgen'])"/>

		<div class='statsbox'>
		<xsl:text>By Race:</xsl:text>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Blood Elf</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$beCount'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Draenei</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$drCount'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Dwarf</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$dwCount'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Gnome</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$gnCount'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Goblin</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$goCount'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Human</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$huCount'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Night Elf</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$neCount'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Orc</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$orCount'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Pandaren</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select="count(/restedToons/c[@race = 'Pandaren'])"/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Tauren</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$taCount'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Troll</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$trCount'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Undead</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$unCount'/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='statEntry'>
			<xsl:with-param name='title'>Worgen</xsl:with-param>
			<xsl:with-param name='val'><xsl:value-of select='$woCount'/></xsl:with-param>
		</xsl:call-template>

		</div>  <!-- statsbox -->
	</xsl:template>

	<xsl:template name='faction'>
		<div class='statsbox'>
			<xsl:text>By Faction:</xsl:text>
			<xsl:call-template name='statEntry'>
				<xsl:with-param name='title'>Alliance</xsl:with-param>
				<xsl:with-param name='val'><xsl:value-of select="count(/restedToons/c[@faction = 'Alliance'])"/></xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name='statEntry'>
				<xsl:with-param name='title'>Horde</xsl:with-param>
				<xsl:with-param name='val'><xsl:value-of select="count(/restedToons/c[@faction = 'Horde'])"/></xsl:with-param>
			</xsl:call-template>
		</div> <!-- statsbox -->
	</xsl:template>

	<xsl:template name='gender'>
		<div class='statsbox'>
			<xsl:text>By Gender:</xsl:text>
			<xsl:call-template name='statEntry'>
				<xsl:with-param name='title'>Male</xsl:with-param>
				<xsl:with-param name='val'><xsl:value-of select="count(/restedToons/c[@gender = 'Male'])"/></xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name='statEntry'>
				<xsl:with-param name='title'>Female</xsl:with-param>
				<xsl:with-param name='val'><xsl:value-of select="count(/restedToons/c[@gender = 'Female'])"/></xsl:with-param>
			</xsl:call-template>
		</div> <!-- statsbox -->
	</xsl:template>

	<xsl:key name='classes' match='c' use='@class'/>
	<xsl:template name='class'>
		<div class='statsbox'>
			<xsl:text>By Class:</xsl:text>
			<xsl:call-template name='statEntry'>
				<xsl:with-param name='title'>Death Knight</xsl:with-param>
				<xsl:with-param name='val'><xsl:value-of select="count(/restedToons/c[@class = 'Death Knight'])"/></xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name='statEntry'>
				<xsl:with-param name='title'>Druid</xsl:with-param>
				<xsl:with-param name='val'><xsl:value-of select="count(/restedToons/c[@class = 'Druid'])"/></xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name='statEntry'>
				<xsl:with-param name='title'>Hunter</xsl:with-param>
				<xsl:with-param name='val'><xsl:value-of select="count(/restedToons/c[@class = 'Hunter'])"/></xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name='statEntry'>
				<xsl:with-param name='title'>Mage</xsl:with-param>
				<xsl:with-param name='val'><xsl:value-of select="count(/restedToons/c[@class = 'Mage'])"/></xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name='statEntry'>
				<xsl:with-param name='title'>Monk</xsl:with-param>
				<xsl:with-param name='val'><xsl:value-of select="count(/restedToons/c[@class = 'Monk'])"/></xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name='statEntry'>
				<xsl:with-param name='title'>Paladin</xsl:with-param>
				<xsl:with-param name='val'><xsl:value-of select="count(/restedToons/c[@class = 'Paladin'])"/></xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name='statEntry'>
				<xsl:with-param name='title'>Priest</xsl:with-param>
				<xsl:with-param name='val'><xsl:value-of select="count(/restedToons/c[@class = 'Priest'])"/></xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name='statEntry'>
				<xsl:with-param name='title'>Rogue</xsl:with-param>
				<xsl:with-param name='val'><xsl:value-of select="count(/restedToons/c[@class = 'Rogue'])"/></xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name='statEntry'>
				<xsl:with-param name='title'>Shaman</xsl:with-param>
				<xsl:with-param name='val'><xsl:value-of select="count(/restedToons/c[@class = 'Shaman'])"/></xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name='statEntry'>
				<xsl:with-param name='title'>Warlock</xsl:with-param>
				<xsl:with-param name='val'><xsl:value-of select="count(/restedToons/c[@class = 'Warlock'])"/></xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name='statEntry'>
				<xsl:with-param name='title'>Warrior</xsl:with-param>
				<xsl:with-param name='val'><xsl:value-of select="count(/restedToons/c[@class = 'Warrior'])"/></xsl:with-param>
			</xsl:call-template>
		</div> <!-- statsbox -->
	</xsl:template>

	<xsl:key name='realms' match='c' use='@rn'/>
	<xsl:template name='realm'>
		<div class='statsbox'>
			<xsl:text>Realm:</xsl:text>
			<xsl:for-each select="restedToons/c[generate-id() = generate-id(key('realms',@rn)[1])]">
				<xsl:sort data-type='text' order='ascending' select='@rn'/>
				<xsl:copy-of select="."/>
	
				<xsl:value-of select='@rn'/>
				<xsl:text> - </xsl:text>
			</xsl:for-each>
		</div> <!-- statsbox -->
	</xsl:template>

	<xsl:template name='iLvl'>
		<xsl:element name='a'>
			<xsl:attribute name='target'>_blank</xsl:attribute>
			<xsl:attribute name='href'>http://www.askmrrobot.com/wow/optimize/us/<xsl:value-of select='@rn'/>/<xsl:value-of select='@cn'/></xsl:attribute>
			<xsl:value-of select='@iLvl'/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="c">
		<xsl:variable name='sincePlayed' select="$now - @updated"/> <!-- seconds -->
		<xsl:variable name='restingRate'><xsl:choose> <!-- % per second -->
			<xsl:when test='@isResting = 1'><xsl:value-of select='/restedToons/resting'/></xsl:when>
			<xsl:otherwise><xsl:value-of select='/restedToons/notresting'/></xsl:otherwise>
		</xsl:choose></xsl:variable>
		<xsl:variable name='restingColor'><xsl:choose>
			<xsl:when test='@isResting = 1'>#09f</xsl:when>
			<xsl:otherwise>#f66</xsl:otherwise>
		</xsl:choose></xsl:variable>
		<xsl:variable name='PCgained' select='$sincePlayed * $restingRate'/>
		<xsl:variable name='PCsum'><xsl:choose>
			<xsl:when test='(@restedPC + $PCgained) &gt; 150'>150</xsl:when>
			<xsl:otherwise><xsl:value-of select='(@restedPC + $PCgained)'/></xsl:otherwise>
		</xsl:choose></xsl:variable>
		<xsl:variable name='correctedPC' select="($PCsum div 150) * 100"/>
		<xsl:variable name='lvlPC' select="(@xpNow div @xpMax) * 100"/>
		<xsl:variable name='PCNeeded'><xsl:value-of select='(150 - (@restedPC + $PCgained))'/></xsl:variable>
		<xsl:variable name='timeFull'>
			<xsl:value-of select='ex:add(ex:date-time(), ex:duration($PCNeeded div $restingRate))'/>
		</xsl:variable>
		<xsl:variable name='timeFullStr'>
			<xsl:value-of select="concat(ex:day-abbreviation($timeFull), ', ',
				format-number(ex:day-in-month($timeFull), '00'), ' ',
				ex:month-abbreviation($timeFull), ' ', ex:year($timeFull), ' ',
				format-number(ex:hour-in-day($timeFull), '00'), ':',
				format-number(ex:minute-in-hour($timeFull), '00'), ':',
				format-number(ex:second-in-minute($timeFull), '00'), ' GMT')"/>
		</xsl:variable>
		
		<xsl:variable name='iLvlPC' select="(@iLvl div $maxiLvl) * 100"/>
<!--
	 select='(@iLvl div max(/restedToons/c/@iLvl)) * 100'/>
-->

		<xsl:variable name='divname'><xsl:value-of select='@rn'/>-<xsl:value-of select='@cn'/></xsl:variable>
		<!-- output starts here -->
		<xsl:element name='div'> <!-- char -->
			<xsl:attribute name='class'>char</xsl:attribute>
			<xsl:attribute name='onMouseOver'>javascript:showObject("<xsl:value-of select='$divname'/>");</xsl:attribute>
			<xsl:attribute name='onMouseOut'>javascript:hideObject("<xsl:value-of select='$divname'/>");</xsl:attribute>

		<div class='meter-wrap'>
		<xsl:element name='div'>
			<xsl:attribute name='class'>meter-value</xsl:attribute>
			<xsl:attribute name='style'>background-color: <xsl:value-of select='$restingColor'/>; width: <xsl:value-of select='$correctedPC'/>%</xsl:attribute>
			<div class='meter-text'>
			<xsl:element name='a'>
				<xsl:attribute name='target'>_blank</xsl:attribute>
				<xsl:attribute name='href'>http://us.battle.net/wow/character/<xsl:value-of select='@rn'/>/<xsl:value-of select='@cn'/>/simple</xsl:attribute>
				<xsl:value-of select='@cn'/> - <xsl:value-of select='@rn'/> 
			</xsl:element>
			<xsl:text> (</xsl:text><xsl:value-of select='format-number($PCsum,"#.00")'/>%) <xsl:value-of select="ex:duration($sincePlayed)"/>
			</div> <!-- meter-text -->
		</xsl:element> <!-- meter-value -->
		<xsl:element name='div'>
			<xsl:attribute name='class'>meter-value</xsl:attribute>
			<xsl:choose>
				<xsl:when test="@lvlNow != $maxLevel">
					<xsl:attribute name='style'>background-color: #96f; width: <xsl:value-of select='$lvlPC'/>%</xsl:attribute>
					<div class='meter-text'>
						<xsl:value-of select='@lvlNow'/> (<xsl:value-of select='format-number($lvlPC,"#.00")'/>%) <xsl:value-of select='@race'/> - <xsl:value-of select='@class'/> :: <xsl:value-of select='@faction'/> :: iLvl: <xsl:call-template name='iLvl'/>
					</div> <!-- meter-text -->
				</xsl:when>
				<xsl:when test="@lvlNow = $maxLevel">
					<xsl:attribute name='style'>background-color: #96f; width: <xsl:value-of select='$iLvlPC'/>%</xsl:attribute>
					<div class='meter-text'>
						<xsl:value-of select='@lvlNow'/><xsl:text> </xsl:text><xsl:value-of select='@race'/> - <xsl:value-of select='@class'/> :: <xsl:value-of select='@faction'/> :: iLvl: <xsl:call-template name='iLvl'/>
					</div> <!-- meter-text -->
				</xsl:when>
			</xsl:choose>
		</xsl:element>
		</div> <!-- meter-wrap -->
		</xsl:element> <!-- char -->
		<xsl:element name='div'>
			<xsl:attribute name='id'><xsl:value-of select='$divname'/></xsl:attribute>
			<xsl:attribute name='class'>charfloat</xsl:attribute>
			<xsl:attribute name='style'>position:absolute; z-index:1; visibility:hidden</xsl:attribute>
			<xsl:value-of select='@cn'/> of <xsl:value-of select='@rn'/>
			<xsl:text> is a level </xsl:text><xsl:value-of select='@lvlNow'/>
			<xsl:text> </xsl:text><xsl:value-of select='@race'/>
			<xsl:text> </xsl:text><xsl:value-of select='@class'/>.
			<xsl:value-of select='format-number($lvlPC + $PCsum,"#.00")'/>
			<xsl:element name='br'/>
			<xsl:text>Date Full: </xsl:text>
			<xsl:value-of select='$timeFullStr'/>
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>
