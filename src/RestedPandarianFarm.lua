-- RestedPandarianFarm.lua
RESTED_SLUG, Rested  = ...

Rested.FarmThings = {["Tilled Soil"] = true, ["Untilled Soil"] = true,
		["Occupied Soil"] = true, ["Encroaching Weed"] = true,
		["Swooping Plainshawk"] = true, ["Squatting Virmen"] = true, ["Voracious Virmen"] = true,
		["Stubborn Weed"] = true, ["Unstable Portal Shard"] = true, ["Rift Stalker"] = true,
		["Gina Mudclaw"] = true,
}
Rested.FarmPrefixes = { "Alluring", "Infested", "Parched", "Runty", "Smothered", "Tangled", "Wiggling", "Wild" }

function Rested.FarmIsCrop( name )
	if Rested.FarmThings[name] then
		return false
	else
		for _, pattern in pairs( Rested.FarmPrefixes ) do
			if string.find(name, "^"..pattern) then
				return false
			end
		end
	end
	return true
end

function Rested.FarmSoftFriendChanged( ... )
	if GetSubZoneText() == "Sunsong Ranch" then
		local unitName = UnitName("playertarget")
		local unitGUID = UnitGUID("playertarget")

		-- print( "--"..(unitName or "nil") )
		if unitGUID and unitName and Rested.FarmIsCrop(unitName) and not string.match(unitGUID, "^Pet") then
			Rested.Command( "farm" )

			Rested.me.farm = Rested.me.farm or {}
			Rested.me.farm[unitGUID] = time()
			Rested.me.plots = Rested.me.plots or {}
			Rested.me.plots[unitGUID] = unitName

			local plotCount = 0
			for k,v in pairs(Rested.me.farm) do
				local val = tonumber(v)
				if not val or val+64800 < time() then
					Rested.me.farm[k] = nil
				end
				plotCount = plotCount + 1
			end
			print( (unitName or "nil").." ("..(unitGUID or "nil")..") - "..(plotCount or "nil") )
		end
	end
end

Rested.EventCallback( "PLAYER_SOFT_FRIEND_CHANGED", Rested.FarmSoftFriendChanged )

function Rested.FarmReport( realm, name, charStruct )
	local rn = Rested.FormatName( realm, name )
	if charStruct.farm then
		local plotCount, maxTS = 0, 0
		for k,v in pairs(charStruct.farm) do
			local val = tonumber(v)
			maxTS = math.max(maxTS, (val or 0))
			if val and val + Rested_options.staleStart < time() then
				charStruct.farm[k] = nil
			end
			plotCount = plotCount + 1
		end
		if plotCount == 0 then
			charStruct.farm = nil
		end
		plotCount = math.min( plotCount, 16 )
		table.insert( Rested.charList, { (plotCount * 150 / 16) + (1/(time()+1-maxTS)), string.format( "%0.10f :: %i :: %s", (1/(time()-maxTS)), plotCount, rn ) } )
		return 1
	end
end

Rested.reportReverseSort["Farm"] = true
Rested.dropDownMenuTable["Farm"] = "farm"
Rested.commandList["farm"] = {["help"] = {"","Show Farm report"}, ["func"] = function()
		Rested.reportName = "Farm"
		Rested.UIShowReport( Rested.FarmReport )
	end
}
