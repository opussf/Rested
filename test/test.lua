#!/usr/bin/env lua

addonData={["Version"] = "1.0", ["Author"] = "author" }

require "wowTest"

RestedOptionsFrame_NagTimeSliderText = CreateFontString()
RestedOptionsFrame_NagTimeSlider = CreateFrame()
RestedFrame = CreateFrame()

-- require the file to test
package.path = "../src/?.lua;'" .. package.path
require "Rested"
require "RestedBase"
require "RestedDeaths"
require "RestedGuild"
require "RestediLvl"
require "RestedPlayed"
--require "RestedOptions"

test.outFileName = "testOut.xml"

-- addon setup
function test.before()
	--Rested.eventFunctions = {}
	Rested.reminders = {}
	Rested.lastReminderUpdate = nil
	Rested_options = {}
	Rested_restedState = {}
	Rested.OnLoad()
end
function test.after()
end
function test.test_Command_Help()
	assertEquals( "help", Rested.Command( "help" ) )
end
-- VARIABLES_LOADED Inits data
function test.test_maxLevel_set()
	-- account max level is set
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertTrue( Rested_options["maxLevel"] )
end
function test.test_RealmLevelCreated()
	-- current realm table is added if it does not exist.
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertTrue( Rested_restedState["testRealm"] )
end
function test.test_RealmLevelPreserved()
	-- do not overwrite a previous realm table
	Rested_restedState["testRealm"] = {["aPlayer"] = {["initAt"]=6372 }}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( 6372, Rested_restedState["testRealm"]["aPlayer"].initAt )
end
function test.test_PlayerLevelCreated()
	-- current player table is added if it does not exist.
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertTrue( Rested_restedState["testRealm"]["testPlayer"] )
end
function test.test_PlayerLevelPreserved()
	-- do not overwrite a previous player table
	Rested_restedState["testRealm"] = {["testPlayer"] = {["initAt"]=6372 }}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( 6372, Rested_restedState["testRealm"]["testPlayer"].initAt )
end
function test.test_PlayerClassIsSet()
	-- player class is set
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Warlock", Rested_restedState["testRealm"]["testPlayer"].class )
end
function test.test_PlayerClassIsReset()
	-- player class is reset - always over write this - many paths to this state
	Rested_restedState["testRealm"] = {["testPlayer"] =
			{["initAt"]=6372,["class"]="Warrior"}}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Warlock", Rested_restedState["testRealm"]["testPlayer"].class )
end
function test.test_PlayerFactionIsSet()
	-- player class is set
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Alliance", Rested_restedState["testRealm"]["testPlayer"].faction )
end
function test.test_PlayerFactionIsReset()
	-- player class is reset - always over write this - many paths to this state
	Rested_restedState["testRealm"] = {["testPlayer"] =
			{["initAt"]=6372,["faction"]="Horde"}}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Alliance", Rested_restedState["testRealm"]["testPlayer"].faction )
end
function test.test_PlayerRaceIsSet()
	-- player class is set
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Human", Rested_restedState["testRealm"]["testPlayer"].race )
end
function test.test_PlayerRaceIsReset()
	-- player class is reset - always over write this - many paths to this state
	Rested_restedState["testRealm"] = {["testPlayer"] =
			{["initAt"]=6372,["race"]="Orc"}}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Human", Rested_restedState["testRealm"]["testPlayer"].race )
end
function test.test_PlayerGenderIsSet()
	-- player class is set
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Female", Rested_restedState["testRealm"]["testPlayer"].gender )
end
function test.test_PlayerGenderIsReset()
	-- player class is reset - always over write this - many paths to this state
	Rested_restedState["testRealm"] = {["testPlayer"] =
			{["initAt"]=6372,["gender"]="Male"}}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Female", Rested_restedState["testRealm"]["testPlayer"].gender )
end
function test.testPlayerUpdatedIsSet()
	-- this should always be updated.
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( time(), Rested_restedState["testRealm"]["testPlayer"].updated )
end
function test.testPlayerUpdatedIsUpdated()
	-- this should always be updated.
	Rested_restedState["testRealm"] = {["testPlayer"] =
			{["initAt"]=6372,["updated"]=6372}}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( time(), Rested_restedState["testRealm"]["testPlayer"].updated )
