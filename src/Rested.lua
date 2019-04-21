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

MAX_PLAYER_LEVEL_TABLE={
	[0]=60,
	[1]=70,
	[2]=80,
	[3]=85,
	[4]=(time()>1348531200 and 90 or 85),   -- Mists
	[5]=(time()>1415750400 and 100 or 90),
	[6]=(time()>1471737600 and 110 or 100), -- Sep 28, 2016  -- validate this
	[7]=(time()>1534118400 and 120 or 110), -- Aug 13, 2018  -- validate this
}

-- Saved Variables
Rested_restedState = {}

Rested = {}
Rested.commandList = {}  -- ["cmd"] = { ["func"] = reference, ["help"] = {"parameters", "help string"} }
Rested.initFunctions = {}
Rested.onUpdateFunctions = {}
Rested.eventFunctions = {} -- [event] = {}, [event] = {}, ...
Rested.reminderFunctions = {}  -- the functions to call for each alt ( realm, name, struct )
Rested.reminders = {}
Rested.genders={ "", "Male", "Female" }
Rested.filterKeys = { "class", "race", "faction", "lvlNow", "gender" }
--Rested.reportName = ""

-- Load / init functions
function Rested.OnLoad()
	RestedFrame:RegisterEvent( "ADDON_LOADED" )
	RestedFrame:RegisterEvent( "VARIABLES_LOADED" )
	SLASH_RESTED1 = "/rested"
	SlashCmdList["RESTED"] = function( msg ) Rested.Command( msg ); end
end
function Rested.OnUpdate( ... )
	for i, func in pairs( Rested.onUpdateFunctions ) do
		func( ... )
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
		-- create function
		Rested[event] = function( ... )
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
	if( Rested.lastReminderUpdate == nil ) or ( Rested.lastReminderUpdate < time() ) then
		Rested.PrintReminders()
		Rested.lastReminderUpdate = time()
	end
end
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
	Rested.maxLevel = MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()]

	RestedFrame:UnregisterEvent( "ADDON_LOADED" )
	--Rested.Print( "Addon_Loaded End" )
end
function Rested.VARIABLES_LOADED( ... )
	--a, b, c = ...
	--Rested.Print( "VARIABLES_LOADED start( "..(a or "") .." )" )

	-- init unsaved variables
	-- Global
	if not Rested_options.ignoreTime then
		Rested_options.ignoreTime = 3600
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
	-- core data that will always be a part of the records
	Rested_restedState[Rested.realm][Rested.name].class = UnitClass( "player" )
	Rested_restedState[Rested.realm][Rested.name].faction = select( 2, UnitFactionGroup( "player" ) )  -- localized string
	Rested_restedState[Rested.realm][Rested.name].race = UnitRace( "player" )
	Rested_restedState[Rested.realm][Rested.name].gender = Rested.genders[(UnitSex( "player" ) or 0 )]
	Rested_restedState[Rested.realm][Rested.name].updated = time()
	-- ALWAYS remove the ignore timer for the current player
	Rested_restedState[Rested.realm][Rested.name].ignore = nil

	-- init other modules
	for _,func in pairs( Rested.initFunctions ) do
		func()
	end

	RestedFrame:UnregisterEvent( "VARIABLES_LOADED" )
end

--[[
function Rested.PLAYER_ENTERING_WORLD()
	Rested.Print(date("%x %X")..": PLAYER_ENTERING_WORLD" )
	Rested.SaveRestedState()
end
function Rested.PLAYER_XP_UPDATE()
	Rested.Print(date("%x %X")..": PLAYER_XP_UPDATE" )
	Rested.SaveRestedState()
end
Rested.PLAYER_UPDATE_RESTING = Rested.PLAYER_XP_UPDATE
Rested.UPDATE_EXHAUSTION = Rested.PLAYER_XP_UPDATE
Rested.CHANNEL_UI_UPDATE = Rested.PLAYER_XP_UPDATE

--
function Rested.SaveRestedState()
	Rested.Print("Save Rested State");
	Rested.rested = GetXPExhaustion() or 0    -- XP till Exhaustion
	if (Rested.rested > 0) then
		Rested.restedPC = (Rested.rested / UnitXPMax("player")) * 100
	else
		Rested.restedPC = 0
	end

	if (Rested.info) then
		Rested.Print("UPDATE_EXHAUSTION fired at "..time()..": "..Rested.restedPC.."%");
	end
	if (Rested.realm ~= nil) and (Rested.name ~= nil) then
		Rested_restedState[Rested.realm][Rested.name].restedPC = Rested.restedPC;
		Rested_restedState[Rested.realm][Rested.name].updated = time();
		Rested_restedState[Rested.realm][Rested.name].lvlNow = UnitLevel("player");
		Rested_restedState[Rested.realm][Rested.name].xpMax = UnitXPMax("player");
		Rested_restedState[Rested.realm][Rested.name].xpNow = UnitXP("player");
		Rested_restedState[Rested.realm][Rested.name].isResting = IsResting();
		Rested_restedState[Rested.realm][Rested.name].deaths = tonumber(GetStatistic(60) or 0);
		Rested_options["maxDeaths"] = math.max(Rested_options["maxDeaths"] or 0,
													Rested_restedState[Rested.realm][Rested.name].deaths or 0);
	else
		Rested.Print("Realm and name not known");
	end
end
]]