#!/usr/bin/env lua

require "wowTest"
test.outFileName = "testOut.xml"
--test.coberturaFileName = "../coverage.xml"  -- to enable coverage output

ParseTOC( "../src/Rested.toc" )

RestedUIFrame_TitleText = CreateFontString()
UIDropDownMenu_SetText = function() end
RestedCSV_EditBox = CreateEditBox()
--RestedOptionsFrame_NagTimeSliderText)
--RestedOptionsFrame_NagTimeSlider)
--RestedFrame = CreateFrame()
--RestedUIFrame = CreateFrame()
--RestedUIFrame_TitleText = CreateFontString()
--RestedScrollFrame_VSlider = CreateFrame()
--RestedUIFrame_TitleText = CreateFontString()
--UIDropDownMenu_SetText = function() end)

-- addon setup
function test.before()
	--Rested.eventFunctions = {}
	Rested.filter = nil
	Rested.reminders = {}
	Rested.lastReminderUpdate = nil
	Rested_options = {}
	Rested_restedState = {}
	chatLog = {}
	Rested.OnLoad()
	--Rested.SaveRestedState()
end
function test.after()
end
function test.showCharList()
	--if true then return end
	table.sort( Rested.charList, function( a, b ) return( a[1] > b[1] ); end )
	for k,v in pairs( Rested.charList ) do
		print( k..": "..v[1]..":-:"..v[2] )
	end
end
function test.test_printHelp()
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.HelpReport )
	-- test.showCharList()
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
	assertTrue( Rested_restedState["Test Realm"] )
end
function test.test_RealmLevelPreserved()
	-- do not overwrite a previous realm table
	Rested_restedState["Test Realm"] = {["aPlayer"] = {["initAt"]=6372 }}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( 6372, Rested_restedState["Test Realm"]["aPlayer"].initAt )
end
function test.test_PlayerLevelCreated()
	-- current player table is added if it does not exist.
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertTrue( Rested_restedState["Test Realm"]["testPlayer"] )
end
function test.test_PlayerLevelPreserved()
	-- do not overwrite a previous player table
	Rested_restedState["Test Realm"] = {["testPlayer"] = {["initAt"]=6372 }}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( 6372, Rested_restedState["Test Realm"]["testPlayer"].initAt )
end
function test.test_PlayerClassIsSet()
	-- player class is set
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Warlock", Rested_restedState["Test Realm"]["testPlayer"].class )
end
function test.test_PlayerClassIsReset()
	-- player class is reset - always over write this - many paths to this state
	Rested_restedState["Test Realm"] = {["testPlayer"] =
			{["initAt"]=6372,["class"]="Warrior"}}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Warlock", Rested_restedState["Test Realm"]["testPlayer"].class )
end
function test.test_PlayerFactionIsSet()
	-- player class is set
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Alliance", Rested_restedState["Test Realm"]["testPlayer"].faction )
end
function test.test_PlayerFactionIsReset()
	-- player class is reset - always over write this - many paths to this state
	Rested_restedState["Test Realm"] = {["testPlayer"] =
			{["initAt"]=6372,["faction"]="Horde"}}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Alliance", Rested_restedState["Test Realm"]["testPlayer"].faction )
end
function test.test_PlayerRaceIsSet()
	-- player class is set
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Human", Rested_restedState["Test Realm"]["testPlayer"].race )
end
function test.test_PlayerRaceIsReset()
	-- player class is reset - always over write this - many paths to this state
	Rested_restedState["Test Realm"] = {["testPlayer"] =
			{["initAt"]=6372,["race"]="Orc"}}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Human", Rested_restedState["Test Realm"]["testPlayer"].race )
end
function test.test_PlayerGenderIsSet()
	-- player class is set
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Female", Rested_restedState["Test Realm"]["testPlayer"].gender )
end
function test.test_PlayerGenderIsReset()
	-- player class is reset - always over write this - many paths to this state
	Rested_restedState["Test Realm"] = {["testPlayer"] =
			{["initAt"]=6372,["gender"]="Male"}}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Female", Rested_restedState["Test Realm"]["testPlayer"].gender )
end
function test.testPlayerUpdatedIsSet()
	-- this should always be updated.
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( time(), Rested_restedState["Test Realm"]["testPlayer"].updated )
end
function test.testPlayerUpdatedIsUpdated()
	-- this should always be updated.
	Rested_restedState["Test Realm"] = {["testPlayer"] =
			{["initAt"]=6372,["updated"]=6372}}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( time(), Rested_restedState["Test Realm"]["testPlayer"].updated )
end
function test.testPlayerIgnoreIsCleared()
	Rested_restedState["Test Realm"] = { ["testPlayer"] = { ["ignore"] = time() + 3600 } }
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertIsNil( Rested_restedState["Test Realm"]["testPlayer"]["ignore"] )
end
-- other base functions
-- FormatName
function test.test_FormatName_CurrentToon()
	Rested.ADDON_LOADED()
	rn = Rested.FormatName( "Test Realm", "testPlayer" )
	assertEquals( COLOR_GREEN.."testPlayer:Test Realm"..COLOR_END, rn )
end
function test.test_FormatName_CurrentToon_noColor()
	Rested.ADDON_LOADED()
	rn = Rested.FormatName( "Test Realm", "testPlayer", false )
	assertEquals( "testPlayer:Test Realm", rn )
end
function test.test_FormatName_DiffRealm()
	Rested.ADDON_LOADED()
	rn = Rested.FormatName( "otherRealm", "testPlayer" )
	assertEquals( "testPlayer:otherRealm", rn )
end
function test.test_FormatName_DiffName()
	Rested.ADDON_LOADED()
	rn = Rested.FormatName( "Test Realm", "otherPlayer" )
	assertEquals( "otherPlayer:Test Realm", rn )
end
function test.test_FormatName_DiffRealm_DiffName()
	Rested.ADDON_LOADED()
	rn = Rested.FormatName( "otherRealm", "otherPlayer" )
	assertEquals( "otherPlayer:otherRealm", rn )
end
-- ForAllChars
function test.returnOne( realm, name, cstruct )
	return 1
end
function test.test_ForAllChars_returnsCount()
	now = time()
	Rested_restedState = {}
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.filter = nil
	result = Rested.ForAllChars( test.returnOne )
	assertEquals( 2, result )
end
function test.test_ForAllChars_returnsCount_ignoreChar()
	now = time()
	Rested_restedState = {}
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600, ["ignore"] = time()+3600 } }
	Rested.filter = nil
	result = Rested.ForAllChars( test.returnOne )
	assertEquals( 1, result )