end
function test.testPlayerIgnoreIsCleared()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["ignore"] = time() + 3600 } }
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertIsNil( Rested_restedState["testRealm"]["testPlayer"]["ignore"] )
end
-- Event callbacks
-- InitCallback
function test.test_InitCallback_RegisterdAndCalledFromVARIABLES_LOADED()
	Rested.miscVariable = nil
	Rested.InitCallback( function() Rested.miscVariable = 19; end )
	assertIsNil( Rested.miscVariable )
	Rested.ADDON_LOADED()
	assertIsNil( Rested.miscVariable )
	Rested.VARIABLES_LOADED()
	assertEquals( 19, Rested.miscVariable )
end
-- EventCallBack
function test.test_EventCallback_RegistersEvent()
	-- calling EventCallback registers the event
	Rested.EventCallback( "NONSENSE_EVENT", function() Rested.nonsense=42; end )
	assertTrue( RestedFrame.Events["NONSENSE_EVENT"] )
end
function test.test_EventCallback_RegistersEvent_notADDON_LOADED()
	-- don't allow this function / event to be registered
	assertIsNil( Rested.EventCallback( "ADDON_LOADED", function() Rested.nonsense=19; end ) )
end
function test.test_EventCallback_RegisterEvent_notVARIABLES_LOADED()
	-- don't allow this function / event to be registered
	assertIsNil( Rested.EventCallback( "VARIABLES_LOADED", function() Rested.nonsense=19; end ) )
end
function test.test_EventCallback_EventAddedTo_eventFunctions()
	Rested.eventFunctions["EVENT_ADDED"] = nil
	Rested.EventCallback( "EVENT_ADDED", function() return; end )
	assertTrue( Rested.eventFunctions["EVENT_ADDED"] )
end
function test.test_EventCallback_CreatesFunction()
	Rested.EVENT_FUNCTION = nil
	Rested.EventCallback( "EVENT_FUNCTION", function() return; end )
	assertTrue( Rested.EVENT_FUNCTION )
end
function test.test_EventCallback_2functions()
	Rested.EventCallback( "PLAYER_ENTERING_WORLD", function() Rested.bleh5=48; end )
	Rested.EventCallback( "PLAYER_ENTERING_WORLD", function() Rested.yonks=49; end )
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 48, Rested.bleh5 )
	assertEquals( 49, Rested.yonks )
end
function test.test_EventCallback_noADDON_LOADED()
	Rested.EventCallback( "ADDON_LOADED", function() Rested.bleh2=37; end )
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertIsNil( Rested.bleh2 )
end
function test.test_EventCallback_noVARIABLES_LOADED()
	Rested.EventCallback( "VARIABLES_LOADED", function() Rested.lala=96; end )
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertIsNil( Rested.lala )
end
function test.test_EventCallback_EventTakesParameter()
	Rested.EventCallback( "WITH_PARAM", function( thing ) Rested.bleh6=thing; end )
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	Rested.WITH_PARAM( "ThisParam" )
	assertEquals( "ThisParam", Rested.bleh6 )
end

-- OnUpdate
function test.test_OnUpdate_registerCallBack()
	-- the OnUpdate 'event' should be special as it is not an event from the API
	originalOnUpdateFunctions = Rested.onUpdateFunctions
	Rested.onUpdateFunctions = {}
	local testFunc = function() return( { [0] = { "0 reminder", } } ) end
	Rested.OnUpdateCallback( testFunc )
	for k, f in pairs( Rested.onUpdateFunctions ) do
		if f == testFunc then
			found = true
		end
	end
	Rested.onUpdateFunctions = originalReminderFunctions
	assertTrue( found )
end
function test.test_OnUpdate_callOnUpdate()
	originalOnUpdateFunctions = Rested.onUpdateFunctions
	Rested.onUpdateFunctions = {}
	Rested.OnUpdateCallback( function() Rested.updated = time(); end )
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	Rested.OnUpdate()
	assertTrue( Rested.updated )
end

-- Reminders
function test.test_Reminders_registerCallBack()
	local testFunc = function() return( { [0] = { "0 reminder", } } ) end
	Rested.ReminderCallback( testFunc )
	for k, f in pairs( Rested.reminderFunctions ) do
		if f == testFunc then
			found = true
		end
	end
	assertTrue( found )
end
function test.test_Reminders_makeReminderSchedule_oneChar()
	originalReminderFunctions = Rested.reminderFunctions
	Rested.reminderFunctions = {}
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["updated"] = time() } }
	Rested.ReminderCallback(
		function( realm, name, struct )
			return( { [0] = { name.."-"..realm.." is"..( struct.isResting and "" or " not").." resting." } } )
		end
	)
	Rested.MakeReminderSchedule()
	Rested.reminderFunctions = originalReminderFunctions
	assertEquals( "testPlayer-testRealm is resting.", Rested.reminders[0][1] )
