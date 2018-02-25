#!/usr/bin/env lua

addonData={["Version"] = "1.0", ["Author"] = "author" }

require "wowTest"

-- require the file to test
package.path = "../src/?.lua;'" .. package.path
require "Rested"

test.outFileName = "testOut.xml"

-- Figure out how to parse the XML here, until then....
RestedOptionsFrame_NagTimeSliderText = CreateFontString()
RestedOptionsFrame_NagTimeSlider = CreateFrame()
RestedFrame = CreateFrame()

-- addon setup
function test.before()
	Rested.eventFunctions = {}
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
	Rested.EventCallback( "PLAYER_ENTERING_WORLD", function() Rested.bleh=27; end )
	Rested.PLAYER_ENTERING_WORLD( )
	assertEquals( 27, Rested.bleh )
end
function test.test_EventCallback_noADDON_LOADED()
	Rested.EventCallback( "ADDONLOADED", function() Rested.bleh=37; end )
	Rested.ADDON_LOADED()
	assertEquals( 19, Rested.bleh )
end
function test.test_EventCallback_2Events()
	Rested.EventCallback( "PLAYER_ENTERING_WORLD", function() Rested.bleh=42; end )
	Rested.EventCallback( "LICK_THE_BEAR", function() Rested.bleh=43; end )
	Rested.LICK_THE_BEAR()
	assertEquals( 43, Rested.bleh )
end
function test.test_EventCallback_2functions()
	Rested.EventCallback( "PLAYER_ENTERING_WORLD", function() Rested.bleh=48; end )
	Rested.EventCallback( "PLAYER_ENTERING_WORLD", function() Rested.yonks=49; end )
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 49, Rested.yonks )
end
function test.test_EventCallback_EventTakesParameter()
	Rested.EventCallback( "WITH_PARAM", function( thing ) Rested.bleh=thing; end )
	Rested.WITH_PARAM( "ThisParam" )
	assertEquals( "ThisParam", Rested.bleh )
end
-- base data
function test.test_BaseData_RealmName()
	Rested.ADDON_LOADED()
	assertTrue( Rested_restedState["testRealm"], "testRealm has not been recorded." )
end
function test.test_BaseData_PlayerName()
	Rested.ADDON_LOADED()
	assertTrue( Rested_restedState["testRealm"]["testPlayer"], "testPlayer has not been recorded." )
end
function test.test_BaseData_InitAt_NoPreviousChar()
	-- ["initAt"] = 1351452756,
	-- this should only ever be set / updated if it does not exist
	Rested_restedState = {}
	now = time()
	Rested.ADDON_LOADED()
	assertEquals( now, Rested_restedState["testRealm"]["testPlayer"]["initAt"] )
end
function test.test_BaseData_InitAt_PreviousChar()
	-- ["initAt"] = 1351452756,
	-- this should only ever be set / updated if it does not exist
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["initAt"] = 37864 } }
	Rested.ADDON_LOADED()
	assertEquals( 37864, Rested_restedState["testRealm"]["testPlayer"]["initAt"] )
end

test.run()