end
function test.test_ForAllChars_returnsCount_includeIgnoreChar()
	now = time()
	Rested_restedState = {}
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600, ["ignore"] = time()+3600 } }
	Rested.filter = nil
	result = Rested.ForAllChars( test.returnOne, true )
	assertEquals( 2, result )
end

-- Filter
function test.test_ForAllChars_filter_lvlNow_ignored()
	now = time()
	Rested_restedState = {}
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600, ["ignore"] = time()+3600 } }
	Rested.filter = 10
	result = Rested.ForAllChars( test.returnOne )
	assertEquals( 0, result )
end
function test.test_ForAllChars_filter_lvlNow_includeIgnoreChar_10()
	now = time()
	Rested_restedState = {}
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600, ["ignore"] = time()+3600 } }
	Rested.filter = 10
	result = Rested.ForAllChars( test.returnOne, true )
	assertEquals( 1, result )
end
function test.test_ForAllChars_filter_lvlNow_includeIgnoreChar_2()
	now = time()
	Rested_restedState = {}
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600, ["ignore"] = time()+3600 } }
	Rested.filter = 2
	result = Rested.ForAllChars( test.returnOne )
	assertEquals( 1, result )
end
function test.test_ForAllChars_callBack_returnsNil()
	now = time()
	Rested_restedState = {}
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
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
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["updated"] = time() } }
	Rested.ReminderCallback(
		function( realm, name, struct )
			return( { [0] = { name.."-"..realm.." is"..( struct.isResting and "" or " not").." resting." } } )
		end
	)
	Rested.MakeReminderSchedule()
	Rested.reminderFunctions = originalReminderFunctions
	assertEquals( "testPlayer-Test Realm is resting.", Rested.reminders[0][1] )
