#!/usr/bin/env lua

addonData={["version"] = "1.0"}

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
--	Rested.ADDON_LOADED()
	Rested_restedState = {
		["testRealm"] = {
			["testPlayer"] = {
				["deaths"] = 1,
			},
			["noDeaths"] = {
			},
		},
	}
end
function test.after()
end
function test.testGetToonCount()
--	local nameCount, realmCount = Rested.GetToonCount();
end
function test.test_main_forAllAlts()
	count = Rested.ForAllAlts( function() return 1 end, false )
	assertEquals( 2, count )
end
-- Deaths report
function test.beforeDeaths()
end
function test.afterDeaths()
end
function test.test_deaths_hasDropDownMenuEntry()
	assertEquals( "deaths", Rested.dropDownMenuTable["Deaths"] )
end
function test.test_deaths_hasCommandListEntry()
	assertEquals( "function", type(Rested.commandList["deaths"]) )
end
function test.test_deaths_0()
	test.beforeDeaths()
	Rested.ForAllAlts( Rested.Deaths, false )
--[[
Rested.dropDownMenuTable["Deaths"] = "deaths";
Rested.commandList["deaths"] = function()
	Rested.reportName = "Deaths";
	Rested.ShowReport( Rested.Deaths );
end
]]


	test.afterDeaths()
end
-- Missions report
function test.beforeMissions()
end
function test.afterMissions()
end
function test.test_missions_01()
	test.beforeMissions()
	test.afterMissions()
end
--[[


function test.testParseCmdItemStr1()
	assertEquals( "item:9999", INEED.parseCmd( "item:9999 2" ) )
end
function test.testParseCmdItemStr2()
	assertEquals( "2", select(2, INEED.parseCmd( "item:9999 2" ) ) )
end
function test.testParseCmdItemLink1()
	assertEquals( "|cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0:80:0:0|h[Broken Fang]|h|r",
			INEED.parseCmd( "|cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0:80:0:0|h[Broken Fang]|h|r" ) )
end
function test.testParseCmdList()
	assertEquals( "list", INEED.parseCmd( "list" ) )
end
function test.testParseCmdAccount()
	assertEquals( "account", INEED.parseCmd( "account" ) )
end
function test.testGetItemIdFromLink_withLink()
	assertEquals( "7073",
			INEED.getItemIdFromLink( "|cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0:80:0:0|h[Broken Fang]|h|r" ))
end
function test.testGetItemIdFromLink_withItemNum()
	assertEquals( "9999", INEED.getItemIdFromLink( "item:9999" ) )
end
function test.testAddItem_ItemStr()
	INEED.addItem( "item:9799" )
	assertEquals( 1, INEED_data["9799"]["testRealm"]["testName"].needed )
end
function test.testAddItem_ItemLink_NeededIsSet()
	INEED.addItem( "|cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0:80:0:0|h[Broken Fang]|h|r", 10 )
	assertEquals( 10, INEED_data["7073"]["testRealm"]["testName"].needed )
end
function test.testAddItem_ItemLink_TotalIsSet()
	INEED.addItem( "|cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0:80:0:0|h[Broken Fang]|h|r", 10 )
	assertEquals( 52, INEED_data["7073"]["testRealm"]["testName"].total )
end
function test.testItemFulfilled()
	INEED.addItem( "|cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0:80:0:0|h[Broken Fang]|h|r", 10 )
	INEED.UNIT_INVENTORY_CHANGED()  -- this should actually clear the item
	assertIsNil( INEED_data["7073"] )
end
function test.testAccountInfo_NoParameter()
	INEED.accountInfo( )   -- 0 accountInfo
	assertIsNil( INEED_account.balance )   -- init is nil
end
function test.testAccountInfo_SetCopperValue()
	INEED.accountInfo( 100000 )  -- sets 10 gold
	assertEquals( 100000, INEED_account.balance )
end
function test.testAccountInfo_SetCopperValue_Reset()
	INEED.accountInfo( 100000 )  -- sets 10 gold
	INEED.accountInfo( 10000 ) -- set to 1 gold
	assertEquals( 10000, INEED_account.balance )
end
function test.testAccountInfo_SetStringValue_Gold()
	INEED.command( "account 20G" )
	assertEquals( 200000, INEED_account.balance )
end
function test.testAccountInfo_SetStringValue_Silver()
	INEED.command( "account 20S" )
	assertEquals( 2000, INEED_account.balance )
end
function test.testAccountInfo_SetStringValue_Copper()
	INEED.command( "account 20C" )
	assertEquals( 20, INEED_account.balance )
end
function test.testAccountInfo_SetStringValue_MixedValues01()
	INEED.command( "account 20G 20C" )
	assertEquals( 200020, INEED_account.balance )
end
function test.testAccountInfo_SetStringValue_MixedValues02()
	INEED.command( "account 20G20C" )
	assertEquals( 200020, INEED_account.balance )
end
function test.testAccountInfo_SetStringValue_MixedValues03()
	INEED.command( "account 20G20C15S" )
	assertEquals( 201520, INEED_account.balance )
end
function test.testAccountInfo_SetStringValue_MixedValues_UnexpectedRage()
	INEED.command( "account 20G20C100S" )
	assertEquals( 210020, INEED_account.balance )
end

function test.testMerchantShow_AutoPurchaseDecrementsBalance()
	INEED.accountInfo( 1000000 )  -- sets 100 gold
	INEED.addItem( "|cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0:80:0:0|h[Broken Fang]|h|r", 100 ) -- the merchant sells these!
	INEED.MERCHANT_SHOW()
	assertEquals( 760000, INEED_account.balance )
end
function test.testMerchantShow_AutoPurchaseAbidesByAccountBalance_SingleItem()
	-- 7073 is sold at 50s each, we have 52, need 54 (extra 2)
	INEED.addItem( "|cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0:80:0:0|h[Broken Fang]|h|r", 54 )
	INEED.accountInfo( 6000 ) -- 60s
	INEED.MERCHANT_SHOW()
	assertEquals( 1000, INEED_account.balance )
end
function test.testMerchantShow_AutoPurchaseAbidesByAccountBalance_TwoItems()
	-- 7073 is sold at 50s each, we have 52, need 54 (extra 2)
	INEED.addItem( "|cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0:80:0:0|h[Broken Fang]|h|r", 54 )
	-- 6742 is sold at 1g each, we have 0, need 3 (extra 3)
	INEED.addItem( "item:6742", 3 ) -- mercahnt also sells, we need 3, we have 0, UnBroken Fang
	-- would need 4g to auto purchase
	INEED.accountInfo( 21000 ) -- 2g 10s
	INEED.MERCHANT_SHOW()
	INEED.UNIT_INVENTORY_CHANGED()
	INEED.showList()
	local balance = INEED_account.balance -- 10s
	local haveNum = INEED_data["6742"]["testRealm"]["testName"].total -- 1

	assertEquals( 1000, balance )
	assertEquals( 1, haveNum )
end

]]--

test.run()
