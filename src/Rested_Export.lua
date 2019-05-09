#!/usr/bin/env lua

accountPath = arg[1]
exportType = arg[2]

pathSeparator = string.sub(package.config, 1, 1) -- first character of this string (http://www.lua.org/manual/5.2/manual.html#pdf-package.config)
-- remove 'extra' separators from the end of the given path
while (string.sub( accountPath, -1, -1 ) == pathSeparator) do
	accountPath = string.sub( accountPath, 1, -2 )
end
-- append the expected location of the datafile
dataFilePath = {
	accountPath,
	"SavedVariables",
	"Rested.lua"
}
dataFile = table.concat( dataFilePath, pathSeparator )

restingRate = {}
restingRate[0] = (5/(32*3600))
restingRate[1] = (5/(8*3600))

cacheRate = 6 -- 6/hour (144/day)
cacheMax = 500  -- Todo:  This needs to come from a variable, and be stored per character...  :|
guildList = {}

function FileExists( name )
	local f = io.open( name, "r" )
	if f then io.close( f ) return true else return false end
end
function DoFile( filename )
	local f = assert( loadfile( filename ) )
	return f()
end
function MakeCharTable( realm, name, c )
	charStruct = {}
	charStruct.rn = realm
	charStruct.cn = name
	charStruct.isResting = (c.isResting and 1 or 0)
	charStruct.class = c.class
	charStruct.initAt = c.initAt
	charStruct.updated = c.updated
	charStruct.race = c.race
	charStruct.xpNow = c.xpNow
	charStruct.xpMax = c.xpMax
	charStruct.restedPC = c.restedPC
	charStruct.lvlNow = c.lvlNow
	charStruct.faction = c.faction
	charStruct.iLvl = c.iLvl or 0
	charStruct.gender = c.gender
	charStruct.guild = c.guildName or ""
	charStruct.totalPlayed = c.totalPlayed or 0

	if c.guildName then
		guildList[c.guildName] = realm
	end

	return charStruct
end
function ExportXML()
	strOut = "<?xml version='1.0' encoding='utf-8' ?>\n"
	strOut = strOut .. "<restedToons>\n"
	strOut = strOut .. "\t<resting>"..restingRate[1].."</resting>\n";
	strOut = strOut .. "\t<notresting>"..restingRate[0].."</notresting>\n";
	strOut = strOut .. "\t<maxLevel>"..Rested_options.maxLevel.."</maxLevel>\n";
	strOut = strOut .. "\t<maxiLvl>"..Rested_options.maxiLvl.."</maxiLvl>\n";
	strOut = strOut .. "\t<cacheRate>6</cacheRate>\n"

	for realm, chars in pairs( Rested_restedState ) do
		for name, c in pairs(chars) do
			if not c.ignore or c.ignore < os.time() then
				charStruct = MakeCharTable( realm, name, c )
				charOut = {}
				for k,v in pairs(charStruct) do
					table.insert(charOut, string.format('%s="%s"', k, v))
				end
				strOut = strOut .. '\t<c '..table.concat( charOut, " " )..'/>\n'
			end
		end
	end
	for guildName, realm in pairs( guildList ) do
		strOut = strOut .. string.format('\t<gi gn="%s" rn="%s" />\n', guildName, realm)
	end

	strOut = strOut .. "</restedToons>"
	return strOut
end
function ExportJSON()
	strOut = "{\"restedToons\": {\n"
	strOut = strOut .. "\t\"resting\": \""..restingRate[1].."\",\n"
	strOut = strOut .. "\t\"notresting\": \""..restingRate[0].."\",\n"
	strOut = strOut .. "\t\"maxLevel\": "..Rested_options.maxLevel..",\n"
	strOut = strOut .. "\t\"maxiLvl\": "..Rested_options.maxiLvl..",\n"
	strOut = strOut .. "\t\"chars\": [\n"

	outTable = {}
	for realm, chars in pairs(Rested_restedState) do
		for name, c in pairs(chars) do
			if not c.ignore or c.ignore < os.time() then
				charStruct = MakeCharTable( realm, name, c )
				charOut = {}
				for k,v in pairs(charStruct) do
					if type(v) == "number" then
						table.insert(charOut, string.format('"%s":%s', k, v))
					else
						table.insert(charOut, string.format('"%s":"%s"', k, v))
					end
				end
				charLine = '\t\t{'..table.concat( charOut, ", " )..'}'
				table.insert(outTable, charLine)
			end
		end
	end
	strOut = strOut .. table.concat( outTable, ",\n" )
	strOut = strOut .. "\n\t],\n"
	strOut = strOut .. '\t"guilds": [\n'

	outTable = {}
	for guildName, realm in pairs( guildList ) do
		guildLine = string.format('\t\t{"gn":"%s", "rn":"%s"}', guildName, realm )
		table.insert( outTable, guildLine )
	end
	strOut = strOut .. table.concat( outTable, ",\n" )
	strOut = strOut .. "\n\t]\n"


	strOut = strOut .. "}}"
	return strOut
end


functionList = {
	["xml"] = ExportXML,
	["json"] = ExportJSON
}

func = functionList[string.lower( exportType )]

if dataFile and FileExists( dataFile ) and exportType and func then
	DoFile( dataFile )
	strOut = func()
	print( strOut )
else
	io.stderr:write( "Something is wrong.  Lets review:\n")
	io.stderr:write( "Data file provided: "..( dataFile and " True" or "False" ).."\n" )
	io.stderr:write( "Data file exists  : "..( FileExists( dataFile ) and " True" or "False" ).."\n" )
	io.stderr:write( "ExportType given  : "..( exportType and " True" or "False" ).."\n" )
	io.stderr:write( "ExportType valid  : "..( func and " True" or "False" ).."\n" )
end