end
function test.test_Reminders_makeReminderSchedule_badReturnStruct()
	-- test if the reminder function does not return an expected table
	originalReminderFunctions = Rested.reminderFunctions
	Rested.reminderFunctions = {}
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
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
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
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
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore testplayer" )
	assertEquals( time()+ 604800, Rested_restedState["Test Realm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_realm()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore otherrealm" )
	assertEquals( time()+ 604800, Rested_restedState["otherRealm"]["otherPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_partial()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore rp" )
	assertEquals( time()+ 604800, Rested_restedState["otherRealm"]["otherPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_dot()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore ." )
	assertEquals( time()+ 604800, Rested_restedState["otherRealm"]["otherPlayer"]["ignore"] )
	assertEquals( time()+ 604800, Rested_restedState["Test Realm"]["testPlayer"]["ignore"] )
end
function test.notest_Ignore_SetIgnore_noParam()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore" )
	assertIsNil( Rested_restedState["otherRealm"]["otherPlayer"]["ignore"] )
	assertIsNil( Rested_restedState["Test Realm"]["testPlayer"]["ignore"] )
end
function test.notest_Ignore_clearIgnore_TiedTo_PLAYER_ENTERING_WORLD()
	-- TODO:  Fix this
	now = time()
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600, ["ignore"] = now-5 } }
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertIsNil( Rested_restedState["otherRealm"]["otherPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_name_withTime_60seconds()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore Player 60" )
	assertEquals( time() + 60, Rested_restedState["Test Realm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_name_withTime_minute()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore Player 1m" )
	assertEquals( time() + 60, Rested_restedState["Test Realm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_name_withTime_minute_setsOption()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore Player 5m" )
	assertEquals( 300, Rested_options.ignoreTime )
end
function test.test_Ignore_SetIgnore_name_withTime_hour()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore Player 1h" )
	assertEquals( time() + 3600, Rested_restedState["Test Realm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_name_withTime_day()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore Player 1d" )
	assertEquals( time() + 86400, Rested_restedState["Test Realm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_name_withTime_week()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore Player 1w" )
	assertEquals( time() + 604800, Rested_restedState["Test Realm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_name_withTime_1year()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore Player 52w" )
	assertAlmostEquals( time() + 31449600, Rested_restedState["Test Realm"]["testPlayer"]["ignore"], nil, nil, 1 )
end
function test.test_Ignore_SetIgnore_realm_withSpace_withTime()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore test Realm 1d" )
	assertEquals( time() + 86400, Rested_restedState["test Realm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_realm_withSpace_withComplexTime()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore test Realm 1d12h" )
	assertEquals( time() + 129600, Rested_restedState["test Realm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_realm_withSpace_withComplexTimeWithSpaces()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore test Realm 1d 12h" )
	assertEquals( time() + 129600, Rested_restedState["test Realm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_IgnoreReport_ShortTime()
	-- the ignore report changes based on how long the char is ignored for.
	now = time()
	Rested_options = { ["ignoreTime"] = 604800, ["ignoreDateLimit"] = 7776000 }  -- 7 days and 90 days
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	Rested.Command( "ignore test 1d 12h" )
	assertEquals( time() + 129600, Rested_restedState["Test Realm"]["testPlayer"]["ignore"] )

	Rested.ForAllChars( Rested.IgnoredCharacters, true )  -- need to report on ignored toons
	-- test.showCharList()
	assertEquals( 1, #Rested.charList, "There should be 1 entry" )
	assertEquals( "1 Day 12 Hr: |cff00ff00testPlayer:Test Realm|r", Rested.charList[1][2] )
end
function test.test_Ignore_IgnoreReport_LongTime()
	-- the ignore report changes based on how long the char is ignored for.
	now = time()
	Rested_options = { ["ignoreTime"] = 604800, ["ignoreDateLimit"] = 7776000 }  -- 7 days and 90 days
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	Rested.Command( "ignore test Realm 100d" )
	assertEquals( time() + 8640000, Rested_restedState["Test Realm"]["testPlayer"]["ignore"] )

	Rested.ForAllChars( Rested.IgnoredCharacters, true )  -- need to report on ignored toons
	-- test.showCharList()
	assertEquals( 1, #Rested.charList, "There should be 1 entry" )
	expected = string.format( "%s: |cff00ff00testPlayer:Test Realm|r", date( "%x %X", now + 8640000 ) )
	assertEquals( expected, Rested.charList[1][2] )
end
function test.test_Ignore_IgnoreReport_LongTime_noOptionSet()
	-- the ignore report changes based on how long the char is ignored for.
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	Rested.Command( "ignore test 100d" )
	assertEquals( time() + 8640000, Rested_restedState["Test Realm"]["testPlayer"]["ignore"] )

	Rested.ForAllChars( Rested.IgnoredCharacters, true )  -- need to report on ignored toons
	-- test.showCharList()
	assertEquals( 1, #Rested.charList, "There should be 1 entry" )
	expected = string.format( "%s: |cff00ff00testPlayer:Test Realm|r", date( "%x %X", now + 8640000 ) )
	assertEquals( expected, Rested.charList[1][2] )
end
-- Rested.me
function test.test_RestedMe_isSet()
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( Rested_restedState["Test Realm"]["testPlayer"], Rested.me, "Rested.me should be set, and point to the current toon." )
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
--require "RestedMounts"
function test.test_Mounts_Report_SingleMount_halfLife()
	now = time()
	Rested_options.mountHistoryAge = 60
	Rested_misc = { ["mountHistory"] = { [time()-30] = "Garn Nighthowl",
		} }
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }

	Rested.ForAllChars( Rested.MountReport )

	-- test.showCharList()
	assertEquals( 75, Rested.charList[1][1] )
end
function test.test_Mounts_Report_SingleMount_Recent()
	now = time()
	Rested_options.mountHistoryAge = 60
	Rested_misc = { ["mountHistory"] = { [time()] = "Garn Nighthowl",
		} }
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }

	Rested.ForAllChars( Rested.MountReport )

	-- test.showCharList()
	assertEquals( 150, Rested.charList[1][1] )
end
function test.test_Mounts_Report_SingleMount_Oldest()
	now = time()
	Rested_options.mountHistoryAge = 60
	Rested_misc = { ["mountHistory"] = { [time()-59] = "Garn Nighthowl",
		} }
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }

	Rested.ForAllChars( Rested.MountReport )

	-- test.showCharList()
	assertEquals( 2.5, Rested.charList[1][1] )
end
function test.test_Mounts_Report_NoMounts()
	now = time()
	Rested_options.mountHistoryAge = 60
	Rested_misc = { }
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }

	Rested.ForAllChars( Rested.MountReport )

	-- test.showCharList()
	assertEquals( 0, #Rested.charList )
end
function test.test_Mounts_Report_TwoMounts_Same()
	now = time()
	Rested_options.mountHistoryAge = 60
	Rested_misc = { ["mountHistory"] = { [time()-59] = "Garn Nighthowl", [time()-30] = "Garn Nighthowl"
		} }
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }

	Rested.ForAllChars( Rested.MountReport )

	-- test.showCharList()
	assertAlmostEquals( 75, Rested.charList[1][1], nil, nil, 2.5 )
end
function test.test_Mounts_Report_TwoMounts_Diff()
	now = time()
	Rested_options.mountHistoryAge = 60
	Rested_misc = { ["mountHistory"] = { [time()-60] = "Garn Nighthowl", [time()-30] = "Other Mount"
		} }
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }

	Rested.ForAllChars( Rested.MountReport )

	-- test.showCharList()
	assertEquals( 75, Rested.charList[1][1] )
end
function test.test_Mounts_Report_TwoMounts_TooOldMount()
	now = time()
	Rested_options.mountHistoryAge = 60
	Rested_misc = { ["mountHistory"] = { [time()-120] = "Garn Nighthowl", [time()-30] = "Other Mount"
		} }
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }

	Rested.ForAllChars( Rested.MountReport )

	-- test.showCharList()
	assertEquals( 1, #Rested.charList )
	assertEquals( 75, Rested.charList[1][1] )
end
function test.test_Mounts_Set_HistoryAge_Day()
	Rested_options.mountHistoryAge = 259200
	Rested.Command( "setMountAge 1d" )
	assertEquals( 86400, Rested_options.mountHistoryAge )
end

-- remove
function test.test_Remove_oneAlt()
	Rested.ADDON_LOADED()
	now = time()
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["Test Realm"]["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 }
	Rested.Command( "rm otherPlayer" )
	assertIsNil( Rested_restedState["Test Realm"]["otherPlayer"] )
end
function test.test_Remove_pruneEmptyRealm()
	Rested.ADDON_LOADED()
	now = time()
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "rm otherPlayer" )
	assertIsNil( Rested_restedState["otherRealm"] )
end
function test.test_Remove_notCurrentToon()
	Rested.ADDON_LOADED()
	now = time()
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "rm testPlayer" )
	assertTrue( Rested_restedState["Test Realm"]["testPlayer"] )
end
function test.test_Remove_withRealm()
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	now = time()
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"]["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 }
	Rested.Command( "rm testPlayer-otherRealm" )
	assertTrue( Rested_restedState["Test Realm"]["testPlayer"] )
	assertIsNil( Rested_restedState["otherRealm"]["testPlayer"] )
end
function test.test_Remove_withRealm_colon()
	Rested.ADDON_LOADED()
	now = time()
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"]["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 }
	Rested.Command( "rm testPlayer:otherRealm" )
	assertTrue( Rested_restedState["Test Realm"]["testPlayer"] )
	assertIsNil( Rested_restedState["otherRealm"]["testPlayer"] )
end
function test.test_Remove_realmWithSpace()
	Rested.ADDON_LOADED()
	now = time()
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["other Realm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["other Realm"]["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 }
	Rested.Command( "rm testPlayer-other Realm" )
	assertTrue( Rested_restedState["Test Realm"]["testPlayer"] )
	assertIsNil( Rested_restedState["other Realm"]["testPlayer"] )
end
function test.test_Remove_realmWithPunc()
	Rested.ADDON_LOADED()
	now = time()
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["Blade's Edge"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["Blade's Edge"]["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 }
	Rested.Command( "rm testPlayer-blade's edge" )
	assertTrue( Rested_restedState["Test Realm"]["testPlayer"] )
	assertIsNil( Rested_restedState["Blade's Edge"]["testPlayer"] )
end
function test.test_Remove_realmWithPunc_incomplete()
	Rested.ADDON_LOADED()
	now = time()
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["Blade's Edge"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["Blade's Edge"]["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 }
	Rested.Command( "rm testPlayer-blade" )
	assertTrue( Rested_restedState["Test Realm"]["testPlayer"] )
	assertIsNil( Rested_restedState["Blade's Edge"]["testPlayer"] )
end

-- set nag time
function test.test_NagTime_Set_Day()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setNag 1d" )
	assertEquals( 86400, Rested_options.nagStart )
end
function test.test_NagTime_Set_Day_defaultUnit()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setNag 1" )
	assertEquals( 86400, Rested_options.nagStart )
end
function test.test_NagTime_Set_Hour()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setNag 1h" )
	assertEquals( 3600, Rested_options.nagStart )
end
function test.test_NagTime_Set_2Values()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setNag 1d1m" )
	assertEquals( 86460, Rested_options.nagStart )
end
function test.test_NagTime_Set_CannotBeGreaterThanStale()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setNag 10d1m" )
	assertEquals( 604800, Rested_options.nagStart )
end
function test.test_NagTime_Set_CanBeEqualToStale()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setNag 10d" )
	assertEquals( 864000, Rested_options.nagStart )
end
function test.test_NagTime_Set_EmptyDoesNotChange()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setNag" )
	assertEquals( 7 * 86400, Rested_options.nagStart )
end
function test.test_NagTime_Set_SetToZero()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setNag 0" )
	assertEquals( 7 * 86400, Rested_options.nagStart )
end

-- set stale time
function test.test_StaleTime_Set_Day()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setstale 9d" )
	assertEquals( 777600, Rested_options.staleStart )
end
function test.test_StaleTime_Set_Day_defaultUnit()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setstale 12" )
	assertEquals( 1036800, Rested_options.staleStart )
end
function test.test_StaleTime_Set_Week()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setstale 2w" )
	assertEquals( 1209600, Rested_options.staleStart )
end
function test.test_StaleTime_Set_CannotBeLessThanNag()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setstale 5d" )
	assertEquals( 864000, Rested_options.staleStart )
end
function test.test_StaleTime_Set_CanBeEqualToNag()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setstale 7d" )
	assertEquals( 604800, Rested_options.staleStart )
end
function test.test_StaleTime_Set_EmptyDoesNotChange()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 864000
	Rested.Command( "setstale" )
	assertEquals( 8640000, Rested_options.staleStart )
end

-- Professions
function test.test_Profession_SaveInfo()
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	Rested.SaveProfessionInfo()
	assertEquals( "prof1", Rested_restedState["Test Realm"]["testPlayer"]["prof1"] )
end
function test.notest_Profession_Concentration()
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	Rested.GetConcentration()
	test.dump( Rested_restedState )
end

-- gold
--require "RestedGold"
function test.before_gold()
	oldMyCopper = myCopper
end
function test.after_gold()
	myCopper = 0
end
function test.test_Gold_01()
	test.before_gold()
	myCopper = 847394
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	Rested.PLAYER_ENTERING_WORLD()

	Rested.SaveGold()
	assertEquals( 847394, Rested_restedState["Test Realm"]["testPlayer"].gold )
	test.after_gold()
end
function test.test_Gold_Report_01()
	test.before_gold()

	--Rested.ADDON_LOADED()
	--Rested.VARIABLES_LOADED()
	--Rested.PLAYER_ENTERING_WORLD()

	Rested_restedState = nil
	Rested_restedState = {}
	Rested_restedState["goldRealm"] = { ["goldPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = time(), ["gold"] = 872648 } }

	Rested.ForAllChars( Rested.GoldReport )
	assertEquals( "87g 26s 48c :: goldPlayer:goldRealm", Rested.charList[2][2] )
	test.after_gold()
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
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
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
	assertEquals( 60, Rested_restedState["Test Realm"]["testPlayer"]["lvlNow"] )
end
function test.test_BaseData_lvlNow_PLAYER_ENTERING_WORLD()
	Rested_restedState["Test Realm"] = { ["testPlayer"] = { ["lvlNow"] = 2 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 60, Rested_restedState["Test Realm"]["testPlayer"]["lvlNow"] )
end
function test.test_BaseData_lvlNow_PLAYER_XP_UPDATE()
	Rested_restedState["Test Realm"] = { ["testPlayer"] = { ["lvlNow"] = 2 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_XP_UPDATE()
	assertEquals( 60, Rested_restedState["Test Realm"]["testPlayer"]["lvlNow"] )
end
function test.test_BaseData_lvlNow_PLAYER_UPDATE_RESTING()
	Rested_restedState["Test Realm"] = { ["testPlayer"] = { ["lvlNow"] = 2 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_UPDATE_RESTING()
	assertEquals( 60, Rested_restedState["Test Realm"]["testPlayer"]["lvlNow"] )
end
function test.test_BaseData_lvlNow_UPDATE_EXHAUSTION()
	Rested_restedState["Test Realm"] = { ["testPlayer"] = { ["lvlNow"] = 2 } }
	Rested.ADDON_LOADED()
	Rested.UPDATE_EXHAUSTION()
	assertEquals( 60, Rested_restedState["Test Realm"]["testPlayer"]["lvlNow"] )
end
function test.test_BaseData_lvlNow_CHANNEL_UI_UPDATE()
	Rested_restedState["Test Realm"] = { ["testPlayer"] = { ["lvlNow"] = 2 } }
	Rested.ADDON_LOADED()
	Rested.CHANNEL_UI_UPDATE()
	assertEquals( 60, Rested_restedState["Test Realm"]["testPlayer"]["lvlNow"] )
end
function test.test_BaseData_xpNow_PLAYER_ENTERING_WORLD()
	Rested_restedState["Test Realm"] = { ["testPlayer"] = { ["xpNow"] = 2 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 100, Rested_restedState["Test Realm"]["testPlayer"]["xpNow"] )
end
function test.test_BaseData_xpMax_PLAYER_ENTERING_WORLD()
	Rested_restedState["Test Realm"] = { ["testPlayer"] = { ["xpMax"] = 2 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 1000, Rested_restedState["Test Realm"]["testPlayer"]["xpMax"] )
end
function test.test_BaseData_isResting_PLAYER_ENTERING_WORLD()
	Rested_restedState["Test Realm"] = { ["testPlayer"] = { ["isResting"] = false } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertTrue( Rested_restedState["Test Realm"]["testPlayer"]["isResting"] )
end
function test.test_BaseData_rested_PLAYER_ENTERING_WORLD()
	Rested_restedState["Test Realm"] = { ["testPlayer"] = { ["rested"] = 918273987 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 3618, Rested_restedState["Test Realm"]["testPlayer"]["rested"] )
end
function test.test_BaseData_restedPC_PLAYER_ENTERING_WORLD()
	Rested_restedState["Test Realm"] = { ["testPlayer"] = { ["restedPC"] = 918273987 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 361.8, Rested_restedState["Test Realm"]["testPlayer"]["restedPC"] )
end
function test.test_BaseData_RestedReminder()
	now = time()
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.reminderFunctions = {}
	Rested.ReminderCallback( Rested.RestedReminderValues )
	Rested.MakeReminderSchedule()
	assertEquals( "|cff00ff00RESTED:|r 5 days until Test Realm:testPlayer is fully rested.", Rested.reminders[now+428400][1] )
end
-- RestedDeaths
function test.test_RestedDeaths_deaths_PLAYER_ENTERING_WORLD()
	Rested_restedState["Test Realm"] = { ["testPlayer"] = { ["deaths"] = 918273987 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 42, Rested_restedState["Test Realm"]["testPlayer"]["deaths"] )
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

-- Nag MountReport
function test.test_NagReport_MaxLevel_InNagRange()
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["Test Realm"] = { ["testPlayer_MaxLevel"] =
			{ ["lvlNow"] = Rested.maxLevel, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = true, ["restedPC"] = 0,
			["updated"] = now-(8*86400) } }

	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.NagCharacters )

	-- test.showCharList()
	assertEquals( "90 :: 8 Day 0 Hr : testPlayer_MaxLevel:Test Realm", Rested.charList[1][2] )
end
function test.test_NagReport_MaxLevel_LessThanNagRange()
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["Test Realm"] = { ["testPlayer_MaxLevel"] =
			{ ["lvlNow"] = Rested.maxLevel, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = true, ["restedPC"] = 0,
			["updated"] = now-(6*86400) } }

	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.NagCharacters )

	-- test.showCharList()
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.test_NagReport_MaxLevel_GreaterThanNagRange()
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["Test Realm"] = { ["testPlayer_MaxLevel"] =
			{ ["lvlNow"] = Rested.maxLevel, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = true, ["restedPC"] = 0,
			["updated"] = now-(10.2*86400) } }

	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.NagCharacters )

	-- test.showCharList()
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.test_NagReport_Leveling_RestedLessThanLevel_Resting_True()
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["Test Realm"] = { ["testPlayer_lvl2"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = true, ["restedPC"] = 0,
			["updated"] = now-(2*86400) } }

	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.NagCharacters )

	-- test.showCharList()
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.notest_NagReport_Leveling_RestedLessThanLevel_Resting_False()
	-- TODO: fix this
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["Test Realm"] = { ["testPlayer_lvl2"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 0,
			["updated"] = now-(2*86400) } }

	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.NagCharacters )

	-- test.showCharList()
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.notest_NagReport_Leveling_RestedGreaterThanLevel_Resting_True()
	-- fix this
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["Test Realm"] = { ["testPlayer_lvl2"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = true, ["restedPC"] = 0,
			["updated"] = now-(8.5*86400) } }

	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.NagCharacters )

	-- test.showCharList()
	assertEquals( "2 :: |cff00ff00127.5%|r : Test Realm:testPlayer_lvl2", Rested.charList[1][2] )
end
function test.notest_NagReport_Leveling_RestedGreaterThanLevel_Resting_False()
	-- fix this
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["Test Realm"] = { ["testPlayer_lvl2"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 0,
			["updated"] = now-(8.5*86400) } }

	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.NagCharacters )

	-- test.showCharList()
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.notest_NagReport_Leveling_RestedGreaterThanMax_Resting_True()
	-- TODO: fix this
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["Test Realm"] = { ["testPlayer_lvl2"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = true, ["restedPC"] = 0,
			["updated"] = now-(17*86400) } }

	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.NagCharacters )

	-- test.showCharList()
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.notest_NagReport_Leveling_RestedGreaterThanMax_Resting_False()
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["Test Realm"] = { ["testPlayer_lvl2"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 0,
			["updated"] = now-(70*86400) } }

	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.NagCharacters )

	-- test.showCharList()
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.notest_NagReport_Leveling_RestedGreaterThanLevel_FullyRested_Resting_True()
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["Test Realm"] = { ["testPlayer_lvl2"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = true, ["restedPC"] = 150,
			["updated"] = now-(1*86400) } }

	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.NagCharacters )

	-- test.showCharList()
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.notest_NagReport_Leveling_RestedGreaterThanLevel_FullyRested_Resting_False()
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["Test Realm"] = { ["testPlayer_lvl2"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150,
			["updated"] = now-(1*86400) } }

	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.NagCharacters )

	-- test.showCharList()
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.test_NagReport_NotResting()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["Test Realm"] = { ["testPlayer_lvl2"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150,
			["updated"] = now-(1*3600) } }
	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.NagCharacters )

	-- test.showCharList()
	assertEquals( "2 :: 1 Hr 0 Min : testPlayer_lvl2:Test Realm NOT RESTING", Rested.charList[1][2] )
end

-- Offline tests
function myPrint( str )
	stdOut = stdOut or {}
	table.insert( stdOut, str )
end
function test.after_Offline()
	ParseTOC( "../src/Rested.toc" )
--	require "Rested"
--	require "RestedUI"
--	require "RestedBase"
--	require "RestedDeaths"
--	require "RestedGuild"
--	require "RestediLvl"
--	require "RestedPlayed"
end
function test.notest_Offline_01()
	stdOut = nil
	originalPrint = print
	print = myPrint
	arg = {[0] = "../src/Rested_Offline.lua", "./", "nag"}
	loadfile( "../src/Rested_Offline.lua" )() -- Rested_Export reads from arg, not actually the parameters passed
	for _,v in pairs( stdOut ) do
		originalPrint( v )
	end
	print = originalPrint
	--print( strOut )
	test.after_Offline()
end

-- Auction tests
function test.test_AuctionReport_noAuctions()
	Rested.ForAllChars( Rested.AuctionsReport )
	-- test.showCharList()
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.test_AuctionReport_newAuction_12hours()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150,
			["updated"] = now-(1*86400),
			["Auctions"] = {
				[550] = {
					["created"] = now,
					["duration"] = 12 * 3600
				},
			} } }
	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.AuctionsReport )
	-- test.showCharList()
	assertEquals( "1 (12 Hr 0 Min to go) |cff00ff00testPlayer:Test Realm|r", Rested.charList[1][2] )
end
function test.test_AuctionReport_newAuction_24hours()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150, ["updated"] = now-(1*86400),
			["Auctions"] = {
				[550] = {
					["created"] = now,
					["duration"] = 24 * 3600
				},
			} } }
	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.AuctionsReport )
	-- test.showCharList()
	assertEquals( "1 (1 Day 0 Hr to go) |cff00ff00testPlayer:Test Realm|r", Rested.charList[1][2] )
end
function test.test_AuctionReport_newAuction_48hours()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150, ["updated"] = now-(1*86400),
			["Auctions"] = {
				[550] = {
					["created"] = now,
					["duration"] = 48 * 3600
				},
			} } }
	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.AuctionsReport )
	-- test.showCharList()
	assertEquals( "1 (2 Day 0 Hr to go) |cff00ff00testPlayer:Test Realm|r", Rested.charList[1][2] )
end
function test.test_AuctionReport_clearOldAuction_12hours_Init()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150, ["updated"] = now-(1*86400),
			["Auctions"] = {
				[550] = {
					["created"] = now-(12*3600) - 5,  -- 12 hours, 5 seconds ago
					["duration"] = 12 * 3600
				},
			} } }
	Rested.VARIABLES_LOADED()  -- calls init functions
	Rested.ForAllChars( Rested.AuctionsReport )
	-- test.showCharList()
	assertIsNil( Rested_restedState["Test Realm"]["testPlayer"]["Auctions"] )
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.test_AuctionReport_clearOldAuction_12hours_PLAYER_ENTERING_WORLD()
	now = time()
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()  -- calls init functions
	Rested_restedState["Test Realm"]["testPlayer"]["Auctions"] = {
			[550] = {
				["created"] = now-(12*3600) - 5,  -- 12 hours, 5 seconds ago
				["duration"] = 12 * 3600
			},
	}
	Rested.PLAYER_ENTERING_WORLD()
	Rested.ForAllChars( Rested.AuctionsReport )
	-- test.showCharList()
	assertIsNil( Rested_restedState["Test Realm"]["testPlayer"]["Auctions"] )
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.test_AuctionReport_CreateAuction_PostCommodity_12Hours()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150, ["updated"] = now-(1*86400),
			} }
	Rested.VARIABLES_LOADED()
	C_AuctionHouse.PostCommodity( {}, 1, 1, 1 ) -- item(table), durationKey, quantiy, unitPrice
	Rested.AUCTION_HOUSE_AUCTION_CREATED( 15 )  -- This event has a payload....  The auction ID
	assertEquals( 12*3600, Rested_restedState["Test Realm"]["testPlayer"]["Auctions"][15].duration )