end
function test.test_Reminders_makeReminderSchedule_badReturnStruct()
	-- test if the reminder function does not return an expected table
	originalReminderFunctions = Rested.reminderFunctions
	Rested.reminderFunctions = {}
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isRested"] = true, ["updated"] = time() } }
	Rested.ReminderCallback( function() return true; end )
	Rested.MakeReminderSchedule()
	Rested.reminderFunctions = originalReminderFunctions
	assertEquals( 0, #Rested.reminders )
end
function test.test_Reminders_makeReminderSchedule_oneChar_isIgnored()
	-- ignored char should not show up in reminders
	originalReminderFunctions = Rested.reminderFunctions
	Rested.reminderFunctions = {}
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["updated"] = time(), ["ignore"] = time()+60 } }
	Rested.ReminderCallback(
		function( realm, name, struct )
			return( { [0] = { name.."-"..realm.." is"..( struct.isResting and "" or " not").." resting." } } )
		end
	)
	Rested.MakeReminderSchedule()
	Rested.reminderFunctions = originalReminderFunctions
	assertIsNil( Rested.reminders[0] )
end




--[[

-- core data


-- ForAllAlts
function test.test_Reminders_makeReminders_notIgnored()
	now = time()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["updated"] = time(), ["ignore"] = now+60 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["updated"] = time() } }
	Rested.reminderFunctions = {}
	Rested.ReminderCallback(
		function( realm, name, struct )
			return( { [0] = { name.."-"..realm.." is"..( struct.isResting and "" or " not").." resting." } } )
		end
	)
	Rested.MakeReminderSchedule()
	assertEquals( 1, #Rested.reminders[0] )
end
function test.notest_Reminders_makeReminders_noMaxLvl()
	now = time()
	print( "maxLevel = "..Rested.maxLevel )
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 89, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["updated"] = time() } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["updated"] = time() } }
	Rested.reminderFunctions = {}
	Rested.ReminderCallback(
		function( realm, name, struct )
			return( { [0] = { name.."-"..realm.." is"..( struct.isResting and "" or " not").." resting." } } )
		end
	)
	Rested.MakeReminderSchedule()
	assertEquals( 1, #Rested.reminders[0] )
end
function test.test_Reminders_ReminderOnUpdate()
	-- make sure that this sets Rested.lastReminderUpdate
	Rested.ReminderOnUpdate()
	assertEquals( time(), Rested.lastReminderUpdate )
end
function test.test_Reminders_PrintReminders()
	-- test that the current reminder is processed
	-- the reminders that are printed are removed from the table
	now = time()
	Rested.reminders = { [now] = { "Reminder", "Another" }, [now+5] = { "Future" }, [now-5] = { "Past" } }
	Rested.PrintReminders()
	assertIsNil( Rested.reminders[now] )   -- primary test
	assertTrue( Rested.reminders[now-5] )  -- These are secondary tests only
	assertTrue( Rested.reminders[now+5] )
end
function test.test_Reminders_ReminderOnUpdate_printsCurrentReminder()
	now = time()
	Rested.reminders = { [now] = { "Reminder", "Another" }, [now+5] = { "Future" }, [now-5] = { "Past" } }
	Rested.ReminderOnUpdate()
	assertIsNil( Rested.reminders[now] )   -- primary test
	assertTrue( Rested.reminders[now-5] )  -- These are secondary tests only
	assertTrue( Rested.reminders[now+5] )
end

-- status code
function test.test_Status_status()
	Rested.Status()
end
function test.test_Status_command()
	Rested.Command( "status" )
end
-- ignore code
function test.test_Ignore_SetIgnore_name()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore testplayer" )
	assertEquals( time()+ 604800, Rested_restedState["testRealm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_realm()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore otherrealm" )
	assertEquals( time()+ 604800, Rested_restedState["otherRealm"]["otherPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_partial()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore rp" )
	assertEquals( time()+ 604800, Rested_restedState["otherRealm"]["otherPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_dot()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore ." )
	assertEquals( time()+ 604800, Rested_restedState["otherRealm"]["otherPlayer"]["ignore"] )
	assertEquals( time()+ 604800, Rested_restedState["testRealm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_noParam()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore" )
	assertIsNil( Rested_restedState["otherRealm"]["otherPlayer"]["ignore"] )
	assertIsNil( Rested_restedState["testRealm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_clearIgnore()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600, ["ignore"] = now-5 } }
	for realm in pairs( Rested_restedState ) do
		for name, charStruct in pairs( Rested_restedState[realm] ) do
			Rested.UpdateIgnore( charStruct )
		end
	end
	assertIsNil( Rested_restedState["otherRealm"]["otherPlayer"]["ignore"] )
end
-- remove
function test.test_Remove_oneAlt()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["testRealm"]["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 }
	Rested.Command( "rm otherPlayer" )
	assertIsNil( Rested_restedState["testRealm"]["otherPlayer"] )
end
function test.test_Remove_pruneEmptyRealm()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "rm otherPlayer" )
	assertIsNil( Rested_restedState["otherRealm"] )
end
function test.test_Remove_notCurrentToon()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "rm testPlayer" )
	assertTrue( Rested_restedState["testRealm"]["testPlayer"] )
end
function test.test_Remove_withRealm()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"]["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 }
	Rested.Command( "rm testPlayer-otherRealm" )
	assertTrue( Rested_restedState["testRealm"]["testPlayer"] )
	assertIsNil( Rested_restedState["otherRealm"]["testPlayer"] )
end
function test.test_Remove_realmWithSpace()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["other Realm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["other Realm"]["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 }
	Rested.Command( "rm testPlayer-other Realm" )
	assertTrue( Rested_restedState["testRealm"]["testPlayer"] )
	assertIsNil( Rested_restedState["other Realm"]["testPlayer"] )
end
function test.test_Remove_realmWithPunc()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["Blade's Edge"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["Blade's Edge"]["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 }
	Rested.Command( "rm testPlayer-blade's edge" )
	assertTrue( Rested_restedState["testRealm"]["testPlayer"] )
	assertIsNil( Rested_restedState["Blade's Edge"]["testPlayer"] )
end
function test.test_Remove_realmWithPunc_incomplete()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["Blade's Edge"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["Blade's Edge"]["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 }
	Rested.Command( "rm testPlayer-blade" )
	assertTrue( Rested_restedState["testRealm"]["testPlayer"] )
	assertIsNil( Rested_restedState["Blade's Edge"]["testPlayer"] )
end

-- base data
function test.test_BaseData_lvlNow()
	-- lvlNow always gets set
	Rested_restedState = {}
	Rested.ADDON_LOADED()
	assertEquals( 60, Rested_restedState["testRealm"]["testPlayer"]["lvlNow"] )
end
function test.test_BaseData_lvlNow_PLAYER_ENTERING_WORLD()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["lvlNow"] = 2 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 60, Rested_restedState["testRealm"]["testPlayer"]["lvlNow"] )
end
function test.test_BaseData_lvlNow_PLAYER_XP_UPDATE()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["lvlNow"] = 2 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_XP_UPDATE()
	assertEquals( 60, Rested_restedState["testRealm"]["testPlayer"]["lvlNow"] )
end
function test.test_BaseData_lvlNow_PLAYER_UPDATE_RESTING()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["lvlNow"] = 2 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_UPDATE_RESTING()
	assertEquals( 60, Rested_restedState["testRealm"]["testPlayer"]["lvlNow"] )
end
function test.test_BaseData_lvlNow_UPDATE_EXHAUSTION()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["lvlNow"] = 2 } }
	Rested.ADDON_LOADED()
	Rested.UPDATE_EXHAUSTION()
	assertEquals( 60, Rested_restedState["testRealm"]["testPlayer"]["lvlNow"] )
end
function test.test_BaseData_lvlNow_CHANNEL_UI_UPDATE()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["lvlNow"] = 2 } }
	Rested.ADDON_LOADED()
	Rested.CHANNEL_UI_UPDATE()
	assertEquals( 60, Rested_restedState["testRealm"]["testPlayer"]["lvlNow"] )
end
function test.test_BaseData_xpNow_PLAYER_ENTERING_WORLD()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["xpNow"] = 2 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 100, Rested_restedState["testRealm"]["testPlayer"]["xpNow"] )
end
function test.test_BaseData_xpMax_PLAYER_ENTERING_WORLD()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["xpMax"] = 2 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 1000, Rested_restedState["testRealm"]["testPlayer"]["xpMax"] )
end
function test.test_BaseData_isResting_PLAYER_ENTERING_WORLD()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["isResting"] = false } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertTrue( Rested_restedState["testRealm"]["testPlayer"]["isResting"] )
end
function test.test_BaseData_rested_PLAYER_ENTERING_WORLD()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["rested"] = 918273987 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 3618, Rested_restedState["testRealm"]["testPlayer"]["rested"] )
end
function test.test_BaseData_restedPC_PLAYER_ENTERING_WORLD()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["restedPC"] = 918273987 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 361.8, Rested_restedState["testRealm"]["testPlayer"]["restedPC"] )
end
function test.test_BaseData_RestedReminder()
	now = time()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.reminderFunctions = {}
	Rested.ReminderCallback( Rested.RestedReminderValues )
	Rested.MakeReminderSchedule()
	assertEquals( "|cff00ff00RESTED:|r 5 days until testRealm:testPlayer is fully rested.", Rested.reminders[now+428400][1] )
