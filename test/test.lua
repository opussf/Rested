#!/usr/bin/env lua

addonData={["Version"] = "1.0", ["Author"] = "author" }

require "wowTest"

RestedOptionsFrame_NagTimeSliderText = CreateFontString()
RestedOptionsFrame_NagTimeSlider = CreateFrame()
RestedFrame = CreateFrame()
RestedUIFrame = CreateFrame()
RestedUIFrame_TitleText = CreateFontString()
RestedScrollFrame_VSlider = CreateFrame()
RestedUIFrame_TitleText = CreateFontString()

-- require the file to test
package.path = "../src/?.lua;'" .. package.path
require "Rested"
require "RestedUI"
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
-- VARIABLES_LOADED Inits data
function test.test_maxLevel_set()
	-- account max level is set
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertTrue( Rested_misc["maxLevel"] )
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
-- other base functions
-- FormatName
function test.test_FormatName_CurrentToon()
	Rested.ADDON_LOADED()
	rn = Rested.FormatName( "testRealm", "testPlayer" )
	assertEquals( COLOR_GREEN.."testRealm:testPlayer"..COLOR_END, rn )
end
function test.test_FormatName_CurrentToon_noColor()
	Rested.ADDON_LOADED()
	rn = Rested.FormatName( "testRealm", "testPlayer", false )
	assertEquals( "testRealm:testPlayer", rn )
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
function test.test_ForAllChars_callBack_returnsNil()
	Rested_restedState = {}
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600, ["ignore"] = time()+3600 } }
	Rested.filter = nil
	result = Rested.ForAllChars( function() end, true )
	assertEquals( 0, result )
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
function test.test_Reminders_PrintReminders()
	-- test that the current reminder is processed
	-- the reminders that are printed are removed from the table
	now = time()
	Rested.reminders = { [now] = { "Reminder", "Another" }, [now+5] = { "Future" }, [now-5] = { "Past" } }
	Rested.PrintReminders()
	assertIsNil( Rested.reminders[now] )   -- primary test
	assertTrue( Rested.reminders[now+5] )  -- These are secondary tests only
	assertIsNil( Rested.reminders[now-5] )
end

-- ignore code
function test.test_Ignore_SetIgnore_name()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore testplayer" )
	assertEquals( time()+ 604800, Rested_restedState["testRealm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_realm()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore otherrealm" )
	assertEquals( time()+ 604800, Rested_restedState["otherRealm"]["otherPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_partial()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore rp" )
	assertEquals( time()+ 604800, Rested_restedState["otherRealm"]["otherPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_dot()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore ." )
	assertEquals( time()+ 604800, Rested_restedState["otherRealm"]["otherPlayer"]["ignore"] )
	assertEquals( time()+ 604800, Rested_restedState["testRealm"]["testPlayer"]["ignore"] )
end
function test.notest_Ignore_SetIgnore_noParam()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore" )
	assertIsNil( Rested_restedState["otherRealm"]["otherPlayer"]["ignore"] )
	assertIsNil( Rested_restedState["testRealm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_clearIgnore_TiedTo_PLAYER_ENTERING_WORLD()
	now = time()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600, ["ignore"] = now-5 } }
	Rested.PLAYER_ENTERING_WORLD()
	assertIsNil( Rested_restedState["otherRealm"]["otherPlayer"]["ignore"] )
end

-- Rested.me
function test.test_RestedMe_isSet()
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( Rested_restedState["testRealm"]["testPlayer"], Rested.me, "Rested.me should be set, and point to the current toon." )
end

-- FormatRested
function test.test_FormatRested_restedOutStr_useInitAt()
	charStruct = {["initAt"] = time() - 3600 }
	outStr, rVal, code, timeTill = Rested.FormatRested( charStruct )
	assertEquals( "0.2%", outStr )
	assertEquals( "-", code )
end
function test.test_FormatRested_restedOutStr_noInitAt()
	charStruct = {}
	outStr, rVal, code, timeTill = Rested.FormatRested( charStruct )
	assertEquals( "|cff00ff00Fully Rested|r", outStr )
	assertIsNil( timeTill )
end
function test.test_FormatRested_restedOutStr_isResting()
	charStruct = {["isResting"] = true}
	outStr, rVal, code, timeTill = Rested.FormatRested( charStruct )
	assertEquals( "|cff00ff00Fully Rested|r", outStr )
	assertEquals( "+", code )
end
function test.test_FormatRested_restedValue_beyondCurrentLevel()
	charStruct = {["initAt"] = time() - 14400, ["isResting"] = true, ["xpNow"] = 98, ["xpMax"] = 100 }
	outStr, rVal, code, timeTill = Rested.FormatRested( charStruct )
	assertEquals( "|cff00ff002.5%|r", outStr )
	assertEquals( "+", code )
	assertEquals( 2.5, rVal )
end

-- Mounts
require "RestedMounts"
function test.showCharList()
	if true then return end
	table.sort( Rested.charList, function( a, b ) return( a[1] > b[1] ); end )
	for k,v in pairs( Rested.charList ) do
		print( k..": "..v[1]..":"..v[2] )
	end
end

function test.test_Mounts_Report_SingleMount_halfLife()
	Rested_options.mountHistoryAge = 60
	Rested_misc = { ["mountHistory"] = { [time()-30] = "Garn Nighthowl",
		} }
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }

	Rested.ForAllChars( Rested.MountReport )

	test.showCharList()
	assertEquals( 75, Rested.charList[1][1] )
end
function test.test_Mounts_Report_SingleMount_Recent()
	Rested_options.mountHistoryAge = 60
	Rested_misc = { ["mountHistory"] = { [time()] = "Garn Nighthowl",
		} }
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }

	Rested.ForAllChars( Rested.MountReport )

	test.showCharList()
	assertEquals( 150, Rested.charList[1][1] )
end
function test.test_Mounts_Report_SingleMount_Oldest()
	Rested_options.mountHistoryAge = 60
	Rested_misc = { ["mountHistory"] = { [time()-59] = "Garn Nighthowl",
		} }
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }

	Rested.ForAllChars( Rested.MountReport )

	test.showCharList()
	assertEquals( 2.5, Rested.charList[1][1] )