end
function test.test_AuctionReport_CreateAuction_PostCommodity_24Hours()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150, ["updated"] = now-(1*86400),
			} }
	Rested.VARIABLES_LOADED()
	C_AuctionHouse.PostCommodity( {}, 2, 1, 1 ) -- item(table), durationKey, quantiy, unitPrice
	Rested.AUCTION_HOUSE_AUCTION_CREATED( 15 )  -- This event has a payload....  The auction ID
	assertEquals( 24*3600, Rested_restedState["Test Realm"]["testPlayer"]["Auctions"][15].duration )
end
function test.test_AuctionReport_CreateAuction_PostCommodity_48Hours()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150, ["updated"] = now-(1*86400),
			} }
	Rested.VARIABLES_LOADED()
	C_AuctionHouse.PostCommodity( {}, 3, 1, 1 ) -- item(table), durationKey, quantiy, unitPrice
	Rested.AUCTION_HOUSE_AUCTION_CREATED( 15 )  -- This event has a payload....  The auction ID
	assertEquals( 48*3600, Rested_restedState["Test Realm"]["testPlayer"]["Auctions"][15].duration )
end
function test.test_AuctionReport_CreateAuction_PostItem_12Hours()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150, ["updated"] = now-(1*86400),
			} }
	Rested.VARIABLES_LOADED()
	C_AuctionHouse.PostItem( {}, 1, 1, 1 ) -- item(table), durationKey, quantiy, unitPrice
	Rested.AUCTION_HOUSE_AUCTION_CREATED( 16 )  -- This event has a payload....  The auction ID
	assertEquals( 12*3600, Rested_restedState["Test Realm"]["testPlayer"]["Auctions"][16].duration )
