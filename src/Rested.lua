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
	[7]=(time()>1537488000 and 120 or 110), -- find this
}

-- Saved Variables
Rested_restedState = {}

Rested = {}
Rested.maxLevel = MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()];
Rested.commandList = {}  -- ["cmd"] = { ["func"] = reference, ["help"] = {"parameters", "help string"} }
Rested.initFunctions = {}
Rested.eventFunctions = {} -- [event] = {}, [event] = {}, ...
Rested.reminderFunctions = {}  -- the functions to call for each alt ( realm, name, struct )
Rested.reminders = {}
Rested.genders={ "", "Male", "Female" }
Rested.filterKeys = { "class", "race", "faction", "lvlNow", "gender" }

-- Load / init functions
function Rested.OnLoad()
	RestedFrame:RegisterEvent( "ADDON_LOADED" )
	SLASH_RESTED1 = "/rested"
	SlashCmdList["RESTED"] = function( msg ) Rested.Command( msg ); end
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
--Rested.CommandList["help"]

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
function Rested.InitCallback( callback )
	table.insert( Rested.initFunctions, callback )
end
function Rested.EventCallback( event, callback )
	--print( "EventCallback( "..event..", )" )
	if( event == "ADDON_LOADED" ) then  -- use InitCallback to modify the ADDON_LOADED event
		return
	end
	if not Rested.eventFunctions[ event ] then
		Rested.eventFunctions[ event ] = {}
	end
	table.insert( Rested.eventFunctions[event], callback )

	Rested[event] = function( ... )
		if Rested.eventFunctions[event] then
			for k, func in pairs( Rested.eventFunctions[event] ) do
				--print( event..": #"..k )
				func( ... )
			end
		else
			Rested.Print( "There are no function callbacks registered for this event: ("..event..")" )
		end
	end
	RestedFrame:RegisterEvent( event )
end
function Rested.ReminderCallback( callback )
	table.insert( Rested.reminderFunctions , callback )
end
function Rested.MakeReminderSchedule()
	Rested.reminders = {} -- clear this
	for realm in pairs( Rested_restedState ) do
		for name, struct in pairs( Rested_restedState[realm] ) do
			if( struct.ignore ) then -- character is bing ignored
				-- Rested.updateIgnore( struct )
			else  -- not ignored
				for _, func in pairs( Rested.reminderFunctions ) do
					local msgstruct = func( realm, name, struct )
					for ts, msgs in pairs( msgstruct ) do
						--print( ts..": ("..ts - now..") " )
						for _, m in pairs( msgs ) do
							--print( "..:"..m )
							if( Rested.reminders[ts] ) then
								--print( "--> Inserting ")
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
function Rested.FormatName( realm, name )
	-- format realm:name
	-- color it green if it is the current toon  <-- Confgure the color?
	isSelf = ( realm == Rested.realm and name == Rested.name )
	return string.format( "%s%s:%s%s",
			( isSelf and COLOR_GREEN or "" ), realm, name, ( isSelf and COLOR_END or "" ) )
end
function Rested.ForAllChars( action, processIgnored )
	-- loops though all the chars, using action to return count, and build the reporting table
	-- include chars that:
	--     are not ignored
	--     match the filter
	--     are ignored, and processIgnored is true
	--     are ignored, processIgnored is true, and matches the filter
	-- param: action -- function to call with params ( realm, name, charStruct )
	--               -- This should also insert into Rested.displayList
	--               -- And return the number of lines / chars added to the struct
	-- param: processIgnored -- boolean ( true to include ignored toons )
	-- returns: integer -- the sum of the values returned by action
	-- Rested.displayList = {}  -- force this clear
	-- print( "ForAllChars( fn, "..( processIgnored and "true" or "nil" ).." )" )
	local count = 0
	for realm in pairs( Rested_restedState ) do
		for name, charStruct in pairs( Rested_restedState[realm] ) do
			local match = true
			if( Rested.filter ) then  -- there is a filter value
				match = false  -- default to false if a filter is given
				-- print( "filter set: "..Rested.filter )
				if( string.find( string.upper( realm ), Rested.filter ) or      -- match realm
					string.find( string.upper( name ), Rested.filter ) ) then   -- match name
					match = true
				else  -- does not match name or realm, search the keys

					for _, key in pairs( Rested.filterKeys ) do
						if( charStruct[key] and string.find( string.upper( charStruct[key] ), Rested.filter ) ) then
							match = true
							--print( "matched "..key )
						end
					end
				end
			end
			if( charStruct.ignore ) then  -- char is being ignored
				--print( "isIgnored" )
				Rested.UpdateIgnore( charStruct )  -- update ignored
				match = match and processIgnored
			end

			--print( match )
			if( match ) then
				count = count + action( realm, name, charStruct )
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

