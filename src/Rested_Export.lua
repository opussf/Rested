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
tableKeyMap = {
	["isResting"] = { ["key"] = "isResting", ["func"] = function( inValue ) return( inValue and 1 or 0 ); end, },
	["iLvl"] = { ["key"] = "iLvl", ["func"] = function( inValue ) return( inValue or 0 ); end },
	["guildName"] = { ["key"] = "guild", ["func"] = function( inValue ) return( inValue or "" ); end },
}
function GetKeyValues( key, value, keyPre, t )
--	print( string.format( "GetKeyValues( %s, %s, %s, %s )",
--			key, (value and "true" or "false"), (keyPre or "nil"), (t and "t" or "nil") ) )
	t = t or {}

	if( type(value) == "table" ) then
--		print( "value is a table" )
		for k, v in pairs( value ) do
			t = GetKeyValues( k, v, ( keyPre and keyPre.."_" or "" )..key , t )
		end
	else
		outKey = ( keyPre and keyPre.."_" or "" )..key
		outVal = (tableKeyMap[outKey] and tableKeyMap[outKey].func( value ) or value)
		if( type(outVal) == "boolean" ) then
			outVal = outVal and "True" or "False"
		end
		t[outKey] = outVal
	end
	return t
end
function EscapeStr( strIn )
	-- This escapes a str
	strIn = string.gsub( strIn, "\\", "\\\\" )
	strIn = string.gsub( strIn, "\"", "\\\"" )
	return strIn
end
function EscapeStrXML( strIn )
	strIn = string.gsub( strIn, "\"", "&quot;" )
	return strIn
end
function MakeCharTable( realm, name, c )
	charStruct = {}
	charStruct.rn = realm
	charStruct.cn = name

	-- Use the keyMap to set default values.
	for k, struct in pairs( tableKeyMap ) do
		charStruct[struct.key] = struct.func()
	end
	-- Go through the keys, get single key-value pairs.
	-- Tables will have _ seperated names
	for key, value in pairs( c ) do
		keyValues = GetKeyValues( key, value )

		for k, v in pairs( keyValues ) do
			charStruct[tableKeyMap[k] and tableKeyMap[k].key or k] = v
		end
	end
	-- Add the guild name to a different struct.
	if c.guildName then
		guildList[c.guildName.."-"..realm] = {["guildName"] = c.guildName, ["realm"] = realm }
	end

	return charStruct
end
function ExportXML()
	strOut = "<?xml version='1.0' encoding='utf-8' ?>\n"
	strOut = strOut .. "<restedToons>\n"
	strOut = strOut .. "\t<resting>"..restingRate[1].."</resting>\n";
	strOut = strOut .. "\t<notresting>"..restingRate[0].."</notresting>\n";
	strOut = strOut .. "\t<maxLevel>"..Rested_misc.maxLevel.."</maxLevel>\n";
	strOut = strOut .. "\t<maxiLvl>"..Rested_misc.maxiLvl.."</maxiLvl>\n";
	strOut = strOut .. "\t<cacheRate>6</cacheRate>\n"

	for realm, chars in sorted_pairs( Rested_restedState ) do
		for name, c in sorted_pairs(chars) do
			if not c.ignore or c.ignore < os.time() then
				charStruct = MakeCharTable( realm, name, c )
				charOut = {}
				for k,v in sorted_pairs(charStruct) do
					table.insert(charOut, string.format('%s="%s"', k, EscapeStrXML(v)))
				end
				strOut = strOut .. '\t<c '..table.concat( charOut, " " )..'/>\n'
			end
		end
	end
	for _, st in sorted_pairs( guildList ) do
		strOut = strOut .. string.format('\t<gi gn="%s" rn="%s" />\n', st.guildName, st.realm)
	end

	strOut = strOut .. "</restedToons>"
	return strOut
end
function ExportJSON()
	strOut = "{\"restedToons\": {\n"
	strOut = strOut .. "\t\"resting\": \""..restingRate[1].."\",\n"
	strOut = strOut .. "\t\"notresting\": \""..restingRate[0].."\",\n"
	strOut = strOut .. "\t\"maxLevel\": "..Rested_misc.maxLevel..",\n"
	strOut = strOut .. "\t\"maxiLvl\": "..Rested_misc.maxiLvl..",\n"
	strOut = strOut .. "\t\"chars\": [\n"

	outTable = {}
	for realm, chars in sorted_pairs(Rested_restedState) do
		for name, c in sorted_pairs(chars) do
			if not c.ignore or c.ignore < os.time() then
				charStruct = MakeCharTable( realm, name, c )
				charOut = {}
				for k,v in sorted_pairs(charStruct) do
					if type(v) == "number" then
						table.insert(charOut, string.format('"%s":%s', EscapeStr(k), v))
					else
						table.insert(charOut, string.format('"%s":"%s"', EscapeStr(k), EscapeStr(v)))
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
	for _, st in sorted_pairs( guildList ) do
		guildLine = string.format('\t\t{"gn":"%s", "rn":"%s"}', EscapeStr(st.guildName), EscapeStr(st.realm) )
		table.insert( outTable, guildLine )
	end
	strOut = strOut .. table.concat( outTable, ",\n" )
	strOut = strOut .. "\n\t]\n"


	strOut = strOut .. "}}"
	return strOut
end
function ExportCSV()
	local report = {}
	local row = {"Realm","Name"}
	for _, fieldStruct in ipairs( Rested_csv.fields ) do
		table.insert( row, fieldStruct[1] )
	end
	table.insert( report, table.concat( row, "," ) )

	for realm, chars in sorted_pairs( Rested_restedState ) do
		for name, charStruct in sorted_pairs( chars ) do
			if not charStruct.ignore or charStruct.ignore < os.time() then
				row = {realm, name}
				for _, fieldStruct in ipairs( Rested_csv.fields ) do
					table.insert( row, (charStruct[fieldStruct[2]] or "") )
				end
				table.insert( report, table.concat( row, "," ) )
			end
		end
	end
	strOut = table.concat( report, "\n" ).."\n"
	return strOut
end

function sorted_pairs( tableIn )
	local keys = {}
	for k in pairs( tableIn ) do table.insert( keys, k ) end
	table.sort( keys )
	local lcv = 0
	local iter = function()
		lcv = lcv + 1
		if keys[lcv] == nil then return nil
		else return keys[lcv], tableIn[keys[lcv]]
		end
	end
	return iter
end

functionList = {
	["xml"] = ExportXML,
	["json"] = ExportJSON,
	["csv"] = ExportCSV
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