end
function test.test_AuctionReport_CreateAuction_PostCommodity_24Hours()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150, ["updated"] = now-(1*86400),
			} }
	Rested.VARIABLES_LOADED()
	C_AuctionHouse.PostItem( {}, 2, 1, 1 ) -- item(table), durationKey, quantiy, unitPrice
	Rested.AUCTION_HOUSE_AUCTION_CREATED( 16 )  -- This event has a payload....  The auction ID
	assertEquals( 24*3600, Rested_restedState["Test Realm"]["testPlayer"]["Auctions"][16].duration )
end
function test.test_AuctionReport_CreateAuction_PostCommodity_48Hours()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["Test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150, ["updated"] = now-(1*86400),
			} }
	Rested.VARIABLES_LOADED()
	C_AuctionHouse.PostItem( {}, 3, 1, 1 ) -- item(table), durationKey, quantiy, unitPrice
	Rested.AUCTION_HOUSE_AUCTION_CREATED( 16 )  -- This event has a payload....  The auction ID
	assertEquals( 48*3600, Rested_restedState["Test Realm"]["testPlayer"]["Auctions"][16].duration )
end
function test.test_AuctionReport_ExpiredAuction_Report()
	now = time()
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()  -- calls init functions
	Rested_restedState["Test Realm"]["testPlayer"]["Auctions"] = {
			[550] = {
				["created"] = now-(12*3600) - 5,  -- 12 hours, 5 seconds ago
				["duration"] = 12 * 3600
			},
	}
	Rested.ForAllChars( Rested.AuctionsReport )
	-- test.showCharList()
	assertEquals( "1 (EXPIRED) |cff00ff00testPlayer:Test Realm|r", Rested.charList[1][2] )