end
-- RestedDeaths
function test.test_RestedDeaths_deaths_PLAYER_ENTERING_WORLD()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["deaths"] = 918273987 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 42, Rested_restedState["testRealm"]["testPlayer"]["deaths"] )
end
-- FormatName
function test.test_FormatName_CurrentToon()
	Rested.ADDON_LOADED()
	rn = Rested.FormatName( "testRealm", "testPlayer" )
	assertEquals( COLOR_GREEN.."testRealm:testPlayer"..COLOR_END, rn )
end
function test.test_FormatName_DiffRealm()
	Rested.ADDON_LOADED()
	rn = Rested.FormatName( "otherRealm", "testPlayer" )
	assertEquals( "otherRealm:testPlayer", rn )
end
function test.test_FormatName_DiffName()
	Rested.ADDON_LOADED()
	rn = Rested.FormatName( "testRealm", "otherPlayer" )
	assertEquals( "testRealm:otherPlayer", rn )
end
function test.test_FormatName_DiffRealm_DiffName()
	Rested.ADDON_LOADED()
	rn = Rested.FormatName( "otherRealm", "otherPlayer" )
	assertEquals( "otherRealm:otherPlayer", rn )
end
-- ForAllChars
function test.returnOne( realm, name, cstruct )
	return 1
