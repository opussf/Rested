RESTED_MSG_ADDONNAME = "Rested Reporter"
RESTED_MSG_VERSION   = GetAddOnMetadata("Rested","Version")
RESTED_MSG_AUTHOR    = GetAddOnMetadata("Rested","Author")

-- Colours
COLOR_RED = "|cffff0000"
COLOR_GREEN = "|cff00ff00"
COLOR_BLUE = "|cff0000ff"
COLOR_PURPLE = "|cff700090"
COLOR_YELLOW = "|cffffff00"
COLOR_ORANGE = "|cffff6d00"
COLOR_GREY = "|cff808080"
COLOR_GOLD = "|cffcfb52b"
COLOR_NEON_BLUE = "|cff4d4dff"
COLOR_END = "|r"

-- Saved Variables
Rested_restedState = {}
Rested_misc = {}

Rested = {}
Rested.commandList = {}  -- ["cmd"] = { ["func"] = reference, ["help"] = {"parameters", "help string"} }
Rested.initFunctions = {}
Rested.onUpdateFunctions = {}
Rested.eventFunctions = {} -- [event] = {}, [event] = {}, ...
Rested.reminderFunctions = {}  -- the functions to call for each alt ( realm, name, struct )
Rested.reminders = {}
Rested.genders={ "", "Male", "Female" }
Rested.filterKeys = { "class", "race", "faction", "lvlNow", "gender" }
Rested.rateStruct = {[0] = {(5/(32*3600)), "-"}, [1] = {(5/(8*3600)), "+"} }
-- report code that needs to show up 'early'
Rested.reportName = ""
Rested.dropDownMenuTable = {}

Rested.maxPlayerLevelTable = {  -- MAX_PLAYER_LEVEL_TABLE is an existing table.  currently goes to 10
	[0]=60,
	[1]=70,
	[2]=80,
	[3]=85,
	[4]=(time()>1348531200 and 90 or 85),   -- Mists
	[5]=(time()>1415750400 and 100 or 90),
	[6]=(time()>1471737600 and 110 or 100), -- Sep 28, 2016  -- validate this
	[7]=(time()>1534118400 and 120 or 110), -- Aug 13, 2018  -- validate this
	[8]=120,
	[9]=120,
	[10]=120,
}

-- Load / init functions
function Rested.OnLoad()
	RestedFrame:RegisterEvent( "ADDON_LOADED" )
	RestedFrame:RegisterEvent( "VARIABLES_LOADED" )
	SLASH_RESTED1 = "/rested"
	SlashCmdList["RESTED"] = function( msg ) Rested.Command( msg ); end