end
function test.test_AuctionReport_ExpiredReminders()
	now = time()
	Rested.reminders = {}
	Rested.ADDON_LOADED()
	Rested_restedState["Test Realm"] = { ["testPlayer2"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["updated"] = time(), ["restedPC"] = 150,
			["Auctions"] = {
				[550] = {
					["created"] = now-(12*3600) - 25,  -- 12 hours, 5 seconds ago
					["duration"] = 12 * 3600
				}
	} } }
	Rested.VARIABLES_LOADED()
	Rested.MakeReminderSchedule()
	assertEquals( "testPlayer2:Test Realm has 1 expired auctions.", Rested.reminders[time()+60][1] )
end
-- Nag timeOut
----------
function test.test_SetNagTimeOut_report_nil()
	Rested_options.nagTimeOut = nil
	Rested.Command( "setNagTimeout" )
	assertIsNil( Rested_options.nagTimeOut )
end
function test.test_SetNagTimeOut_report_set()
	Rested_options.nagTimeOut = 302
	Rested.Command( "setNagTimeout" )
	assertEquals( 302, Rested_options.nagTimeOut )
end
function test.test_SetNagTimeOut_set_nonnil()
	Rested_options.nagTimeOut = 60
	Rested.Command( "setNagTimeout 1m30s" )
	assertEquals( 90, Rested_options.nagTimeOut )
