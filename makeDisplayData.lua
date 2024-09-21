#!/usr/bin/env lua
Rested_misc = {
	["maxLevel"] = 80
}
Rested_options = {
	["nagStart"] = 82800,
	["staleStart"] = 864000,
	["mountHistoryAge"] = 2678400,
	["nagTimeOut"] = 90,
	["noNagTime"] = 86400,
	["ignoreTime"] = 60,
}
Rested_restedState = {
	["Test Realm"] = {
		["Maxlevel"] = {
			["isResting"] = true,
			["class"] = "Paladin",
			["race"] = "Human",
			["iLvl"] = 600,
			["xpNow"] = 0,
			["rested"] = 337658,
			["updated"] = "{os.time() - (86400 * 9)}",
			["gold"] = 26090929,
			["restedPC"] = 0,
			["deaths"] = 2600,
			["gender"] = "Female",
			["initAt"] = 1717903682,
			["xpMax"] = 225105,
			["faction"] = "Alliance",
			["totalPlayed"] = 63660,
			["lvlNow"] = 80,
			["Auctions"] = {
				[783832620] = {
					["created"] = "{os.time() - (3600 * 10)}",
					["type"] = "Commodity",
					["version"] = "cache-11-g7cec26e-nothing",
					["duration"] = 172800,
					["total"] = 4400,
				},
				[784084451] = {
					["created"] = "{os.time() - (3600 * 49)}",
					["type"] = "Item",
					["version"] = "cache-11-g7cec26e-nothing",
					["duration"] = 172800,
					["total"] = 3750000,
				},
			},
			["guildRank"] = "Guild Master",
			["guildRep"] = 42000,
			["guildReaction"] = 8,
			["guildRankIndex"] = 0,
			["guildBottom"] = 0,
			["guildTop"] = 42000,
			["guildName"] = "Test Guild",
			["weeklyActivity"] = {
				["Dungeon"] = 3,
				["PvP"] = 3,
				["Raid"] = 3,
			},
			["weeklyResetAt"] = "{os.time() + 86400}",
		},
		["Ignored"] = {
			["ignore"] = "{os.time() + 86200}",
			["isResting"] = true,
			["class"] = "Paladin",
			["race"] = "Human",
			["iLvl"] = 78,
			["xpNow"] = 0,
			["rested"] = 337658,
			["updated"] = "{os.time() - (86400 * 11)}",
			["gold"] = 26090929,
			["restedPC"] = 0,
			["deaths"] = 13,
			["gender"] = "Female",
			["initAt"] = 1717903682,
			["xpMax"] = 225105,
			["faction"] = "Alliance",
			["totalPlayed"] = 63660,
			["lvlNow"] = 39,
		},
		["Staleresting"] = {
			["isResting"] = true,
			["class"] = "Paladin",
			["race"] = "Human",
			["iLvl"] = 78,
			["xpNow"] = 1300,
			["rested"] = 337658,
			["updated"] = "{os.time() - (86400 * 11)}",
			["gold"] = 26090929,
			["restedPC"] = 0,
			["deaths"] = 39,
			["gender"] = "Female",
			["initAt"] = 1717903682,
			["xpMax"] = 225105,
			["faction"] = "Alliance",
			["totalPlayed"] = 63660,
			["lvlNow"] = 39,
		},
		["Stalenoresting"] = {
			["isResting"] = false,
			["class"] = "Paladin",
			["race"] = "Human",
			["iLvl"] = 204,
			["xpNow"] = 130000,
			["rested"] = 337658,
			["updated"] = "{os.time() - (86400 * 11)}",
			["gold"] = 26090929,
			["restedPC"] = 0,
			["deaths"] = 54,
			["gender"] = "Female",
			["initAt"] = 1717903682,
			["xpMax"] = 225105,
			["faction"] = "Alliance",
			["totalPlayed"] = 63660,
			["lvlNow"] = 39,
		},
		["Fullyrested"] = {
			["isResting"] = true,
			["class"] = "Paladin",
			["race"] = "Human",
			["iLvl"] = 102,
			["xpNow"] = 0,
			["rested"] = 337658,
			["updated"] = 1726181131,
			["gold"] = 26090929,
			["restedPC"] = 300,
			["deaths"] = 67,
			["gender"] = "Female",
			["initAt"] = 1717903682,
			["xpMax"] = 225105,
			["faction"] = "Alliance",
			["totalPlayed"] = 63660,
			["lvlNow"] = 39,
		},
		["Halfrested"] = {
			["isResting"] = true,
			["class"] = "Paladin",
			["race"] = "Human",
			["iLvl"] = 300,
			["xpNow"] = 0,
			["rested"] = 337658,
			["updated"] = "{os.time()}",
			["gold"] = 26090929,
			["restedPC"] = 75,
			["deaths"] = 80,
			["gender"] = "Female",
			["initAt"] = 1717903682,
			["xpMax"] = 225105,
			["faction"] = "Alliance",
			["totalPlayed"] = 63660,
			["lvlNow"] = 39,
			["weeklyCacheCount"] = 2,
			["weeklyCacheTS"] = "{os.time()}",
			["tradeCD"] = {
				[447312] = {
					["category"] = "Invent",
					["cdTS"] = "{os.time() + (9600)}",
				},
			},
			["concentration"] = {
				["Khaz Engineering"] = {
					["max"] = 1000,
					["ts"] = "{os.time() - (86400 * 2)}",
					["value"] = 359,
				},
			},
			["weeklyActivity"] = {
				["Dungeon"] = 2,
			},
			["weeklyResetAt"] = "{os.time() + 86400}",
		},
		["Norested"] = {
			["isResting"] = true,
			["class"] = "Paladin",
			["race"] = "Human",
			["iLvl"] = 402,
			["xpNow"] = 0,
			["rested"] = 337658,
			["updated"] = "{os.time()}",
			["gold"] = 26090929,
			["restedPC"] = 0,
			["deaths"] = 93,
			["gender"] = "Female",
			["initAt"] = 1717903682,
			["xpMax"] = 225105,
			["faction"] = "Alliance",
			["totalPlayed"] = 636600,
			["lvlNow"] = 39,
			["weeklyCacheCount"] = 4,
			["weeklyCacheTS"] = "{os.time()}",
			["tradeCD"] = {
				[430345] = {
					["category"] = "Meticulous Experimentation",
					["cdTS"] = "{os.time()}",
				},
			},
		},
	}
}

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
function EscapeStr( strIn )
	-- This escapes a str
	strIn = string.gsub( strIn, "\\", "\\\\" )
	strIn = string.gsub( strIn, "\"", "\\\"" )
	return strIn
