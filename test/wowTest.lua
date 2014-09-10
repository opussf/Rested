--
-- Created by IntelliJ IDEA.
-- User: cgordon
-- Date: 12/5/13
-- Time: 19:06 PM
--
-----------------------------------------
-- This is an uber simple unit test implementation
-- It creates a dictionary called test.
-- Put the normal test functions in it like:
-- function test.before() would define what to do before each test
-- function test.after() would define what to do after each test
-- function test.testName() would define a test
-- Use test.run() at the end to run them all

require "wowStubs"

-- Basic assert functions
function assertEquals( expected, actual )
	if not actual or expected ~= actual then
		print( "Failure:", "expected ("..expected..")", "actual ("..(actual or "nil")..")" )
		error()
	else
		return 1    -- passed
	end
end
function assertIsNil( expected )
	if expected then
		print( "Failure:", "expected ("..expected..") to be nil" )
		error()
	else
		return 1
	end
end


test = {}
test.outFileName = "testOut.xml"
test.runInfo = {["count"] = 0, ["fail"] = 0, ["time"] = 0, ["testResults"] = {} }
-- testResults = {[test]= {["output"], ["result"], ["failed"], ["runTime"]}}

function test.toXML()
	if test.outFileName then
		local f = assert( io.open( test.outFileName, "w"))
		f:write(string.format("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"))
		f:write(string.format("<testsuite errors=\"\" failures=\"%i\" name=\"Lua.Tests\" tests=\"%i\" time=\"%0.3f\">\n",
				test.runInfo.fail, test.runInfo.count, test.runInfo.time ) )
		f:write(string.format("<properties/>\n"))
		for tName, tData in pairs( test.runInfo.testResults ) do
			f:write(string.format("<testcase classname=\"%s\" name=\"%s\" time=\"%0.3f\">\n",
					"Lua.Tests", tName, tData.runTime ) )
			if tData.failed then
				f:write(string.format("<failure type=\"%s\">%s\n</failure>\n", "testFail", tData.output ) )
			end
			f:write("</testcase>\n")
		end
		f:write(string.format("</testsuite>\n"))
		f:close()
	end
end

function test.print(...)
	io.write("meh")
end

-- intercept the lua's print function
--print = test.print

function test.run()
	local startTime = os.clock()
	test.runInfo.testResults = {}
	for fName in pairs( test ) do
		if string.match( fName, "^test.*" ) then
			local testStartTime = os.clock()
			test.runInfo.testResults[fName] = {}
			test.runInfo.count = test.runInfo.count + 1
			if test.before then test.before() end
			local status, exception = pcall(test[fName])
			if status then
				io.write(".")
			else
				test.runInfo.testResults[fName].output = debug.traceback()
				io.write("F - "..fName.." failed\n")
				print( exception )
				test.runInfo.fail = test.runInfo.fail + 1
				test.runInfo.testResults[fName].failed = 1
			end
			--print( status, exception )
			if test.after then test.after() end
			test.runInfo.testResults[fName].runTime = os.clock() - testStartTime
		end
	end
	test.runInfo.time = os.clock() - startTime
	io.write("\n\n")
	io.write(string.format("Tests: %i  Failed: %i  Elapsed time: %0.3f",
			test.runInfo.count, test.runInfo.fail, test.runInfo.time ).."\n\n")
	test.toXML()
end