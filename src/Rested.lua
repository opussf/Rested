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
Rested.commandList = {}  -- ["func"] = reference, ["help"] = help string
Rested.initFunctions = {}
Rested.eventFunctions = {} -- [event] = {}, [event] = {}, ...
Rested.reminderFunctions = {}  -- the functions to call for each alt ( realm, name, struct )
Rested.reminders = {}
Rested.genders={ "", "Male", "Female" }

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
						print( ts..": ("..ts - now..") " )
						for _, m in pairs( msgs ) do
							print( "..:"..m )
							if( Rested.reminders[ts] ) then
								print( "--> Inserting ")
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

--[[
function Rested.ForAllAlts( action, processIgnored )
	-- loops through all the alts, using the action to return count and to build
	-- param: action -- function to pass (realm, name, charStruct)
	-- param: processIgnored -- boolean (true to include ignored toons)
	-- returns: integer -- count of entries in the table
	-- Rested.charList
	Rested.charList = {};
	count = 0;
	for realm in pairs(Rested_restedState) do
		for name,vals in pairs(Rested_restedState[realm]) do
			if (vals.ignore) then  -- character is being ignored
				Rested.updateIgnore(vals);
				if processIgnored then
					count = count + action( realm, name, vals );
				end
			elseif (Rested.filter) then -- there is a filter value

				if (string.find(string.upper(realm), Rested.filter)  or        -- match realm
					string.find(string.upper(name), Rested.filter)) then      -- match name
					count = count + action( realm, name, vals );
				else  -- search the keys that exist that I'm searching
					match = false;
					for _, key in pairs( Rested.searchKeys ) do
						if (vals[key] and string.find(string.upper(vals[key]), Rested.filter)) then
							match = true;
						end
					end
					if match then
						count = count + action( realm, name, vals );
					end
				end
			else  -- no filter class, not ignored
				count = count + action(realm, name, vals);
			end
		end
	end
	return count;
end
]]

-- Events
------------------------------------------
function Rested.ADDON_LOADED()
	-- core init:
	Rested.name = UnitName("player");
	Rested.realm = GetRealmName();

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
	RestedFrame:UnregisterEvent( "ADDON_LOADED" )
end