end
function test.test_SetNagTimeOut_set_nil()
	Rested_options.nagTimeOut = 60
	Rested.Command( "setNagTimeout 0" )
	assertIsNil( Rested_options.nagTimeOut )
end
-- NoNag
-----------
function test.test_NoNag_set_01()
	Rested_restedState["Test Realm"] = {["testPlayer"] =
			{["initAt"]=6372,["updated"]=6372}}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	Rested.Command( "noNag . 1h")
	assertEquals( time() + 3600, Rested_restedState["Test Realm"]["testPlayer"]["nonag"] )
end
function test.test_NoNag_set_02()
	Rested.Command( "noNag testPlayer 2h" )
end
-- UIManagement
-------------
function test.test_UIReset()
	Rested.Command( "uireset" )
	-- @TODO: determine how to test
end
function test.test_TextToSeconds_01()
	assertEquals( 15, Rested.TextToSeconds( "15" ) )
end
function test.test_TextToSeconds_02()
	assertEquals( 30, Rested.TextToSeconds( "30s" ) )
end
function test.test_TextToSeconds_03()
	assertEquals( 90, Rested.TextToSeconds( "1m30s" ) )
end
function test.test_TextToSeconds_04()
	assertEquals( 90, Rested.TextToSeconds( "30s1m" ) )
end
function test.test_TextToSeconds_05()
	assertEquals( 3690, Rested.TextToSeconds( "30s1m1h" ) )
end
function test.test_TextToSeconds_06()
	assertEquals( 90090, Rested.TextToSeconds( "30s1m1h1d" ) )
end
function test.test_TextToSeconds_07()
	assertEquals( 694890, Rested.TextToSeconds( "30s1m1h1d1w" ) )
end
function test.test_TextToSeconds_08()
	assertEquals( 694890, Rested.TextToSeconds( "1m1h1d1w30" ) )
end
-- CSV
-------------
function test.test_CSV_InitalColumns()
	Rested_restedState["Test Realm"] = {["testPlayer"] =
			{["faction"]="Alliance",["race"]="Human",["class"]="Warlock",["gender"]="Female",["lvlNow"]=80,["iLvl"]=500}}
	Rested.Command( "csv" )
	assertEquals( "Realm,Name,Faction,Race,Class,Gender,Level,iLvl\nTest Realm,testPlayer,Alliance,Human,Warlock,Female,80,500\n", Rested_csv)
end
-- test descriptions
-------------
-- commandDescs = {
-- 		["all"]       = "Show all characters sorted by level.",
-- 		["auctions"]  = "List of auctions.",
-- 		["cooldowns"] = "",
-- 		["csv"]       = "Export character data in CSV format.",
-- 		["deaths"]    = "",
-- }

-- function test.test_TestDesc_AllCommands()
-- 	for k, v in test.PairsByKeys( Rested.commandList ) do
-- 		chatLog = {}
-- 		Rested.Command( "help "..k )
-- 		if not chatLog[3] then
-- 			test.dump( chatLog )
-- 		end
-- 		assertEquals( commandDescs[k], chatLog[3].msg, "Desc for "..k.." is missing." )
-- 	end
-- end