-- Events
------------------------------------------
function Rested.ADDON_LOADED( ... )
	-- core init:
	Rested.name = UnitName("player")
	Rested.realm = GetRealmName()

	-- find or init the realm
	if not Rested_restedState[Rested.realm] then
		Rested_restedState[ Rested.realm ] = {}
	end

	if not Rested_restedState[Rested.realm][Rested.name] then
		Rested_restedState[ Rested.realm ][ Rested.name ] = {
			["initAt"] = time()
		}
	end
	-- core data that will always be a part of the records
	Rested_restedState[Rested.realm][Rested.name].class = UnitClass( "player" )
	Rested_restedState[Rested.realm][Rested.name].faction = select( 2, UnitFactionGroup( "player" ) )  -- localized string
	Rested_restedState[Rested.realm][Rested.name].race = UnitRace( "player" )
	Rested_restedState[Rested.realm][Rested.name].gender = Rested.genders[( UnitSex( "player" ) or 0 )]
	Rested_restedState[Rested.realm][Rested.name].ignore = nil  -- clear any ignore value once visited
	Rested_restedState[Rested.realm][Rested.name].updated = time()

	-- init other modules
	for _,func in pairs( Rested.initFunctions ) do
		func()
	end
	Rested.MakeReminderSchedule()

	if( ... == "Rested" ) then
		RestedFrame:UnregisterEvent( "ADDON_LOADED" )
	end

end

-- Events from frames
------------------------------------------
function Rested.ReminderOnUpdate()
	if( Rested.lastReminderUpdate == nil ) or ( Rested.lastReminderUpdate < time() ) then
		Rested.PrintReminders()
		Rested.lastReminderUpdate = time()
	end
end

-- Reminders
function Rested.PrintReminders()
	-- print the current reminders, removing the reminders is just nice
	if( Rested.reminders[time()]) then
		for _, msg in ipairs( Rested.reminders[time()] ) do
			Rested.Print( msg, false )   -- print, do not prepend addon info
		end
		Rested.reminders[time()] = nil
	end
end

-- Status
function Rested.Status()
	Rested.Print( "Version: "..RESTED_MSG_VERSION )
	Rested.Print( string.format( "Memory usage: %0.2f kB", collectgarbage( "count" ) ) )
	local rCount, nCount = 0, 0
	for r, v in pairs( Rested_restedState ) do
		for n, _ in pairs( v ) do
			nCount = nCount + 1
		end
		rCount = rCount + 1
	end
	Rested.Print( nCount.." toons found on "..rCount.." realms." )
end
Rested.commandList["status"] = { ["func"] = Rested.Status, ["help"] = { "", "Shows status info" } }

-- ignore
-- allows the user to ignore an alt for a bit of time (set with options)
-- sets 'ignore' which is a timestamp for when to stop ignoring.
-- absence of 'ignore' means to not ignore alt.
function Rested.SetIgnore( param )
	--print( "SetIgnore( "..param.." )" )
	if( param and strlen( param ) > 0 ) then
		param = string.upper( param )
		Rested.Print( "SetIgnore: "..param )
		for realm in pairs( Rested_restedState ) do
			for name, struct in pairs( Rested_restedState[realm] ) do
				if( ( string.find( string.upper( realm ), param ) ) or ( string.find( string.upper( name ), param ) ) ) then
					struct.ignore = time() + Rested_options.ignoreTime
					Rested.Print( string.format( "Ignoring %s:%s for %s", realm, name, SecondsToTime( Rested_options.ignoreTime ) ) )
				end
			end
		end
	else
		-- show the report here
	end
end
function Rested.UpdateIgnore( charStruct )
	if( charStruct.ignore  and time() >= charStruct.ignore ) then
		charStruct.ignore = nil
	end
end
Rested.commandList["ignore"] = { ["func"] = Rested.SetIgnore, ["help"] = { "<search>", "Ignore matched chars, or show ignored." } }
-- TODO: determine if there is an event to use to unignore toons
-- TODO: make this report
-- TODO: connect the report with SetIgnore
-- TODO: command to unignore toon