--[[
	func = Rested.commandList[cmd];
	if func then
		func(param);
	else
		if (cmd ~= nil) and (string.sub(cmd,1,1) == "-") then
			Rested.RemoveFromRested( string.sub(cmd,2) );
			return;
		end
		Rested.commandList["resting"]();
	end
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
function Rested.UNIT_INVENTORY_CHANGED()
	Rested.ScanInv()
end
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

function Rested.Print( msg, showName)
	-- print to the chat frame
	-- set showName to false to suppress the addon name printing
	if (showName == nil) or (showName) then
		msg = COLOR_RED..RESTED_MSG_ADDONNAME.."> "..COLOR_END..msg;
	end
	DEFAULT_CHAT_FRAME:AddMessage( msg );
end
function Rested.PrintStatus()
	Rested.Print("Version: "..RESTED_MSG_VERSION);
	Rested.Print("Memory usage: "..collectgarbage("count").." kB");
	--Rested.Print("Max Level nagtime: "..COLOR_GREEN..Rested_options.maxCutOff..COLOR_END.." Days.");
	--Rested.Print("Max Level stale time: "..COLOR_GREEN..Rested_options.maxStale..COLOR_END.." Days.");
	Rested.PrintToonCount();
end
function Rested.GetToonCount()
	local realmCount = 0;
	local nameCount = 0;
	for r, v in pairs(Rested_restedState) do
		for n, _ in pairs(v) do
			nameCount = nameCount + 1;
		end
		realmCount = realmCount + 1;
	end
	return nameCount, realmCount;
end
function Rested.PrintToonCount()
	local nameCount, realmCount = Rested.GetToonCount();
	Rested.Print(nameCount .." toons found on ".. realmCount .." realms.");
end
function Rested_Debug( msg )
	-- Print Debug Messages
	if Rested.debug then
		msg = "debug-"..msg;
		Rested.Print( msg );
	end
end

Rested.commandList = {
	["help"] = function() Rested.PrintHelp(); end,
	["status"] = function() Rested.PrintStatus(); end,
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
function Rested.ScanInv()
	Rested_options.iLvlHistory = Rested_options.iLvlHistory or {};
	Rested.lastScan = Rested.lastScan or time()+10;
	Rested.scanCount = Rested.scanCount or 0;
	--Rested.Print("lastScan ::"..(Rested.lastScan+5).."<:"..time());
	if (Rested.lastScan+1 <= time()) then
		Rested.lastScan=time();
		--Rested.Print(Rested.realm..":"..Rested.name);
		Rested.scanCount = Rested.scanCount + 1;
		local currentVal = select( 2, GetAverageItemLevel() )
		Rested_restedState[Rested.realm][Rested.name].iLvl = math.floor(currentVal);
		Rested_options["maxiLvl"] = math.max(Rested_options["maxiLvl"] or 0, math.floor(currentVal));

		Rested_options.iLvlHistory[Rested.lastScan] = currentVal;
		local timeCutOff = time() - Rested_options.iLvlMaxAge;  -- one hour

		-- Calculate stats for display
		local sum,min,minTS,ave,max,count,delcount,vm,sd = 0,nil,nil,0,0,0,0,0,0;
		local currValCount = 0;
		for ts, value in pairs(Rested_options.iLvlHistory) do
			if (value == currentVal) then currValCount = currValCount + 1; end
			if (ts > timeCutOff) then
				sum = sum + value;
				min = math.min(value,min or value);
				max = math.max(value,max);
				minTS = math.min(ts,minTS or ts);
				count = count + 1;
			else
				Rested_options.iLvlHistory[ts]=nil;
				delcount = delcount + 1;
			end
		end
		ave = sum/count;
		sum = 0;
		for _,value in pairs(Rested_options.iLvlHistory) do
			vm = value - ave;
			sum = sum + (vm * vm);
		end
		sd = (count > 1) and math.sqrt( sum / (count-1) ) or 0;
		local sdColor = "|cffffffff";
		if Rested.lastSD then
			if (sd > Rested.lastSD) then sdColor = COLOR_RED; end
			if (sd < Rested.lastSD) then sdColor = COLOR_GREEN; end
		end
		Rested.lastSD = sd;

		local currentColor = Rested.GetColorFromRange( currentVal, ave, 2*sd);
		local minColor = Rested.GetColorFromRange(min, ave, 2*sd);
		local maxColor = Rested.GetColorFromRange(max, ave, 2*sd);

		RestediLvlFrame:Show()
		RestediLvl_PositiveSD:SetMinMaxValues( min, max )
		RestediLvl_Ave:SetMinMaxValues( min, max )
		RestediLvl_NegativeSD:SetMinMaxValues( min, max )

		RestediLvl_PositiveSD:SetValue( ave+sd )
		RestediLvl_Ave:SetValue( ave )
		RestediLvl_NegativeSD:SetValue( ave-sd )

		local strOut = format("iLvl: %s%i|r (%s%i|r / %i / %s%i|r / %s%0.2f%s) %i/%i/-%i (%s) %0.2f%%",
				currentColor, math.floor(currentVal),
				minColor,min,ave,
				maxColor,max,
				sdColor,sd,COLOR_END,
				--Rested.scanCount,
				currValCount,
				count, delcount,
				date("%H:%M", time()+(minTS-timeCutOff) ),
				(currValCount/count)*100 );
		RestediLvl_String:SetText( strOut )
		--Rested.Print(time().." + ("..minTS.." - "..timeCutOff..") = "..(time()+(minTS-timeCutOff)))
		--Rested.Print( strOut, false )
	end
end
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


-- slash function handle
function Rested.Command_old(msg)
	--cmd will be nothing
	local cmd, param = Rested.ParseCmd(msg);
	cmd = string.lower(cmd);

	if (cmd == "skills") then
		Rested.PrintSkills();
	elseif (cmd == "friend") then
		Rested.Friend();
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
function Rested.RemoveFromRested( cName )
	cName = string.upper( cName );
	if (cName == string.upper(Rested.name)) then
		Rested.Print("Cannot remove current toon from rested list");
		return
	end
	local numRemoved = 0;
	for r,v in pairs( Rested_restedState ) do
		for n,v in pairs( Rested_restedState[r] ) do
			if (string.upper( n ) == cName) then
				Rested.Print(COLOR_RED.."Removing "..r..":"..n.." from the rested list"..COLOR_END);
				Rested_restedState[r][n] = nil;
				numRemoved = numRemoved + 1;
			end
		end
		local count = 0;
		for n,v in pairs( Rested_restedState[r] ) do
			count = count + 1;
		end
		if (count == 0) then
			Rested.Print(COLOR_RED.."Pruning realm "..r..COLOR_END);
			Rested_restedState[r] = nil;
		end
	end
	if ( numRemoved == 0 ) then
		Rested.Print("No rested record was removed");
	end
	Rested.PrintToonCount();
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
function Rested_Friend()
	-- adds alts to the friend list
	for n, v in pairs(Rested_restedState[Rested.realm]) do
		if (n ~= Rested.name) then
			found = nil;
			for i=1, GetNumFriends() do
				name = GetFriendInfo(i);
				if n == name then found = true; end
			end
			if not found then
				Rested.Print("Adding: "..n);
				AddFriend(n);
			end
		end
		for i=1, GetNumFriends() do
			name, lvl, class, loc, connected, status, note = GetFriendInfo(i);
			if (name == n) then
--				Rested.Print("Update "..n);
				SetFriendNotes(i, "Last on: "..COLOR_GREEN..date("%x", v.updated)..COLOR_END);
			end
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
function Rested.BuildBars()
	Rested.bars = {};
	for idx = 1,Rested.showNumBars do
		Rested.bars[idx] = {};
		local item = CreateFrame("StatusBar", "Rested_ItemBar"..idx, RestedScrollContents, "Rested_RestedBarTemplate");
		Rested.bars[idx].bar = item;
		if idx==1 then
			item:SetPoint("TOPLEFT", "RestedScrollFrame", "TOPLEFT", 5, -5);
		else
			item:SetPoint("TOPLEFT", Rested.bars[idx-1].bar, "BOTTOMLEFT", 0, 0);
		end
		item:SetMinMaxValues(0, 150);
		item:SetValue(0);
		--item:SetScript("OnClick", Rested.BarClick);
		local text = item:CreateFontString("Rested_ItemText"..idx, "OVERLAY", "Rested_RestedBarTextTemplate");
		Rested.bars[idx].text = text;
		text:SetPoint("TOPLEFT", item, "TOPLEFT", 5, 0);
	end
end
function Rested.ShowReport( report )
	Rested.reportFunction = report;
	RestedFrame:Show();
	Rested.ResetFrame();
	Rested.UpdateFrame();
	UIDropDownMenu_SetText( RestedFrame.DropDownMenu, Rested.reportName );
end
function Rested.OnDragStart()
	RestedFrame:StartMoving();
end
function Rested.OnDragStop()
	RestedFrame:StopMovingOrSizing();
end
function Rested.ResetFrame()
	for i = 1, Rested.showNumBars do
		Rested.bars[i].bar:SetValue(0);
		Rested.bars[i].text:SetText("");
		Rested.bars[i].bar:Hide();
	end
end
function Rested.UpdateFrame()
	if (RestedFrame:IsVisible()) then
		count = Rested.ForAllAlts( Rested.reportFunction, (Rested.reportName == "Ignored") );
		RestedFrame_TitleText:SetText("Rested - "..Rested.reportName.." - "..count);
		if count > 0 then
			table.sort( Rested.charList, function( a,b ) return a[1] > b[1] end );
			offset = math.floor(RestedScrollFrame_VSlider:GetValue());
			for i = 1, Rested.showNumBars do
				idx = i+offset;
				if idx<=count then
				--if i<=count then
				--	idx = i+offset;
					Rested.bars[i].bar:SetValue(max(0,Rested.charList[idx][1]));
					Rested.bars[i].text:SetText(Rested.charList[idx][2]);
					Rested.bars[i].bar:Show();
				else
					Rested.bars[i].bar:Hide();
				end
			end
		elseif (Rested.bars and count == 0) then
			for i = 1, Rested.showNumBars do
				Rested.bars[i].bar:Hide();
			end
		end
		RestedScrollFrame_VSlider:SetMinMaxValues(0, max(0,count-Rested.showNumBars));
	end
end
function Rested.OnUpdate()
	-- only gets called when this is shown
	if Rested.lastUpdate + 1 <= time() then
		Rested.lastUpdate = time();
		Rested.UpdateFrame();
		-- if (Rested.maxTimeLeftSeconds) then Rested.Print(Rested.maxTimeLeftSeconds) end
	end
end
function Rested.SetIgnore(param)
	param = string.upper(param);
	Rested.Print("SetIgnore: "..param);
	for realm in pairs( Rested_restedState ) do
		for name,vals in pairs( Rested_restedState[realm] ) do
			if ((string.find(string.upper(realm), param)) or (string.find(string.upper(name), param))) then
				vals.ignore = time() + Rested_options.ignoreTime;
				Rested.Print(format("Ignoring %s:%s for %s", realm, name, SecondsToTime(Rested_options.ignoreTime)));
			end
		end
	end
end
function Rested.updateIgnore( alt )
	if (alt.ignore and time()>=alt.ignore) then
		alt.ignore = nil;
	end
end
function Rested.updateFilter()
	if RestedEditBox:GetNumLetters() then
		Rested.filter = string.upper(RestedEditBox:GetText());
		--Rested.Print("updateFilter ("..RestedEditBox:GetNumLetters().."):"..Rested.filter);
		Rested.UpdateFrame();
	else
		Rested.filter = nil;
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
-- Reminder schedule code
Rested.reminderValues = {
	[0] = COLOR_GREEN.."RESTED:"..COLOR_END.." %s:%s is now fully rested.",
	[60] = COLOR_GREEN.."RESTED:"..COLOR_END.." 1 minute until %s:%s is fully rested.",
	[300] = COLOR_GREEN.."RESTED:"..COLOR_END.." 5 minutes until %s:%s is fully rested.",
	[600] = COLOR_GREEN.."RESTED:"..COLOR_END.." 10 minutes until %s:%s is fully rested.",
	[900] = COLOR_GREEN.."RESTED:"..COLOR_END.." 15 minutes until %s:%s is fully rested.",
	[1800] = COLOR_GREEN.."RESTED:"..COLOR_END.." 30 minutes until %s:%s is fully rested.",
	[3600] = COLOR_GREEN.."RESTED:"..COLOR_END.." 1 hour until %s:%s is fully rested.",
	[7200] = COLOR_GREEN.."RESTED:"..COLOR_END.." 2 hours until %s:%s is fully rested.",
	[14400] = COLOR_GREEN.."RESTED:"..COLOR_END.." 4 hours until %s:%s is fully rested.",
	[21600] = COLOR_GREEN.."RESTED:"..COLOR_END.." 6 hours until %s:%s is fully rested.",
	[28800] = COLOR_GREEN.."RESTED:"..COLOR_END.." 8 hours until %s:%s is fully rested.",
	[43200] = COLOR_GREEN.."RESTED:"..COLOR_END.." 12 hours until %s:%s is fully rested.",
	[57600] = COLOR_GREEN.."RESTED:"..COLOR_END.." 16 hours until %s:%s is fully rested.",
	[86400] = COLOR_GREEN.."RESTED:"..COLOR_END.." 1 day until %s:%s is fully rested.",
	[172800] = COLOR_GREEN.."RESTED:"..COLOR_END.." 2 days until %s:%s is fully rested.",
	[432000] = COLOR_GREEN.."RESTED:"..COLOR_END.." 5 days until %s:%s is fully rested.",
}
Rested.missionReminderValues = {
	[0] = COLOR_RED.."MISSION:"..COLOR_END.." A mission has finished for %s-%s.",
	[300] = COLOR_RED.."MISSION:"..COLOR_END.." 5 minutes until a mission finishes for %s-%s.",
	[600] = COLOR_RED.."MISSION:"..COLOR_END.." 10 minutes until a mission finishes for %s-%s.",
	[900] = COLOR_RED.."MISSION:"..COLOR_END.." 15 minutes until a mission finishes for %s-%s.",
	[1800] = COLOR_RED.."MISSION:"..COLOR_END.." 30 minutes until a mission finishes for %s-%s.",
}
Rested.cacheReminderValues = {
	[5] = COLOR_GREEN.."G-CACHE:"..COLOR_END.." Garrison cache is ready for %s-%s.",
	[12] = COLOR_GREEN.."G-CACHE:"..COLOR_END.." 12 resources for %s-%s.",
	[100] = COLOR_GREEN.."G-CACHE:"..COLOR_END.." 100 resources for %s-%s.",
	[144] = COLOR_GREEN.."G-CACHE:"..COLOR_END.." 144 resources for %s-%s.", -- 1 day
	[200] = COLOR_GREEN.."G-CACHE:"..COLOR_END.." 200 resources for %s-%s.",
	[288] = COLOR_ORANGE.."G-CACHE:"..COLOR_END.." 288 resources for %s-%s.", -- 2 days
	[300] = COLOR_ORANGE.."G-CACHE:"..COLOR_END.." 300 resources for %s-%s.",
	[400] = COLOR_ORANGE.."G-CACHE:"..COLOR_END.." 400 resources for %s-%s.",
	[432] = COLOR_RED.."G-CACHE:"..COLOR_END.." 432 resources for %s-%s.", -- 3 days
	[500] = COLOR_RED.."G-CACHE:"..COLOR_END.." Is full for %s-%s.", -- Full
}
function Rested.MakeReminderSchedule()
	Rested.reminders = {};
	for realm in pairs(Rested_restedState) do
		for name, charStruct in pairs(Rested_restedState[realm]) do
			if (charStruct.ignore) or
				(realm == Rested.realm and name == Rested.name) or
				(charStruct.lvlNow == Rested.maxLevel) then
				-- skip ignored, this char, or maxLvl chars.
				-- do nothing... Nicer logic to do it this way
				--Rested.Print(string.format("Do not process %s:%s", realm, name));
			else
				now = time();
				timeSince = now - charStruct.updated;
				if charStruct.isResting then  -- http://www.wowwiki.com/Rested
					restRate = (5/(8*3600));  -- 5% every 8 hours (5 seems a tad too much)
				else
					restRate = (5/(32*3600));  -- quarter rate 5% every 32 hours
				end
				restAdded = restRate * timeSince;
				restedVal = charStruct.restedPC + restAdded;
				restedAt = now + ((150-restedVal) / restRate);
				--Rested.Print(string.format("%s:%s rested at %s", realm, name, date("%x %X", restedAt)));
				for diff, format in pairs(Rested.reminderValues) do
					reminderTime = string.format("%i",(restedAt - diff)) * 1;
					if (reminderTime > now) then
						if (not Rested.reminders[reminderTime]) then
							Rested.reminders[reminderTime] = {};
						end
						table.insert( Rested.reminders[reminderTime], {["msg"]=string.format(format, realm, name)});
					end
				end
				if charStruct.xpNow then
					needPC = 100 - ((charStruct.xpNow / charStruct.xpMax) * 100);
					lvlRestedAt = string.format("%i", now + ((needPC - restedVal) / restRate)) *1;
					if (lvlRestedAt > now) then
						if (not Rested.reminders[lvlRestedAt]) then
							Rested.reminders[lvlRestedAt] = {};
						end
						table.insert( Rested.reminders[lvlRestedAt],
								{["msg"]=string.format("%s:%s is rested to end of level.", realm, name)});
						Rested.Print(string.format("Level %s:%s at %s",
								realm, name, date("%x %X",lvlRestedAt)));
					end
				end
				if charStruct.missions then
					for i,m in pairs(charStruct.missions) do
						local completedAtSeconds =  m.started + (m.duration * (1 / ((m.emc and m.emc>0) and m.emc*2 or 1)))
						if ( m.emc and m.emc>0 ) then Rested.Print(m.name.." has "..m.emc.." epic mounts to finish at: "..date("%x %X",completedAtSeconds)) end
						for diff, format in pairs(Rested.missionReminderValues) do
							local reminderTime = completedAtSeconds - diff  -- reminder time is before completion
							if (reminderTime > now) then -- yet, still in the future
								if (not Rested.reminders[reminderTime]) then
									Rested.reminders[reminderTime] = {}
								end
								table.insert( Rested.reminders[reminderTime], {["msg"]=string.format(format, name, realm)})
							end -- reminder time in future
						end -- reminder times to watch
					end
				end -- Missions
				if charStruct.garrisonCache then
					for targetAmount, format in pairs(Rested.cacheReminderValues) do
						local reminderTime = Rested.GcacheWhenAt( targetAmount, charStruct.garrisonCache )
						if (reminderTime > now) then -- yet, still in the future
							if (not Rested.reminders[reminderTime]) then
								Rested.reminders[reminderTime] = {}
							end
							table.insert( Rested.reminders[reminderTime], {["msg"]=string.format(format, name, realm)})
						end -- reminder time in future
					end
				end -- garrisonCache
			end  -- Ignore Check
		end -- Name Loop
	end -- Realm loop
end
function Rested.PrintReminders()
	if (Rested.reminders[time()]) then
		--Rested.Print("=+=+=+=+=+=+=+=+=+=+", false);
		for i, struct in ipairs(Rested.reminders[time()]) do
			Rested.Print(struct.msg, false);
		end
		Rested.reminders[time()] = nil;
	end
end
function Rested.ReminderOnUpdate()
	if Rested.lastReminderUpdate + 1 <= time() then
		Rested.lastReminderUpdate = time();
		Rested.PrintReminders();
	end
end
function Rested.OptionsPanel_OnLoad(panel)
	panel.name = RESTED_MSG_ADDONNAME;
	RestedOptionsFrame_Title:SetText(RESTED_MSG_ADDONNAME.." "..RESTED_MSG_VERSION);
	panel.okay = Rested.OptionsPanel_OKAY;
	panel.cancel = Rested.OptionsPanel_Cancel;
	panel.default = Rested.OptionsPanel_Default;

	InterfaceOptions_AddCategory(panel);
end
function Rested.OptionsPanel_Reset()
	RestedOptionsFrame_NagTimeSliderText:SetText("NagTime ("..Rested_options.maxCutOff..")");
	RestedOptionsFrame_NagTimeSlider:SetValue(Rested_options.maxCutOff);

end
function Rested.OptionsPanel_OKAY()
	Rested_options.maxCutOff = RestedOptionsFrame_NagTimeSlider:GetValue();
	Rested.oldVal = nil;
end
function Rested.OptionsPanel_Cancel()
	Rested_options.maxCutOff = Rested.oldVal or Rested_options.maxCutOff;
	Rested.OptionsPanel_Reset();
	Rested.oldVal = nil;
end
function Rested.OptionsPanel_Default()
	Rested_options.maxCutOff = 7;
	RestedOptionsFrame_NagTimeSlider:SetValue(Rested_options.maxCutOff);
end
function Rested.BarClick(bar, button)
	Rested.Print("Clicked on a bar:"..button);
	if button == "RightButton" then
		Rested.Print("Showing");
		Rested_BarMenuFrame:Show();
	end
end
Rested.dropDownMenuTable["Full"] = "full";
Rested.commandList["full"] = function()
		Rested.reportName = "Fully Rested";
		Rested.ShowReport( Rested.FullyRested );
end
function Rested.FullyRested( realm, name, charStruct )
	-- 80 (15.5%): Realm:Name
	local rn = realm..":"..name;
	if (realm == Rested.realm and name == Rested.name) then
		rn = COLOR_GREEN..rn..COLOR_END;
	end
	local restedStr, restedVal, code, timeTillRested = Rested.FormatRested( charStruct );
	if restedVal >= 150 then
		Rested.strOut = string.format("%d %s",
				charStruct.lvlNow,
				rn);
		table.insert( Rested.charList, {(charStruct.xpNow / charStruct.xpMax)*150, Rested.strOut} );
		return 1;
	end
	return 0;
end
Rested.dropDownMenuTable["Level"] = "level";
Rested.commandList["level"] = function()
	Rested.reportName = "% of Level";
	Rested.ShowReport( Rested.OfLevel );
end
function Rested.OfLevel( realm, name, charStruct )
	-- lvl
	local rn = realm..":"..name;
	if (realm == Rested.realm and name == Rested.name) then
		rn = COLOR_GREEN..rn..COLOR_END;
	end
	if charStruct.lvlNow < Rested.maxLevel then
		local lvlPC = charStruct.xpNow / charStruct.xpMax;
		Rested.strOut = string.format("%d :: %0.2f%% %s",
				charStruct.lvlNow,
				lvlPC * 100,
				rn);
		table.insert( Rested.charList, {lvlPC * 150, Rested.strOut} );
		return 1;
	end
	return 0;
end
Rested.dropDownMenuTable["iLvl"] = "ilvl";
Rested.commandList["ilvl"] = function()
	Rested.reportName = "Item Level";
	Rested.ShowReport( Rested.iLevel );
end
function Rested.iLevel( realm, name, charStruct )
	-- lvl
	local rn = realm..":"..name;
	if (realm == Rested.realm and name == Rested.name) then
		rn = COLOR_GREEN..rn..COLOR_END;
	end
	--if charStruct.lvlNow < Rested.maxLevel then
	Rested.strOut = string.format("%d :: %d :: %s",
			charStruct.iLvl or 0,
			charStruct.lvlNow,
			rn);
	table.insert( Rested.charList, {((charStruct.iLvl or 0) / Rested_options["maxiLvl"]) * 150, Rested.strOut} );
	return 1;
--	end
--	return 0;
end


Rested.maxTimeLeftSecondsTable = {}
Rested.dropDownMenuTable["Missions"] = "missions"
Rested.minMissionTime = 300 -- 5 minutes
--Rested.followerTypeIDInfo = {[1] = "G", [2] = "F"}
Rested.commandList["missions"] = function()
	Rested.reportName = "Missions"
	Rested.ShowReport( Rested.Missions )
	Rested.firstCompleted = nil
	Rested.firstCompletedWho = nil
end
function Rested.Missions( realm, name, charStruct )
	local rn = realm..":"..name
	if (realm == Rested.realm and name == Rested.name) then
		rn = COLOR_GREEN..rn..COLOR_END
	end
	local lineCount = 0

	if charStruct.missions and  -- missions
			( ( (not charStruct.garrisonCache) or  -- no gCache info
				( charStruct.garrisonCache and ( (time() - charStruct.garrisonCache)/3600 * Rested.cacheRate < Rested.cacheMax ) ) ) or  -- less than max cache
			(realm == Rested.realm and name == Rested.name) ) then -- missions and current character
		local now = time()
		local countDone, total = {[1]=0, [2]=0}, {[1]=0, [2]=0}
		local displayCompletedAtSeconds = 0
		myFirstCompleted = time()

		for i,m in pairs(charStruct.missions) do
			-- Display::   time :: count done/ total :: name
			-- Show time to complete of shortest non-complete mission or 100%
			local completedAtSeconds = m.started + (m.duration * (1 / (m.emc and m.emc*2 or 1)))

			if (completedAtSeconds > now) then -- completes in the futue (not done)
				if (displayCompletedAtSeconds == 0) or (completedAtSeconds < displayCompletedAtSeconds) then -- completes earlier than current display value (not done)
					displayCompletedAtSeconds = completedAtSeconds
				end
			else
				m.followerTypeID = m.followerTypeID or 1
				countDone[m.followerTypeID] = ( countDone[ m.followerTypeID] and countDone[m.followerTypeID] + 1 or 1 )
				-- countDone = countDone + 1
			end
			total[m.followerTypeID] = ( total[m.followerTypeID] and total[m.followerTypeID] + 1 or 1 )
			--total = total + 1
			--
			--Rested.firstCompleted = math.min(Rested.firstCompleted or time(), completedAtSeconds)
			myFirstCompleted = math.min(myFirstCompleted, completedAtSeconds)
			Rested.firstCompleted = math.min(Rested.firstCompleted or time(), completedAtSeconds)
			if Rested.firstCompleted == time() then Rested.firstCompleted = nil end
			if Rested.firstCompleted == completedAtSeconds then
				Rested.firstCompletedWho = rn
				--
				-- table.insert( Rested.charList,
				-- 		{ time(), "--> "..rn.." :: "..m.name } )
				-- lineCount = lineCount + 1
				--
			end
			--
		end
		local timeLeft = displayCompletedAtSeconds - time()
		timeLeft = (timeLeft >= 0) and timeLeft or 0

		Rested.maxTimeLeftSecondsTable[now] = (Rested.maxTimeLeftSecondsTable[now] and  -- test to see if a value is present
				max(max(timeLeft,Rested.minMissionTime), Rested.maxTimeLeftSecondsTable[now]) or  -- if so, set a value,
				max(timeLeft,Rested.minMissionTime))

		Rested.maxTimeLeftSeconds = 0
		for ts,v in pairs(Rested.maxTimeLeftSecondsTable) do
			Rested.maxTimeLeftSeconds = max( Rested.maxTimeLeftSeconds, v )
			if ts + 3 < now then
				Rested.maxTimeLeftSecondsTable[ts] = nil
			end
		end

		local timeLeftStr = (timeLeft == 0) and "Finished" or SecondsToTime(timeLeft, false, false, (timeLeft > 3600 and 2 or 1) )

		totalMissions = 0
		for i in ipairs(total) do
			totalMissions = totalMissions + total[i]
		end
		mCounts = table.concat(countDone, "-")
		mTotals = table.concat(total, "-")

		Rested.strOut = string.format("%s%s :: %s/%s :: %s",
				(Rested.firstCompletedWho == rn and "-->" or ""),
				timeLeftStr,
				mCounts,
				mTotals,
				rn)
		table.insert( Rested.charList,
				--{ (timeLeft==0 and (150+ (time()-displayCompletedAtSeconds)) or 150 - ((timeLeft / Rested.maxTimeLeftSeconds) * 150)),
				{ (timeLeft==0 and (time() - myFirstCompleted + time())or 150 - ((timeLeft / Rested.maxTimeLeftSeconds) * 150)),
					Rested.strOut
				}
		)
		lineCount = lineCount + 1
	end
	return lineCount
end

Rested.dropDownMenuTable["G-Cache"] = "gcache"
Rested.commandList["gcache"] = function()
	Rested.reportName="Garrison Cache"
	Rested.ShowReport( Rested.Gcache )
end
Rested.cacheRate = 6 -- 6/hour (144/day)
Rested.cacheMax = 500  -- Todo:  This needs to come from a variable, and be stored per character...  :|
Rested.cacheMin = 5
function Rested.GcacheWhenAt( targetAmount, gCacheTS )
	return ( gCacheTS + ( ( targetAmount / Rested.cacheRate ) * 3600 ) )
end
function Rested.Gcache( realm, name, charStruct )
	local rn = realm..":"..name
	if (realm == Rested.realm and name == Rested.name) then
		rn = COLOR_GREEN..rn..COLOR_END;
	end
	local lineCount = 0
	if charStruct.garrisonCache then
		lineCount = 1
		local timeSince = time() - charStruct.garrisonCache
		local timeSinceStr = SecondsToTime(timeSince)

		local resourcesInCache = math.min( ( timeSince / 3600 ) * Rested.cacheRate, Rested.cacheMax )

		Rested.strOut = string.format("%i - %s :: %s",
				(resourcesInCache >= Rested.cacheMin and resourcesInCache or 0),
				timeSinceStr,
				rn)
		table.insert( Rested.charList,
				{ (resourcesInCache / Rested.cacheMax) * 150 ,
					Rested.strOut
				}
		)
	end
	return lineCount
end



]]