#!/usr/bin/env lua

addonData={["Version"] = "1.0", ["Author"] = "author" }

require "wowTest"

RestedOptionsFrame_NagTimeSliderText = CreateFontString()
RestedOptionsFrame_NagTimeSlider = CreateFrame()
RestedFrame = CreateFrame()

-- require the file to test
package.path = "../src/?.lua;'" .. package.path
require "Rested"
require "RestedOptions"
require "RestedBase"
require "RestedDeaths"


test.outFileName = "testOut.xml"

-- addon setup
function test.before()
	--Rested.eventFunctions = {}
	Rested.reminders = {}
	Rested.lastReminderUpdate = nil
	Rested.OnLoad()
end
function test.after()
end
function test.test_Command_Help()
	assertEquals( "help", Rested.Command( "help" ) )
end
function test.test_InitCallback_01()
	Rested.InitCallback( function() Rested.bleh=19; end )
	Rested.ADDON_LOADED()
	assertEquals( 19, Rested.bleh )
end
function test.test_EventCallback_01()
	Rested.EventCallback( "PLAYER_ENTERING_WORLD", function() Rested.bleh1=27; end )
	Rested.PLAYER_ENTERING_WORLD( )
	assertEquals( 27, Rested.bleh1 )
end
function test.test_EventCallback_noADDON_LOADED()
	Rested.EventCallback( "ADDON_LOADED", function() Rested.bleh2=37; end )
	Rested.ADDON_LOADED()
	assertIsNil( Rested.bleh2 )
end
function test.test_EventCallback_2Events()
	Rested.EventCallback( "PLAYER_ENTERING_WORLD", function() Rested.bleh3=42; end )
	Rested.EventCallback( "LICK_THE_BEAR", function() Rested.bleh4=43; end )
	Rested.ADDON_LOADED()
	Rested.LICK_THE_BEAR()
	assertEquals( 43, Rested.bleh4 )
end
function test.test_EventCallback_2functions()
	Rested.EventCallback( "PLAYER_ENTERING_WORLD", function() Rested.bleh5=48; end )
	Rested.EventCallback( "PLAYER_ENTERING_WORLD", function() Rested.yonks=49; end )
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 49, Rested.yonks )
end
function test.test_EventCallback_EventTakesParameter()
	Rested.EventCallback( "WITH_PARAM", function( thing ) Rested.bleh6=thing; end )
	Rested.WITH_PARAM( "ThisParam" )
	assertEquals( "ThisParam", Rested.bleh6 )
end
-- core data
function test.test_CoreData_RealmName()
	Rested.ADDON_LOADED()
	assertTrue( Rested_restedState["testRealm"], "testRealm has not been recorded." )
end
function test.test_CoreData_PlayerName()
	Rested.ADDON_LOADED()
	assertTrue( Rested_restedState["testRealm"]["testPlayer"], "testPlayer has not been recorded." )
end
function test.test_CoreData_initAt_NoPreviousChar()
	-- ["initAt"] = 1351452756,
	-- this should only ever be set / updated if it does not exist
	Rested_restedState = {}
	now = time()
	Rested.ADDON_LOADED()
	assertEquals( now, Rested_restedState["testRealm"]["testPlayer"]["initAt"] )
end
function test.test_CoreData_initAt_PreviousChar()
	-- ["initAt"] = 1351452756,
	-- this should only ever be set / updated if it does not exist
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["initAt"] = 37864 } }
	Rested.ADDON_LOADED()
	assertEquals( 37864, Rested_restedState["testRealm"]["testPlayer"]["initAt"] )
end
function test.test_CoreData_class_isSet()
	-- class always gets set, incase the player has changed since the last time seen
	Rested_restedState = {}
	Rested.ADDON_LOADED()
	assertEquals( "Warlock", Rested_restedState["testRealm"]["testPlayer"]["class"] )
end
function test.test_CoreData_faction_isSet()
	-- faction always gets set
	Rested_restedState = {}
	Rested.ADDON_LOADED()
	assertEquals( "Alliance", Rested_restedState["testRealm"]["testPlayer"]["faction"] )
end
function test.test_CoreData_race_isSet()
	-- faction always gets set
	Rested_restedState = {}
	Rested.ADDON_LOADED()
	assertEquals( "Human", Rested_restedState["testRealm"]["testPlayer"]["race"] )
end
function test.test_CoreData_gender_isSet()
	-- faction always gets set
	Rested_restedState = {}
	Rested.ADDON_LOADED()
	assertEquals( "Female", Rested_restedState["testRealm"]["testPlayer"]["gender"] )
end
function test.test_CoreData_updated_isSet()
	-- faction always gets set
	Rested_restedState = {}
	now = time()
	Rested.ADDON_LOADED()
	assertEquals( now, Rested_restedState["testRealm"]["testPlayer"]["updated"] )
end
function test.test_CoreData_ignore_isCleared()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["ignore"] = time() + 3600 } }
	Rested.ADDON_LOADED()
	assertIsNil( Rested_restedState["testRealm"]["testPlayer"]["ignore"] )
end
-- ForAllAlts

-- Reminders
function test.test_Reminders_registerCallBack()
	Rested.reminderFunctions = {}
	Rested.ReminderCallback( function() return( { [0] = { "0 reminder", } } ) end )
	assertEquals( 1, #Rested.reminderFunctions )
end
function test.test_Reminders_makeReminderSchedule_noChars()
	-- this really should not happen, as the system is guaranteed to have at least the current alt
	Rested_restedState = {}
	Rested.reminderFunctions = {}
	Rested.ReminderCallback( function() return( { [0] = { "0 reminder", } } ) end )
	Rested.MakeReminderSchedule()
	assertEquals( 0, #Rested.reminders )
end
function test.test_Reminders_makeReminderSchedule_oneChar()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["updated"] = time() } }
	Rested.reminderFunctions = {}
	Rested.ReminderCallback(
		function( realm, name, struct )
			return( { [0] = { name.."-"..realm.." is"..( struct.isResting and "" or " not").." resting." } } )
		end
	)
	Rested.MakeReminderSchedule()
	assertEquals( "testPlayer-testRealm is resting.", Rested.reminders[0][1] )
end
function test.test_Reminders_makeReminderSchedule_twoChar()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["updated"] = time() } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["updated"] = time() } }
	Rested.reminderFunctions = {}
	Rested.ReminderCallback(
		function( realm, name, struct )
			return( { [0] = { name.."-"..realm.." is"..( struct.isResting and "" or " not").." resting." } } )
		end
	)
	Rested.MakeReminderSchedule()
	assertEquals( 2, #Rested.reminders[0] )
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
--function Rested.
--[[

	Rested.ReminderCallback( )
	Rested.ADDON_LOADED()
	assertEquals( {"yaya"}, Rested.reminders[0] )
end
]]

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


test.run()