end
function WriteTable( file, tableIn, depth )
	if not depth then depth = 1; end
	for k, v in sorted_pairs( tableIn ) do
		if ( type( k ) == "number" ) then
			file:write( ( "%s[%s] = "):format( string.rep("\t", depth), k ) )
		else
			file:write( ("%s[\"%s\"] = "):format( string.rep("\t", depth), k ) )
		end
		if ( type( v ) == "boolean" ) then
			file:write( v and "true" or "false" )
		elseif ( type( v ) == "table" ) then
			file:write( "{\n" )
			WriteTable( file, v, depth+1 )
			file:write( ("%s}"):format( string.rep("\t", depth) ) )
		elseif ( type( v ) == "string" ) then
			file:write( "\""..EscapeStr( v ).."\"" )
		else
			file:write( v )
		end
		file:write( ",\n" )
	end
end

function WriteValue( file, valName, valIn, depth )
	if not depth then depth = 1; end
	file:write( valName.." = " )
	if ( type( valIn ) == "boolean" ) then
		file:write( valIn and "true" or "false" )
	elseif ( type( valIn ) == "string" ) then
		file:write( "\""..EscapeStr( valIn ).."\"" )
	elseif ( type( valIn ) == "table" ) then
		file:write( "{\n" )
		WriteTable( file, valIn, depth )
		file:write( ("%s}\n"):format( string.rep("\t", depth-1 ) ) )
	else
		file:write( valIn )
	end
end

function FilterTable( tableIn, depth )
	if not depth then depth = 1; end
	for k, v in pairs( tableIn ) do
		if type( v ) == "table" then
			FilterTable( v, depth+1 )
		elseif type( v ) == "string" and string.sub( v, 1, 1 ) == "{" and string.sub( v, -1, -1 ) == "}" then
			tableIn[k] = load( "return "..string.sub( v, 2 -2 ) )()[1]
		end
	end
end


FilterTable( Rested_restedState )

print( "Rested_restedState = {")
WriteTable( io.stdout, Rested_restedState )
print( "}" )
print( "Rested_misc = {")
WriteTable( io.stdout, Rested_misc )
print( "}" )
print( "Rested_options = {")
WriteTable( io.stdout, Rested_options )
print( "}" )