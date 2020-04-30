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
	Rested.filter = nil
	Rested.reminders = {}
	Rested.lastReminderUpdate = nil
	Rested_options = {}
	Rested_restedState = {}
	Rested.OnLoad()
end
function test.after()
end


-- Offline tests
-- Rested Export tests
function myPrint( str )
	stdOut = stdOut or {}
	table.insert( stdOut, str )
end
function test.test_Offline_01()
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
end

test.run()
