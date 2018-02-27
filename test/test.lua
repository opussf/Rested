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
	Rested.LICK_THE_BEAR()
	assertEquals( 43, Rested.bleh4 )
end
function test.test_EventCallback_2functions()
	Rested.EventCallback( "PLAYER_ENTERING_WORLD", function() Rested.bleh5=48; end )
	Rested.EventCallback( "PLAYER_ENTERING_WORLD", function() Rested.yonks=49; end )
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
-- RestedDeaths
function test.test_RestedDeaths_deaths_PLAYER_ENTERING_WORLD()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["deaths"] = 918273987 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 42, Rested_restedState["testRealm"]["testPlayer"]["deaths"] )
end


test.run()