end
function Rested.OnUpdate( elapsed )
	--print( "OnUpdate( "..(elapsed or "nil").." )("..#Rested.onUpdateFunctions..")" )
	for i, func in pairs( Rested.onUpdateFunctions ) do
		func( elapsed )
	end
end

function Rested.Print( msg, showName )
	-- print to the chat frame
	-- set showName to false to suppress the addon name printing
	if (showName == nil) or (showName) then
		msg = COLOR_RED..RESTED_MSG_ADDONNAME.."> "..COLOR_END..msg
	end
	DEFAULT_CHAT_FRAME:AddMessage( msg )
end
function Rested.PrintHelp()
	Rested.Print( RESTED_MSG_ADDONNAME.." ("..RESTED_MSG_VERSION..") by "..RESTED_MSG_AUTHOR )
	for cmd, info in pairs( Rested.commandList ) do
		Rested.Print( string.format( "%s %s %s -> %s",
			SLASH_RESTED1, cmd, info.help[1], info.help[2] ), false )
	end
end

function Rested.ParseCmd( msg )
	msg = string.lower( msg )
	if msg then
		local a,b,c = strfind(msg, "(%S+)")  --contiguous string of non-space characters
		if a then
			return c, strsub(msg, b+2)
		else
			return ""
		end
	end
end
function Rested.Command( msg )
	local cmd, param = Rested.ParseCmd( msg )
	local cmdFunc = Rested.commandList[ cmd ]
	if cmdFunc then
		cmdFunc.func( param )
		return( cmd )
	else
		Rested.PrintHelp()
		return( "help" )
	end
end
function Rested.FormatName( realm, name, useColor )
	-- only use Color formatting if current player
	-- unless useColor is passed as 'false'
	useColor = useColor or ( useColor == nil )
	useColor = useColor and ( realm == Rested.realm and name == Rested.name )
	return string.format( "%s%s:%s%s",
			( useColor and COLOR_GREEN or ""), realm, name, ( useColor and COLOR_END or "" ) )
end
Rested.formatRestedStruct = {}  -- this is here for memory optimization only.  do not rely on this.
function Rested.FormatRested( charStruct )
	-- return formated rested string, restedValue, code (+ / -), timeTillRested (seconds)
	-- rested string is color formated and shows expected current status
	rs = Rested.formatRestedStruct
	rs.timeSince = time() - ( charStruct.updated or charStruct.initAt or 0 )

	rs.restRate, rs.code = unpack( Rested.rateStruct[(charStruct.isResting and 1 or 0)] )
	rs.restAdded = rs.restRate * rs.timeSince
	rs.restedVal = rs.restAdded + ( charStruct.restedPC or 0 )
	rs.restedOutStr = string.format( "%0.1f%%", rs.restedVal )

	if( rs.restedVal >= 150 ) then -- 150% of current is the 'max'
		rs.restedOutStr = COLOR_GREEN.."Fully Rested"..COLOR_END
		rs.timeTillRested = nil
	else
		if( charStruct.xpMax and charStruct.xpNow ) then
			rs.lvlPCLeft = ( ( charStruct.xpMax - charStruct.xpNow ) / charStruct.xpMax ) * 100
			if( rs.restedVal >= rs.lvlPCLeft ) then -- rested beyond the current level
				rs.restedOutStr = COLOR_GREEN..rs.restedOutStr..COLOR_END
			end
			rs.timeTillRested = ( 150 - rs.restedVal ) / rs.restRate   -- restedVal is %, restedRate is %/s,

		end
	end
	return rs.restedOutStr, rs.restedVal, rs.code, rs.timeTillRested
end

function Rested.ForAllChars( action, processIgnored )
	-- loops through all the chars, using action callback to return count, and build the reporting table
	-- include chars that:
	--     are not ignored
	--     match the filter
	--     are ignored, and processIgnored is true
	--     are ignored, processIgnored is true and matches the filter
	-- param: action -- function to call with params ( realm, name, charStuct )
	--               -- This should also insert into Rested.displayList
	--               -- And return the number of lines / chars added to the struct
	-- param: processIgnored -- boolean ( true to include ignored toons )
	-- returns: integer -- the sum of the values returned by action
	-- Rested.displayList = {} -- force this clear
	-- print( "ForAllChars( fn, "..( processIgnored and "true or "nil" )..") " )
	local count = 0
	for realm in pairs( Rested_restedState ) do
		for name, charStruct in pairs( Rested_restedState[realm] ) do
			local match = true
			if( Rested.filter ) then -- there is a filter value
				match = false -- default to false if a filter is given
				if( string.find( string.upper( realm ), Rested.filter ) or
					string.find( string.upper( name ), Rested.filter ) ) then
					match = true
				else -- does not match name or realm, search the keys
					for _, key in pairs( Rested.filterKeys ) do
						if( charStruct[key] and string.find( string.upper( charStruct[key] ), Rested.filter ) ) then
							match = true
						end
					end
				end
			end
			if( charStruct.ignore ) then -- char is being ignored
				Rested.UpdateIgnore( "nil", "nil", charStruct )
				match = match and processIgnored
			end
			if( match ) then
				count = count + ( action( realm, name, charStruct ) or 0 )
			end
		end
	end
	return count
end
function Rested.PruneByAge( struct, ageSeconds )
	-- works with a table in the structure of { [ts] = value, ... }
	-- it will remove any ts that is older than ageSeconds
	local timeCutOff = time() - ageSeconds
	for ts in pairs( struct ) do
		if( ts <= timeCutOff ) then
			struct[ts] = nil
		end
	end
end

-- event callback for modules
function Rested.InitCallback( callback )
	-- these are called from VARIABLES_LOADED.
	-- shortcut to registering event for VARIABLES_LOADED
	table.insert( Rested.initFunctions, callback )
end
function Rested.EventCallback( event, callback )
	-- returns:
	-- 		true if event registered.
	--  	nil if event not registered.
	if( event == "ADDON_LOADED" or event == "VARIABLES_LOADED" ) then
		return
	end

	-- record callback function in table
	if not Rested.eventFunctions[event] then
		Rested.eventFunctions[event] = {}
	end
	table.insert( Rested.eventFunctions[event], callback )

	if not Rested[event] then
		-- create function if it does not exist
		--print( "CREATE function for event: "..event )
		Rested[event] = function( ... )
			--[[
			Rested.Print( string.format( "%s-->%s (%i)<--%s",
					(UnitAffectingCombat( "player" ) and COLOR_RED or ""),
					event,
					#Rested.eventFunctions[event],
					(UnitAffectingCombat( "player" ) and COLOR_END or "") ) )
			]]
			if Rested.eventFunctions[event] then
				for _, func in pairs( Rested.eventFunctions[event] ) do
					func( ... )
				end
				Rested_restedState[Rested.realm][Rested.name].updated = time()
			else
				Rested.Print( "There are no function callbacks registered for this event: ("..event..")" )
			end
		end
	end
	-- register event with the frame
	RestedFrame:RegisterEvent( event )
end
function Rested.OnUpdateCallback( callback )
	-- these are called from OnUpdate
	table.insert( Rested.onUpdateFunctions, callback )
end

-- Reminder callback for modules
-- reminder callback functions are passed realm, name, character table info
-- reminder callback functions should return a table of {[ts] = {"ms1", "ms2", ...}}
function Rested.ReminderCallback( callback )
	table.insert( Rested.reminderFunctions, callback )
end
function Rested.MakeReminderSchedule()
	-- should this filter reminders that are in the past?
	-- or should this rely solely on the registered function?
	Rested.reminders = {}  -- clear the reminders
	for realm in pairs( Rested_restedState ) do
		for name, struct in pairs( Rested_restedState[realm] ) do
			if( struct.ignore ) then -- character is being ignored
				-- do nothing
			else -- not ignored
				for _, func in pairs( Rested.reminderFunctions ) do
					local msgstruct = func( realm, name, struct )
					if type( msgstruct ) == "table" then
						for ts, msgs in pairs( msgstruct ) do
							for _, m in pairs( msgs ) do
								if( Rested.reminders[ts] ) then
									table.insert( Rested.reminders[ts], m )
								else
									Rested.reminders[ts] = { m }
								end
							end
						end
					end
				end
			end
		end
	end
end
Rested.InitCallback( Rested.MakeReminderSchedule )

function Rested.ReminderOnUpdate()
	if not UnitAffectingCombat("player") then
		if( Rested.lastReminderUpdate == nil ) or ( Rested.lastReminderUpdate < time() ) then
			Rested.PrintReminders()
			Rested.lastReminderUpdate = time() + 5
		end
	end
end
Rested.OnUpdateCallback( Rested.ReminderOnUpdate )

function Rested.PrintReminders()
	-- print any reminder that is older than now.
	-- sort them from oldest to newest so that they make sense
	Rested.reminderKeys = {}
	local n = 0
	for k,_ in pairs( Rested.reminders ) do
		n = n + 1  -- lua tables are '1' based
		Rested.reminderKeys[n] = k
	end
	table.sort( Rested.reminderKeys )
	for v = 1, n do
		k = Rested.reminderKeys[v]
		if( k <= time() ) then
			for _, txt in pairs( Rested.reminders[k] ) do
				Rested.Print( txt, false )
			end
			Rested.reminders[k] = nil
		end
	end
end

-- Events
-----------------------------------------
function Rested.ADDON_LOADED( ... )
	-- core init:
	Rested.name = UnitName("player")
	Rested.realm = GetRealmName()
	--Rested.maxLevel = MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()]
	Rested.maxLevel = Rested.maxPlayerLevelTable[GetAccountExpansionLevel()]

	RestedFrame:UnregisterEvent( "ADDON_LOADED" )
	Rested.Print( "Addon_Loaded End" )
end
function Rested.VARIABLES_LOADED( ... )
	--a, b, c = ...
	--Rested.Print( "VARIABLES_LOADED start( "..(a or "") .." )" )

	-- init unsaved variables
	-- Global
	if not Rested_options.ignoreTime then
		Rested_options.ignoreTime = 3600 * 24 * 7
	end
	Rested_options["maxLevel"] = Rested.maxLevel

	-- find or init the realm
	if not Rested_restedState[Rested.realm] then
		Rested_restedState[Rested.realm] = {}
	end

	-- find or init the player
	if not Rested_restedState[Rested.realm][Rested.name] then
		Rested_restedState[Rested.realm][Rested.name] = {
			["initAt"] = time()
		}
	end

	Rested.me = Rested_restedState[Rested.realm][Rested.name]
	-- core data that will always be a part of the records
	Rested.me.class = UnitClass( "player" )
	Rested.me.faction = select( 2, UnitFactionGroup( "player" ) )  -- localized string
	Rested.me.race = UnitRace( "player" )
	Rested.me.gender = Rested.genders[(UnitSex( "player" ) or 0 )]
	Rested.me.updated = time()
	-- ALWAYS remove the ignore timer for the current player
	Rested.me.ignore = nil

	-- init other modules
	for _,func in pairs( Rested.initFunctions ) do
		func()
	end

	RestedFrame:UnregisterEvent( "VARIABLES_LOADED" )
end