-- remove
-- There is always the requirement to remove alts no longer being tracked
function Rested.RemoveCharacter( param )
	param = string.upper( param )
	-- character name can only be letters, which have been uppered.... staying consistent
	-- realm name just needs to be seperated with a '-', but is the rest of the line
	_, _, dname, drealm = strfind( param, "(%u+)[-]*(.*)" )
	if( strlen( drealm ) == 0 ) then drealm = nil end
	--print( "charName: "..dname.." realmName: "..( drealm or "nil" ) )

	for realm, v in pairs( Rested_restedState ) do
		local realmCharCount = 0
		local realmCharRemoved = 0
		for name, _ in pairs( Rested_restedState[realm] ) do
			-- check to see if the name matches, with a possible partial realm name match
			realmCharCount = realmCharCount + 1
			if( dname == string.upper( name ) and ( string.find( string.upper( realm ), ( drealm or "" ) ) ) )  then
				-- make sure it is not the current character
				if( ( dname == string.upper( Rested.name ) and realm == Rested.realm ) ) then
					-- matching the positive here
					-- the inverse boolean would be a bit crazy to follow
					-- not ( x and y )  == (not x or not y)
				else
					Rested.Print( COLOR_RED.."Removing "..name.."-"..realm.." from Rested."..COLOR_END, false )
					Rested_restedState[realm][name] = nil
					realmCharRemoved = realmCharRemoved + 1
				end
			end
		end
		if( realmCharCount - realmCharRemoved == 0 ) then
			Rested.Print( COLOR_RED.."Pruning realm: "..realm..COLOR_END )
			Rested_restedState[realm] = nil
		end
	end
end
Rested.commandList["rm"] = { ["func"] = Rested.RemoveCharacter, ["help"] = { "name[-realm]", "Remove name[-realm] from Rested." } }


--[[

function Rested.PrintHelp()
	Rested.Print("/Rested max       -> Shows list of max level toons");
	Rested.Print("/Rested stale     -> Shows list of stale toons");
end

]]