end
function test.test_ForAllChars_returnsCount()
	Rested_restedState = {}
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.filter = nil
	result = Rested.ForAllChars( test.returnOne )
	assertEquals( 2, result )
end
function test.test_ForAllChars_returnsCount_ignoreChar()
	Rested_restedState = {}
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600, ["ignore"] = time()+3600 } }
	Rested.filter = nil
	result = Rested.ForAllChars( test.returnOne )
	assertEquals( 1, result )
end
function test.test_ForAllChars_returnsCount_includeIgnoreChar()
	Rested_restedState = {}
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600, ["ignore"] = time()+3600 } }
	Rested.filter = nil
	result = Rested.ForAllChars( test.returnOne, true )
	assertEquals( 2, result )
end
-- Filter
function test.test_ForAllChars_filter_lvlNow_ignored()
	Rested_restedState = {}
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600, ["ignore"] = time()+3600 } }
	Rested.filter = 10
	result = Rested.ForAllChars( test.returnOne )
	assertEquals( 0, result )
end
function test.test_ForAllChars_filter_lvlNow_includeIgnoreChar()
	Rested_restedState = {}
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600, ["ignore"] = time()+3600 } }
	Rested.filter = 10
	result = Rested.ForAllChars( test.returnOne, true )
	assertEquals( 1, result )
end
function test.test_ForAllChars_filter_lvlNow_includeIgnoreChar()
	Rested_restedState = {}
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600, ["ignore"] = time()+3600 } }
	Rested.filter = 2
	result = Rested.ForAllChars( test.returnOne )
	assertEquals( 1, result )
end
--
function test.test_PruneByAge_noPrune()
	now = time()
	tableWithSubTable = { ["subTable"] = { [now-30] = "-30", [now] = "0", [now-60] = "-60", [now-180] = "-180" } }
	Rested.PruneByAge( tableWithSubTable["subTable"], 240 )
	assertEquals( "-180", tableWithSubTable["subTable"][now-180] )
end
function test.test_PruneByAge_pruneOne()
	now = time()
	tableWithSubTable = { ["subTable"] = { [now-30] = "-30", [now] = "0", [now-60] = "-60", [now-180] = "-180" } }
	Rested.PruneByAge( tableWithSubTable["subTable"], 120 )
	assertIsNil( tableWithSubTable["subTable"][now-180] )
end
]]


test.run()
