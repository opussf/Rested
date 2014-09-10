--
-- Created by IntelliJ IDEA.
-- User: cgordon
-- Date: 12/5/13
-- Time: 19:18 PM
-- To change this template use File | Settings | File Templates.
--
-----------------------------------------

local itemDB = {
}

-- simulate an internal inventory
myInventory = { ["9999"] = 52, }

-- WOW's function renames
strmatch = string.match
strfind = string.find
strsub = string.sub
strtolower = string.lower
time = os.clock

-- WOW's resources
DEFAULT_CHAT_FRAME={ ["AddMessage"] = print, }

-- stub some external API functions
function CreateFontString(...)
	local fontString = {
			["SetPoint"] = function() end,
			["SetText"] = function(text) end,
	}
	return fontString
end
function CreateFrame(...)
	local frame = {
			["SetPoint"] = function() end,
			["SetMinMaxValues"] = function() end,
			["SetValue"] = function() end,
			["CreateFontString"] = CreateFontString,
			["UnregisterEvent"] = function() end,
	}
	return frame
end
function CreateSlider(...)
	local slider = {
	}
	return slider
end
function GetAccountExpansionLevel()
	-- http://www.wowwiki.com/API_GetAccountExpansionLevel
	-- returns 0 to 4 (5)
	return 4
end
function GetAddOnMetadata(addon, field)
	addonData = { ["version"] = "1.0",
	}
	return addonData[field]
end
function GetCoinTextureString( copperIn )
	if copperIn then
		-- cannot return exactly what WoW does, but can make a simular string
		local gold = math.floor(copperIn / 10000); copperIn = copperIn - (gold * 10000)
		local silver = math.floor(copperIn / 100); copperIn = copperIn - (silver * 100)
		local copper = copperIn
		return( (gold and gold.."G")..
				(silver and ((gold and " " or "")..silver.."S"))..
				(copper and ((silver and " " or "")..copper.."C")) )
	end
end
function GetItemCount( itemID, includeBank )
	-- print( itemID, myInventory[itemID] )
	return myInventory[itemID] or 0
end
function GetItemInfo( itemID )
	-- returns name, itemLink
	local itemData = {
			["7073"] = { "Broken Fang", "|cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0:80:0:0|h[Broken Fang]|h|r" },
			["6742"] = { "UnBroken Fang", "|cff9d9d9d|Hitem:6742:0:0:0:0:0:0:0:80:0:0|h[UnBroken Fang]|h|r" },
	}
	if itemData[itemID] then return unpack( itemData[itemID] ) end
end
function GetMerchantNumItems()
	return 2
end
function GetMerchantItemLink( index )
	-- returns a link for item at index
	local merchantItems = { "|cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0:80:0:0|h[Broken Fang]|h|r",
		"|cff9d9d9d|Hitem:6742:0:0:0:0:0:0:0:80:0:0|h[UnBroken Fang]|h|r",
	}
	return merchantItems[index]
end
function GetMerchantItemInfo( index )
	--local itemName, _, price, quantity = GetMerchantItemInfo( i )
	local merchantItemInfo = { { "Broken Fang", "", 5000, 1 },  -- 50 silver
			{ "UnBroken Fang", "", 10000, 1 },            -- 1 gold
	}
	return unpack( merchantItemInfo[index] )
end
function BuyMerchantItem( index, quantity )
	-- no return value
	local itemID = INEED.getItemIdFromLink( GetMerchantItemLink( index ) )
	if myInventory[itemID] then
		myInventory[itemID] = myInventory[itemID] + quantity
	else
		myInventory[itemID] = quantity
	end
	INEED.UNIT_INVENTORY_CHANGED()

	-- meh
end
function GetRealmName()
	return "testRealm"
end
function UnitClass( who )
	local unitClasses = {
			["player"] = "Warlock",
	}
	return unitClasses[who]
end
function UnitFactionGroup( who )
	local unitFactions = {
			["player"] = "Alliance",
	}
	return unitFactions[who]
end
function UnitName( who )
	local unitNames = {
			["player"] = "testPlayer",
	}
	return unitNames[who]
end
function UnitRace( who )
	local unitRaces = {
			["player"] = "Human",
	}
	return unitRaces[who]
end
function UnitSex( who )
	-- 1 = unknown, 2 = Male, 3 = Female
	local unitSex = {
			["player"] = 3,
	}
	return unitSex[who]
end