--[[
Rested.charList = {};
Rested.lastUpdate = 0;
Rested.lastReminderUpdate = 0;
Rested.showNumBars = 6;
Rested.reportName = "";
Rested.searchKeys = {"class","race","faction","lvlNow","gender","guildName"}
Rested.slotList={"HeadSlot","NeckSlot","ShoulderSlot","BackSlot","ChestSlot","WristSlot","HandsSlot",
		"WaistSlot","LegsSlot","FeetSlot","Finger0Slot","Finger1Slot","Trinket0Slot",
		"Trinket1Slot","MainHandSlot","SecondaryHandSlot"};
Rested.genders={"","Male","Female"};

function Rested.OnLoad()
	RestedFrame:RegisterEvent("PLAYER_XP_UPDATE");
	RestedFrame:RegisterEvent("UPDATE_EXHAUSTION");
	RestedFrame:RegisterEvent("CHANNEL_UI_UPDATE");
	RestedFrame:RegisterEvent("ADDON_LOADED");
	RestedFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	RestedFrame:RegisterEvent("PLAYER_UPDATE_RESTING");
	RestedFrame:RegisterEvent("UNIT_INVENTORY_CHANGED");

	-- Garrison events
	RestedFrame:RegisterEvent("GARRISON_MISSION_STARTED");
	RestedFrame:RegisterEvent("GARRISON_MISSION_FINISHED");
	RestedFrame:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE")
	--RestedFrame:RegisterEvent("GARRISON_MISSION_LIST_UPDATE")
	RestedFrame:RegisterEvent("GARRISON_MISSION_NPC_OPENED")

	-- Garrison Resources event
	RestedFrame:RegisterEvent("VIGNETTE_ADDED")
	RestedFrame:RegisterEvent("VIGNETTE_REMOVED")
	RestedFrame:RegisterEvent("SHOW_LOOT_TOAST")

	-- Not sure what to do with these
--	RestedFrame:RegisterEvent("GARRISON_BUILDING_ACTIVATABLE");
--	RestedFrame:RegisterEvent("GARRISON_BUILDING_ACTIVATED");
--	RestedFrame:RegisterEvent("GARRISON_BUILDING_UPDATE");
--	RestedFrame:RegisterEvent("GARRISON_UPDATE");

	--RestedFrame:RegisterEvent("SHIPMENT_UPDATE");


	--RestedFrame:RegisterEvent("PLAYER_REGEN_ENABLED");

	-- This appears to be fired when a player is gkicked, gquits, etc.
	RestedFrame:RegisterEvent("PLAYER_GUILD_UPDATE")
	ChatFrame_AddMessageEventFilter( "CHAT_MSG_COMBAT_FACTION_CHANGE", Rested.PLAYER_GUILD_UPDATE )

	RestedFrame:RegisterEvent("TIME_PLAYED_MSG")
	RestedFrame:RegisterEvent("PLAYER_LEAVING_WORLD")

	--register slash commands
	SLASH_RESTED1 = "/rested";
	SlashCmdList["RESTED"] = function(msg) Rested.Command(msg); end
	Rested.debug = false;
	Rested.info = false;
end
function Rested.ADDON_LOADED()
	Rested.name = UnitName("player");
	Rested.realm = GetRealmName();

	-- init unsaved variables
	-- Global
	if not Rested_options.ignoreTime then
		Rested_options.ignoreTime = 3600;
	end

	Rested_options["maxLevel"]=Rested.maxLevel;

	-- find or init the realm
	realmFound, playerFound = false, false;
	for k,v in pairs(Rested_restedState) do
		if (k == Rested.realm) then
			realmFound = true;
			break;
		end
	end
	if not realmFound then
		Rested_restedState[Rested.realm] = {};
	end

	-- find or init the player
	for k,v in pairs(Rested_restedState[Rested.realm]) do
		if (k == Rested.name) then
			playerFound = true;
			v.ignore = nil;
			break;
		end
	end
	if not playerFound then
		Rested_restedState[Rested.realm][Rested.name] = {};
		Rested_restedState[Rested.realm][Rested.name].initAt = time();
		Rested_restedState[Rested.realm][Rested.name].restedPC = 0;
		Rested.Print(Rested.name.." added to rested list.");
		Rested.PrintToonCount();
	end
	-- These may change
	Rested_restedState[Rested.realm][Rested.name].class = UnitClass("player");
	Rested_restedState[Rested.realm][Rested.name].faction = select(2, UnitFactionGroup("player"));  -- localized string
	Rested_restedState[Rested.realm][Rested.name].race = UnitRace("player");
	Rested_restedState[Rested.realm][Rested.name].gender = Rested.genders[(UnitSex("player") or 0)];

	Rested_restedState[Rested.realm][Rested.name].updated = time();

	if not Rested.bars then
		Rested.BuildBars();
		--Rested.Print("Built Bars");
	end

	if not Rested_restedState[Rested.realm][Rested.name].race then  -- added these 3 at the same time
		Rested_restedState[Rested.realm][Rested.name].class = UnitClass("player");
		Rested_restedState[Rested.realm][Rested.name].faction = select(2, UnitFactionGroup("player"));  -- localized string
		Rested_restedState[Rested.realm][Rested.name].race = UnitRace("player");
	end

	Rested.MakeReminderSchedule();
	Rested.OptionsPanel_Reset();
	RestedFrame:UnregisterEvent("ADDON_LOADED");

	--Rested.Print("Addon_Loaded End");
end
function Rested.PLAYER_ENTERING_WORLD()
	--Rested.Print(date("%x %X")..":"..event);
	Rested.SaveRestedState();

	if Rested.ForAllAlts( Rested.NagCharacters ) > 0 then
		Rested.commandList.nag();
	end
end
f
function Rested.PLAYER_XP_UPDATE()
	Rested.SaveRestedState()
end
Rested.PLAYER_UPDATE_RESTING = Rested.PLAYER_XP_UPDATE
Rested.UPDATE_EXHAUSTION = Rested.PLAYER_XP_UPDATE
Rested.CHANNEL_UI_UPDATE = Rested.PLAYER_XP_UPDATE

function Rested.GARRISON_UPDATE()
	Rested.Print("GARRISON_UPDATE")
end
function Rested.GARRISON_BUILDING_UPDATE()
	Rested.Print("GARRISON_BUILDING_UPDATE")
end
function Rested.GARRISON_BUILDING_ACTIVATABLE()
	Rested.Print("GARRISON_BUILDING_ACTIVATABLE")
end
function Rested.GARRISON_BUILDING_ACTIVATED()
	Rested.Print("GARRISON_BUILDING_ACTIVATED")
end
function Rested.GARRISON_MISSION_NPC_OPENED()
	-- Prune missions here
	local missions = {}
	C_Garrison.GetInProgressMissions( missions )
	local activeMissionIDs = {}
	for _,m in pairs(missions) do
		activeMissionIDs[m.missionID] = 1
	end
	if Rested_restedState[Rested.realm][Rested.name].missions then
		for pruneID,_ in pairs(Rested_restedState[Rested.realm][Rested.name].missions) do
			--Rested.Print(pruneID.." isActive: "..(activeMissionIDs[pruneID] and "true" or "false"))
			if not activeMissionIDs[pruneID] then
				--Rested.Print("Prune unknown missionID: "..pruneID)
				Rested_restedState[Rested.realm][Rested.name].missions[pruneID] = nil
			end
		end
	end
end
function Rested.GARRISON_MISSION_STARTED()
	--Rested.Print("GARRISON_MISSION_STARTED")
	local missions = {}
	local storeMission = {}

	C_Garrison.GetInProgressMissions( missions )
--	Rested.Print("You have "..#missions.." active missions.")
	for _,m in pairs(missions) do
		local emc = 0 -- Epic Mount Count
		for _,followerID in pairs(m.followers) do
			local abilities = C_Garrison.GetFollowerAbilities( followerID ) -- array of abilities
			for _,ability in pairs(abilities) do
				if ability.id == 221 then  -- ability.id == 221 = Epic Mount
					emc = emc + 1
				end
			end
		end
--		Rested.Print(m.missionID..":"..m.name..(m.inProgress and " is " or " is not ").."in progress."..
--			" Duration: "..m.durationSeconds..". ETC: "..date("%x %X",time()+m.durationSeconds))
		if not Rested_restedState[Rested.realm][Rested.name].missions then
			Rested_restedState[Rested.realm][Rested.name].missions = {}
		end
		if not Rested_restedState[Rested.realm][Rested.name].missions[m.missionID] then  -- only set this if the id is new.
			Rested_restedState[Rested.realm][Rested.name].missions[m.missionID]  = {
					["started"]=time(),
					["duration"]=m.durationSeconds,
					--["etc"] = date("%x %X",time()+m.durationSeconds),
					["etcSeconds"] = time()+ (m.durationSeconds * (1 / (emc>0 and emc*2 or 1))),
					["name"] = m.name,
					["emc"] = ( emc>0 and emc or nil ),
					["followerTypeID"] = m.followerTypeID,
					-- \/ 'extra' mission info
					--["isRare"] = m.isRare,
					--["locPrefix"] = m.locPrefix,
					--["type"] = m.typeAtlas,

			}
		end
		if not Rested_restedState[Rested.realm][Rested.name].knownFollowerTypes then
			Rested_restedState[Rested.realm][Rested.name].knownFollowerTypes = {}
		end
		Rested_restedState[Rested.realm][Rested.name].knownFollowerTypes[m.followerTypeID] = true
	end
	Rested.commandList.missions()
end
function Rested.GARRISON_MISSION_FINISHED( questID, arg2, arg3 )
--	Rested.Print("GARRISON_MISSION_FINISHED")
	local missions = {}
	C_Garrison.GetInProgressMissions( missions )
--	Rested.Print("A mission has finished. qID:"..(questID or "nil").." a2:"..(arg2 or "nil").." a3:"..(arg3 or "nil"))
	Rested.commandList.missions()
end
function Rested.GARRISON_MISSION_COMPLETE_RESPONSE( questID, canComplete, succeeded )
	--	Rested.Print("A mission is being completed. qID:"..(questID or "nil"))
	if Rested_restedState[Rested.realm][Rested.name].missions then
		Rested_restedState[Rested.realm][Rested.name].missions[questID] = nil
		Rested.firstCompleted = nil
		Rested.firstCompletedWho = nil
	end
end
function Rested.SHIPMENT_UPDATE()
	-- This gets spammed when opening a building work order person
	Rested.Print("SHIPMENT_UPDATE")
end
function Rested.VIGNETTE_ADDED( arg1 )
	-- http://wow.gamepedia.com/Events/V
	-- http://wow.gamepedia.com/API_C_Vignettes.GetVignetteInfoFromInstanceID
	local _, _, vName, vObjectIcon = C_Vignettes.GetVignetteInfoFromInstanceID( arg1 )
	--Rested.Print("VIGNETTE_ADDED: "..vName.." ("..(arg1 or nil)..")")
	if Rested.vignettes then
		Rested.vignettes[arg1] = vName
	else
		Rested.vignettes = { [arg1] = vName }
	end
end
function Rested.VIGNETTE_REMOVED( arg1 )
	--Rested.Print("VIGNETTE_REMOVED ("..(arg1 or nil)..")")
	if Rested.vignettes[arg1] then
		--Rested.Print("I know about '"..Rested.vignettes[arg1].."'")
		--Rested.Print("Removing "..Rested.vignettes[arg1])
		Rested.vignettes[arg1] = nil
	end
end
function Rested.SHOW_LOOT_TOAST( ... )
	local typeIdentifier, itemLink, quantity, specID, sex, isPersonal, lootSource = ...;
	--
	-- Rested.Print(string.format("Looted %s (amount: %s) of %s from %s",
	-- 		tostring(typeIdentifier), tostring(quantity), tostring(itemLink), tostring(lootSource))
	-- )
	--
	if lootSource == 10 then -- Garrison Cache
		Rested_restedState[Rested.realm][Rested.name].garrisonCache = time()
	end
end


Rested.commandList = {
	["max"] = function()
			Rested.reportName = "Level "..Rested.maxLevel;
			Rested.ShowReport( Rested.MaxCharacters );
		end,
	["nag"] = function()
			Rested.reportName = "Nag";
			Rested.ShowReport( Rested.NagCharacters );
		end,
	["stale"] = function()
			Rested.reportName = "Stale";
			Rested.ShowReport( Rested.StaleCharacters );
		end,
	["resting"] = function()
			Rested.SaveRestedState();
			Rested.reportName = "Resting";
			Rested.ShowReport( Rested.RestingCharacters );
		end,
	["ignore"] = function(param)
			if (param and strlen(param)>0) then
				Rested.SetIgnore(param);
			else
				Rested.reportName = "Ignored";
				Rested.ShowReport( Rested.IgnoredCharacters, true );  -- true is processIgnored
			end
		end,
	["config"] = function()
		end,
	["all"] = function()
			Rested.reportName = "All";
			Rested.ShowReport( Rested.AllCharacters );
		end,
	["nagtime"] = function( param )
			Rested.setNagTime( param );
		end,
}
function Rested.GetColorFromRange(value, average, range)
	-- takes a value to examine,
	--       an average to examine against,
	--       an acceptable range (+-)
	-- returns a color formatted for wow

	-- ~95% of the data should be within 2sd of the ave
	-- Color the Min and Max from green to red as they get closer to 2sd from the ave.
	-- Red in wow is |cffff0000, Yellow (at 1sd) will be |cffffff00, and Green is |cff00ff00
	-- From Dave, ramp up one till you get to yellow, then ramp down the other.
	-- The task here is to find a smooth way of doing just that.

	-- green to yellow from 0->range/2  :: ramp up red
	-- yellow to red from range/2->range  :: ramp down green
	local distance = abs(average-value);
	local colorStep = (range >2 and 0xff/(range/2) or 1);
	--Rested.Print("range: "..range.." :: range/2: "..(range/2).." :: distance: "..distance);
	--Rested.Print("<range: "..(distance < range and "yes" or "no").." :: <range/2: "..(distance<(range/2) and "yes" or "no"));
	--Rested.Print("Color step: "..colorStep);
	local red = 0;
	if (distance <= (range/2)) then -- add red to green
		red = math.floor(colorStep * distance);
		--Rested.Print(format("Need to add %d (%2x) red to green. (ff%2xff00)", red, red, red));
		return format("|cff%2xff00", red);
	elseif (distance < range) then -- remove green from yellow
		green = math.floor(0xff-(colorStep*(distance-(range/2))));
		--Rested.Print(format("Need to make green %d (%2x) from yellow. (ffff%2x00)", green,green,green));
		return format("|cffff%2x00", green);
	else -- set as red
		--Rested.Print("Just set to red.");
		return "|cffff0000";
	end
end


function Rested.PrintHelp()
	Rested.Print("/Rested           -> Rested Report");
	Rested.Print("/Rested -name     -> Remove name from tracking");
	Rested.Print("/Rested help      -> Shows this menu");
	Rested.Print("/Rested status    -> Shows status info");
	Rested.Print("/Rested max       -> Shows list of max level toons");
	Rested.Print("/Rested stale     -> Shows list of stale toons");
--	Rested.Print("/Rested nagtime # -> Set # of nag days for max lvl toons");
	Rested.Print("/Rested ignore name -> Ignore for "..SecondsToTime(Rested_options.ignoreTime));
end
function Rested.SaveRestedState()
	--Rested.Print("Save Rested State");
	Rested.rested = GetXPExhaustion() or 0;		-- XP till Exhaustion
	if (Rested.rested > 0) then
		Rested.restedPC = (Rested.rested / UnitXPMax("player")) * 100;
	else
		Rested.restedPC = 0;
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
Rested.formatRestedStruct = {}
function Rested.FormatRested(charStruct)
	-- return formated rested string, code (+ / -), timeTillRested (seconds)
	-- rested string is color formated and shows expected current status
	Rested.formatRestedStruct.timeSince = time() - charStruct.updated;
	Rested.formatRestedStruct.restRate = (5/(32*3600));  -- quarter rate 5% every 32 hours
	Rested.formatRestedStruct.code = "-";
	if charStruct.isResting then  -- http://www.wowwiki.com/Rested
		Rested.formatRestedStruct.restRate = (5/(8*3600));  -- 5% every 8 hours (5 seems a tad too much)
		Rested.formatRestedStruct.code = "+";
	end

	Rested.formatRestedStruct.restAdded = Rested.formatRestedStruct.restRate * Rested.formatRestedStruct.timeSince;
	Rested.formatRestedStruct.restedVal = charStruct.restedPC + Rested.formatRestedStruct.restAdded;
	Rested.formatRestedStruct.restedOutStr = string.format("%0.1f%%", Rested.formatRestedStruct.restedVal);
	Rested.formatRestedStruct.timeTillRested = 0;
	if (Rested.formatRestedStruct.restedVal >= 150) then
		if ((Rested.realm == charStruct.realm) and (Rested.name == charStruct.name)) then
			Rested.formatRestedStruct.restedOutStr = COLOR_GREEN.. Rested.formatRestedStruct.restedOutStr .. COLOR_END;
		else
			Rested.formatRestedStruct.restedOutStr = COLOR_GREEN.."Fully Rested"..COLOR_END;
		end
	else
		if (charStruct.xpNow) then -- did not always store xpNow
			Rested.formatRestedStruct.lvlPCLeft = ((charStruct.xpMax - charStruct.xpNow) / charStruct.xpMax) * 100;
			if (Rested.formatRestedStruct.restedVal >= Rested.formatRestedStruct.lvlPCLeft) then
				Rested.formatRestedStruct.restedOutStr = COLOR_GREEN.. Rested.formatRestedStruct.restedOutStr ..COLOR_END;
			end
		end
		Rested.formatRestedStruct.timeTillRested =
			(150-Rested.formatRestedStruct.restedVal) / Rested.formatRestedStruct.restRate;
	end
	return Rested.formatRestedStruct.restedOutStr, Rested.formatRestedStruct.restedVal,
		Rested.formatRestedStruct.code, Rested.formatRestedStruct.timeTillRested;
end
function Rested.RestingCharacters( realm, name, charStruct )
	-- takes the realm, name, charStruct
	-- appends to the global Rested.charList
	-- returns 1 on success, 0 on fail
	if (charStruct.lvlNow ~= Rested.maxLevel and charStruct.restedPC < 150) or
			(realm == Rested.realm and name == Rested.name) then
		local restedStr, restedVal, code, timeTillRested = Rested.FormatRested( charStruct );
		Rested.strOut = string.format("% 2d%s %s", charStruct.lvlNow, code, restedStr);
		if timeTillRested then
			Rested.strOut = Rested.strOut.." "..SecondsToTime(timeTillRested);
		end

		rn = realm..":"..name;
		if (realm == Rested.realm and name == Rested.name) then
			rn = COLOR_GREEN..rn..COLOR_END;
		end
		Rested.strOut = Rested.strOut..": "..rn;
		table.insert( Rested.charList, {restedVal, Rested.strOut} );
		return 1;
	end
	return 0;
end
Rested.reportFunction = Rested.RestingCharacters;
function Rested.StaleCharacters( realm, name, charStruct )
	-- takes the realm, name, charStruct
	-- appends to the global Rested.charList
	-- returns 1 on success, 0 on fail
	local stale = Rested_options.maxStale * 86400;
	timeSince = time() - charStruct.updated;
	if (timeSince > stale) then
		Rested.strOut = format("%d :: %s : %s:%s", charStruct.lvlNow, SecondsToTime(timeSince), realm, name);
		table.insert(Rested.charList, {timeSince, Rested.strOut});
		return 1;
	end
	return 0;
end
function Rested.NagCharacters( realm, name, charStruct )
	-- takes the realm, name, charStruct
	-- appends to the global Rested.charList
	-- returns 1 on success, 0 on fail
	local timeSince = time() - charStruct.updated;
	if (charStruct.lvlNow == Rested.maxLevel and
			timeSince >= Rested_options.maxCutOff*86400 and
			timeSince <= Rested_options.maxStale * 86400) then
		Rested.strOut = format("%d :: %s : %s:%s", charStruct.lvlNow, SecondsToTime(timeSince), realm, name);
		table.insert(Rested.charList, {(timeSince/(Rested_options.maxStale*86400))*150, Rested.strOut});
		return 1;
	end
	return 0;
end
function Rested.MaxCharacters( realm, name, charStruct )
	-- takes the realm, name, charStruct
	-- appends to the global Rested.charList
	-- returns 1 on success, 0 on fail
	if (charStruct.lvlNow == Rested.maxLevel) then
		timeSince = time() - charStruct.updated;
		rn = realm..":"..name;
		if (realm == Rested.realm and name == Rested.name) then
			rn = COLOR_GREEN..rn..COLOR_END;
			Rested.strOut = rn;
		else
			Rested.strOut = SecondsToTime(timeSince) ..": ".. rn;
		end
		table.insert( Rested.charList, {(timeSince / (Rested_options.maxStale*86400)) * 150, Rested.strOut} );
		return 1;
	end
	return 0;
end
function Rested.IgnoredCharacters( realm, name, charStruct )
	if (charStruct.ignore) then
		timeToGo = charStruct.ignore - time();
		Rested.strOut = SecondsToTime(timeToGo) ..": "..realm..":"..name;
		table.insert( Rested.charList, {(timeToGo/Rested_options.ignoreTime)*150, Rested.strOut} );
		return 1;
	end
	return 0;
end
function Rested.AllCharacters( realm, name, charStruct )
	-- 80 (15.5%): Realm:Name
	rn = realm..":"..name;
	if (realm == Rested.realm and name == Rested.name) then
		rn = COLOR_GREEN..rn..COLOR_END;
	end
	Rested.strOut = string.format("%d (%s): %s",
		charStruct.lvlNow,
		--(charStruct.xpNow / charStruct.xpMax) * 100,
		select(1,Rested.FormatRested(charStruct)),
		rn);
	table.insert( Rested.charList, {(charStruct.lvlNow / Rested.maxLevel) * 150, Rested.strOut} );
	return 1;
end
function Rested.setNagTime( param )
	-- need to check for integer value
	a = strfind( param, "[^0-9]" );
	if a then
		Rested_Debug("Bad Data. Nothing changed.");
	else
		Rested_options.maxCutOff = param * 1;
		Rested.Print("Max level nagtime set to "..Rested_options.maxCutOff.." days.");
	end
end
function Rested.PrintSkills()
	numskills =	GetNumSkillLines();
	local profs = nil;
	for i=1, numskills do
		skillname, isHeader, isExpanded, skillRank, _, _, skillMaxRank = GetSkillLineInfo(i);
		if isHeader then
			profs = (skillname == "Professions");
		end
		if not isHeader and profs then
			Rested.Print(skillname..": ".. skillRank.."/"..skillMaxRank);
		end
	end
end
function Rested.Search( toFind )
	toFind = string.upper( toFind );
	count = 0;
	charList = {};
	for r,v in pairs( Rested_restedState ) do
		for n,v in pairs( Rested_restedState[r] ) do
			if (string.find(string.upper(r), toFind)) or (string.find(string.upper(n), toFind)) then
				Rested.strOut = v.lvlNow .." :: ".. SecondsToTime(time() - v.updated) .." : ".. r ..":".. n;
				if v.lvlNow < Rested.maxLevel then
					Rested.strOut = string.format("%s (%0.2f%%)", Rested.strOut, v.restedPC);
				end
				table.insert(charList, {time() - v.updated, Rested.strOut});
				count = count + 1;
			end
		end
	end
	if (count > 0) then
		Rested.Print("Toons found");
		table.sort(charList, function(a, b) return a[1] < b[1] end);
		table.foreach(charList, function(k, v) Rested.Print(" "..v[2], false) end);
	else
		Rested.Print("No tracked toons were found.", false);
	end
end





Rested.dropDownMenuTable = {
	["Resting"] = "resting",
	["All"] = "all",
	["Max"] = "max",
	["Nag"] = "nag",
	["Stale"] = "stale",
	["Ignored"] = "ignore",
}
function Rested.DropDownOnLoad( self )
	UIDropDownMenu_Initialize( RestedFrame.DropDownMenu, Rested.DropDownInitialize );
	UIDropDownMenu_JustifyText( RestedFrame.DropDownMenu, "LEFT" );
end
function Rested.DropDownInitialize( self, level )
	local info = UIDropDownMenu_CreateInfo();
	for text, f in pairs( Rested.dropDownMenuTable ) do
		info = UIDropDownMenu_CreateInfo();
		info.text = text;
		info.notCheckable = true;
		info.arg1 = f;
		info.func = Rested.DropDownOnClick;

		UIDropDownMenu_AddButton(info, level);
	end
end
function Rested.DropDownOnClick( self, func )
	Rested.commandList[func]();
end









function Rested.BarClick(bar, button)
	Rested.Print("Clicked on a bar:"..button);
	if button == "RightButton" then
		Rested.Print("Showing");
		Rested_BarMenuFrame:Show();
	end
end






]]