--[[
edAuctions.lua:
   46
   47  Rested.dropDownMenuTable["Auctions"] = "auctions"
   48: Rested.commandList["auctions"] = {["help"] = {"","Show auction counts"}, ["func"] = function()
   49  		Rested.reportName = "Auctions"
   50  		Rested.UIShowReport( Rested.AuctionsReport )

~/Dev/addons/Rested/src/RestedBase.lua:
   66  	return 0
   67  end
   68: Rested.commandList["ignore"] = { ["func"] = Rested.SetIgnore, ["help"] = {"<search> [ignore Duration]", "Ignore matched chars, or show ignored." } }
   69  Rested.EventCallback( "PLAYER_ENTERING_WORLD", function() Rested.ForAllChars( Rested.UpdateIgnore, true ); end )
   70  Rested.dropDownMenuTable["Ignore"] = "ignore"
   ..
  152  ------------------------------
  153  Rested.dropDownMenuTable["Level"] = "level"
  154: Rested.commandList["level"] = {["help"] = {"","Show % of level"}, ["func"] = function()
  155  		Rested.reportName = "% of Level"
  156  		Rested.UIShowReport( Rested.OfLevel )
  ...
  172
  173  Rested.dropDownMenuTable["Full"] = "full"
  174: Rested.commandList["full"] = {["help"] = {"", "Show fully rested characters"}, ["func"] = function()
  175  		Rested.reportName = "Fully Rested"
  176  		Rested.UIShowReport( Rested.FullyRested )
  ...
  192
  193  Rested.dropDownMenuTable["Resting"] = "resting"
  194: Rested.commandList["resting"] = {["help"] = {"","Show resting characters"}, ["func"] = function ()
  195  		Rested.reportName = "Resting Characters"
  196  		Rested.UIShowReport( Rested.RestingCharacters )
  ...
  218
  219  Rested.dropDownMenuTable["All"] = "all"
  220: Rested.commandList["all"] = {["help"] = {"","Show all characters"}, ["func"] = function()
  221  		Rested.reportName = "All"
  222  		Rested.UIShowReport( Rested.AllCharacters )
  ...
  236
  237  Rested.dropDownMenuTable["Nag"] = "nag"
  238: Rested.commandList["nag"] = {["help"] = {"","Show nag characters"}, ["func"] = function()
  239  		Rested.reportName = "Nag Characters"
  240  		Rested.UIShowReport( Rested.NagCharacters )
  ...
  310  	end
  311  end
  312: Rested.commandList["setnag"] = {["help"] = {"#[s|m|h|d|w]", "Set the time before a max level character shows up in the nag report."},
  313  		["func"] = Rested.SetNag }
  314
  ...
  331  	end
  332  end
  333: Rested.commandList["setnagtimeout"] = {["help"] = {"#[s|m|h|d|w]", "Set the time to autoshow the nag window."},
  334  	["func"] = Rested.SetNagTimeOut,
  335  	["desc"] = {"Set how long the nag report is auto shown for."},
  ...
  379  end
  380
  381: Rested.commandList["nonag"] = {
  382  		["func"] = Rested.SetNoNag,
  383  		["help"] = { "<search> [ignore duration]", "Remove matched chars from the nag list for duration, or until visited." },
  ...
  388  -- Stale characters
  389  Rested.dropDownMenuTable["Stale"] = "stale"
  390: Rested.commandList["stale"] = {["help"] = {"","Show stale characters"}, ["func"] = function()
  391  		Rested.reportName = "Stale Characters"
  392  		Rested.UIShowReport( Rested.StaleCharacters )
  ...
  422  	end
  423  end
  424: Rested.commandList["setstale"] = {["help"] = {"#[s|m|h|d|w]", "Set the time before a max level character shows up as stale."},
  425  		["func"] = Rested.SetStale }
  426
  427  -- Max level characters
  428  Rested.dropDownMenuTable["Max"] = "max"
  429: Rested.commandList["max"] = {["help"] = {"","Show max level characters"}, ["func"] = function()
  430  		Rested.reportName = "Max Level Characters"
  431  		Rested.UIShowReport( Rested.MaxCharacters )

~/Dev/addons/Rested/src/RestedCSV.lua:
   19
   20  Rested.EventCallback( "PLAYER_ENTERING_WORLD", function() Rested_csv=nil; end )
   21: Rested.commandList["csv"] = {["help"] = {"","Make CSV export"}, ["func"] = Rested.MakeCSV }
   22

~/Dev/addons/Rested/src/RestedDeaths.lua:
   13
   14  Rested.dropDownMenuTable["Deaths"] = "deaths"
   15: Rested.commandList["deaths"] = {["help"] = {"","Show number of deaths"}, ["func"] = function()
   16  		Rested.reportName = "Deaths"
   17  		Rested.UIShowReport( Rested.DeathReport )

~/Dev/addons/Rested/src/RestedGold.lua:
   10
   11  Rested.dropDownMenuTable["Gold"] = "gold"
   12: Rested.commandList["gold"] = {["help"] = {"","Show gold"}, ["func"] = function()
   13  		Rested.reportName = "Gold"
   14  		Rested.UIShowReport( Rested.GoldReport )

~/Dev/addons/Rested/src/RestedGuild.lua:
   29
   30  Rested.dropDownMenuTable["Guild"] = "guild"
   31: Rested.commandList["guild"] = {["help"] = {"","Show guild standing"}, ["func"] = function()
   32  		Rested.reportName = "Guild Standing"
   33  		Rested.UIShowReport( Rested.GuildStandingReport )

~/Dev/addons/Rested/src/RestediLvl.lua:
   17
   18  Rested.dropDownMenuTable["iLvl"] = "ilvl"
   19: Rested.commandList["ilvl"] = { ["help"] = {"","Show iLvl report"}, ["func"] = function()
   20  		Rested.reportName = "Item Level"
   21  		Rested.UIShowReport( Rested.iLevelReport )

~/Dev/addons/Rested/src/RestedMounts.lua:
   53
   54  Rested.dropDownMenuTable["Mounts"] = "mounts"
   55: Rested.commandList["mounts"] = { ["help"] = {"","Show recent mount history"}, ["func"] = function()
   56  		Rested.reportName = "Mount history"
   57  		Rested.UIShowReport( Rested.MountReport )
   ..
   87  	Rested.Print( string.format( "mountHistoryAge changed from %s to %s", previousVal, SecondsToTime( newVal ) ) )
   88  end
   89: Rested.commandList["setmountage"] = {["help"] = {"#[s|m|h|d|w]", "Set the time to track mounts."},
   90  		["func"] = Rested.SetMountHistoryAge }
   91

~/Dev/addons/Rested/src/RestedPlayed.lua:
   18
   19  Rested.dropDownMenuTable["Played"] = "played"
   20: Rested.commandList["played"] = { ["help"] = {"","Time played"}, ["func"] = function()
   21  		Rested.reportName = "Time Played"
   22  		Rested.UIShowReport( Rested.PlayedReport )

~/Dev/addons/Rested/src/RestedProfessions.lua:
   58
   59  Rested.dropDownMenuTable["Prof CD"] = "cooldowns"
   60: Rested.commandList["cooldowns"] = { ["help"] = {"","Profession Cooldowns"}, ["func"] = function()
   61  		Rested.reportName = "Cooldowns"
   62  		Rested.UIShowReport( Rested.Cooldowns )

~/Dev/addons/Rested/src/RestedUI.lua:
   97  	RestedUIFrame:SetPoint("LEFT", "$parent", "LEFT")
   98  end
   99: Rested.commandList["uireset"] = { ["help"] = {"","Reset the location of the UI frame"}, ["func"] = Rested.ResetUIPosition }
  100
  101  -- DropDown code
  ...
  109  	-- based on Rested.dropDownMenuTable["Full"] = "full"
  110  	-- the Key is what to show, the value is what rested command to call
  111: 	-- using Rested.commandList["full"] = {["func"] = function() end }
  112  	--local info = UIDropDownMenu_CreateInfo()
  113  	local sortedKeys, i = {}, 1

~/Dev/addons/Rested/src/RestedVault.lua:
   91
   92  Rested.dropDownMenuTable["Vault"] = "vault"
   93: Rested.commandList["vault"] = { ["help"] = {"","Show vault info"}, ["func"] = function()
   94  		Rested.reportName = "Vault Report"
   95  		Rested.UIShowReport( Rested.VaultReport )

~/Dev/addons/Rested/Rested-cf/Rested.lua:
  118  end
  119  Rested.dropDownMenuTable["Help"] = "help"
  120: Rested.commandList["help"] = { ["help"] = {"<command>","Show help. Specific info for command if given."}, ["func"] = function(...)
  121  		Rested.PrintHelp(...)
  122  		Rested.reportName = "Help"
  ...
  298  	end
  299  end
  300: Rested.commandList["rm"] = { ["func"] = Rested.RemoveCharacter, ["help"] = { "name[-realm]", "Remove name[-realm] from Rested." } }
  301
  302  -- event callback for modules
]]




test.run()