end
function test.test_Mounts_Report_NoMounts()
	Rested_options.mountHistoryAge = 60
	Rested_misc = { }
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }

	Rested.ForAllChars( Rested.MountReport )

	test.showCharList()
	assertEquals( 0, #Rested.charList )
end
function test.test_Mounts_Report_TwoMounts_Same()
	Rested_options.mountHistoryAge = 60
	Rested_misc = { ["mountHistory"] = { [time()-59] = "Garn Nighthowl", [time()-30] = "Garn Nighthowl"
		} }
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }

	Rested.ForAllChars( Rested.MountReport )

	test.showCharList()
	assertEquals( 75, Rested.charList[1][1] )
end
function test.test_Mounts_Report_TwoMounts_Diff()
	Rested_options.mountHistoryAge = 60
	Rested_misc = { ["mountHistory"] = { [time()-60] = "Garn Nighthowl", [time()-30] = "Other Mount"
		} }
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }

	Rested.ForAllChars( Rested.MountReport )

	test.showCharList()
	assertEquals( 75, Rested.charList[1][1] )
end
function test.test_Mounts_Report_TwoMounts_TooOldMount()
	Rested_options.mountHistoryAge = 60
	Rested_misc = { ["mountHistory"] = { [time()-120] = "Garn Nighthowl", [time()-30] = "Other Mount"
		} }
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }

	Rested.ForAllChars( Rested.MountReport )

	test.showCharList()
	assertEquals( 1, #Rested.charList )
	assertEquals( 75, Rested.charList[1][1] )
end

-- remove
function test.test_Remove_oneAlt()
	now = time()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["testRealm"]["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 }
	Rested.Command( "rm otherPlayer" )
	assertIsNil( Rested_restedState["testRealm"]["otherPlayer"] )
end
function test.test_Remove_pruneEmptyRealm()
	now = time()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "rm otherPlayer" )
	assertIsNil( Rested_restedState["otherRealm"] )
end
function test.test_Remove_notCurrentToon()
	now = time()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "rm testPlayer" )
	assertTrue( Rested_restedState["testRealm"]["testPlayer"] )
end
function test.test_Remove_withRealm()
	now = time()
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
function test.test_Remove_withRealm_colon()
	now = time()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"]["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 }
	Rested.Command( "rm testPlayer:otherRealm" )
	assertTrue( Rested_restedState["testRealm"]["testPlayer"] )
	assertIsNil( Rested_restedState["otherRealm"]["testPlayer"] )
end
function test.test_Remove_realmWithSpace()
	now = time()
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
	now = time()
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
	now = time()
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

-- set nag time
function test.test_NagTime_Set_Day()
	Rested_options["maxCutoff"] = nil
	Rested.Command( "setNag 1d" )
	assertEquals( 86400, Rested_options.maxCutoff )
end
function test.test_NagTime_Set_Day_defaultUnit()
	Rested_options["maxCutoff"] = nil
	Rested.Command( "setNag 1" )
	assertEquals( 86400, Rested_options.maxCutoff )
end
function test.test_NagTime_Set_Hour()
	Rested_options["maxCutoff"] = nil
	Rested.Command( "setNag 1h" )
	assertEquals( 3600, Rested_options.maxCutoff )
end
function test.test_NagTime_Set_2Values()
	Rested_options["maxCutoff"] = nil
	Rested.Command( "setNag 1d1m" )
	assertEquals( 86460, Rested_options.maxCutoff )
end

-- set stale time
function test.test_StaleTime_Set_Day()
	Rested_options["maxStale"] = nil
	Rested.Command( "setstale 1d" )
	assertEquals( 86400, Rested_options.maxStale )
end
function test.test_StaleTime_Set_Day_defaultUnit()
	Rested_options["maxStale"] = nil
	Rested.Command( "setstale 1" )
	assertEquals( 86400, Rested_options.maxStale )
end
function test.test_StaleTime_Set_Week()
	Rested_options["maxStale"] = nil
	Rested.Command( "setstale 1w" )
	assertEquals( 604800, Rested_options.maxStale )
end







-- Rested Export tests
function myPrint( str )
	stdOut = stdOut or {}
	table.insert( stdOut, str )
end
function test.test_Export_01()
	stdOut = nil
	originalPrint = print
	print = myPrint
	arg = {"./", "json"}
	loadfile( "../src/Rested_Export.lua" )() -- Rested_Export reads from arg, not actually the parameters passed
--	for _,v in pairs( stdOut ) do
--		originalPrint( v )
--	end
	print = originalPrint
	--print( strOut )
end

--[[


originalPrint = print
out = {}
function print( str )
	table.insert( out, str )
	originalPrint( str )
end
arg = {"./","json"}
local X = loadfile( "../src/Rested_Export.lua" )()  -- Rested_Export reads from arg, not actually the parameters passed

originalPrint( #out )

arg = {"./", "xml"}
loadfile( "../src/Rested_Export.lua" )()  -- Rested_Export reads from arg, not actually the parameters passed
]]

--[[

-- core data


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
