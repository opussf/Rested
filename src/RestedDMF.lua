-- RestedDMF.lua
RESTED_SLUG, Rested  = ...

function Rested.DMFQuestComplete( ... )
	Rested.Print( "DMFQuestComplete: "..GetZoneText()..":"..GetSubZoneText() )
	print( ... )
	Rested.me.DMF = Rested.me.DMF or {}
	local questID = ...
	Rested.me.DMF[questID] = time()
end
function Rested.DMFIsOnDMFIsland()
	if GetZoneText() == "Darkmoon Island" then
		Rested.me.DMF = Rested.me.DMF or {}
		Rested.me.DMF.lastVisit = time()
		Rested.Command( "dmf" )
	end
end
function Rested.DMFThisMonth()
	-- return start and end
	local now = date( "*t" )
	-- print( now.wday, now.day )  -- wday 1 = Sun, 7 = Sat
	local monthFirstWDay = ( now.wday - now.day + 1 ) % 7  -- remainder is always +
	if monthFirstWDay == 0 then monthFirstWDay = 7 end
	-- print( "monthFirstWDay: ", monthFirstWDay )
	local firstSundy = ( monthFirstWDay == 1 ) and 1 or ((7 - ( monthFirstWDay -1 )) % 7 ) + 1
	local secondSaturday = firstSundy + 6
	-- print( "firstSunday: ", firstSundy, "2ndSaturday: ", secondSaturday )

	now.day = firstSundy; now.hour = 0; now.minute = 1
	Rested.DMFStart = time( now )
	now.day = secondSaturday; now.hour = 23; now.minute = 59
	Rested.DMFEnd = time( now )
end

Rested.EventCallback( "QUEST_TURNED_IN", Rested.DMFQuestComplete )
Rested.EventCallback( "PLAYER_ENTERING_WORLD", Rested.DMFIsOnDMFIsland )
Rested.InitCallback( Rested.DMFThisMonth )
--[[

Rested.me.DMF {
	lastVisit
	questID = true
}

]]

function Rested.DMFReport( realm, name, charStruct )
	local rn = Rested.FormatName( realm, name )
	if charStruct.DMF then
		local questCount = 0
		for k,v in pairs( charStruct.DMF ) do
			if k ~= "lastVisit" then
				questCount = questCount + 1
			end
		end

		table.insert( Rested.charList, { 150 - ((charStruct.DMF.lastVisit - Rested.DMFStart) * (150/(Rested.DMFEnd - Rested.DMFStart))),
				string.format( "%i :: %s :: %s", questCount, SecondsToTime( time() - charStruct.DMF.lastVisit ), rn ) } )
		return 1
	end
end

Rested.dropDownMenuTable["Darkmoon Faire"] = "dmf"
Rested.commandList["dmf"] = {["help"] = {"","Show DMF report"}, ["func"] = function()
		Rested.reportName = "Darkmoon Faire"
		Rested.UIShowReport( Rested.DMFReport )
	end
}






-- Rested.FarmThings = {["Tilled Soil"] = true, ["Untilled Soil"] = true,
-- 		["Occupied Soil"] = true, ["Encroaching Weed"] = true,
-- 		["Swooping Plainshawk"] = true, ["Squatting Virmen"] = true, ["Voracious Virmen"] = true,
-- 		["Stubborn Weed"] = true, ["Unstable Portal Shard"] = true, ["Rift Stalker"] = true,
-- 		["Gina Mudclaw"] = true,
-- }
-- Rested.FarmPrefixes = { "Alluring", "Infested", "Parched", "Runty", "Smothered", "Tangled", "Wiggling", "Wild" }

-- function Rested.FarmIsCrop( name )
-- 	if Rested.FarmThings[name] then
-- 		return false
-- 	else
-- 		for _, pattern in pairs( Rested.FarmPrefixes ) do
-- 			if string.find(name, "^"..pattern) then
-- 				return false
-- 			end
-- 		end
-- 	end
-- 	return true
-- end

-- function Rested.FarmGetPlotSize( retryCount )
-- 	local plotSizeQuests = { [2] = 30535, [4] = 30257, [8] = 30516, [12] = 30524, [16] = 30529 }
-- 	Rested.me.farm = Rested.me.farm or {}
-- 	for plotSize, qnum in Rested.SortedPairs( plotSizeQuests ) do
-- 		local title = C_QuestLog.GetTitleForQuestID( qnum )
-- 		local isComplete = C_QuestLog.IsQuestFlaggedCompleted( qnum )
-- 		-- print( plotSize,  C_QuestLog.IsQuestFlaggedCompleted(qnum) )
-- 		if title then
-- 			if isComplete then
-- 				Rested.me.farm.numPlots = plotSize
-- 			end
-- 		else
-- 			-- print( plotSize..":"..qnum.." failed to get title: Using After" )
-- 			if not retryCount or retryCount <= 10 then
-- 				C_Timer.After( 1, function() Rested.FarmGetPlotSize( (retryCount and retryCount + 1 or 1) ) end )
-- 			end
-- 			return
-- 		end
-- 	end
-- 	if not Rested.me.farm.numPlots then
-- 		Rested.me.farm = nil
-- 	end
-- end
-- function Rested.FarmGetDailyReset( )
-- 	-- return low, and high
-- 	local now = date( "*t" )
-- 	--print( "hour: "..now.hour )
-- 	if now.hour >= 2 then
-- 		now.hour = 2
-- 	end
-- 	Rested.FarmPrev = time(now)
-- 	Rested.FarmNext = Rested.FarmPrev + 86400
-- end

-- function Rested.FarmSoftFriendChanged( ... )
-- 	if GetSubZoneText() == "Sunsong Ranch" then
-- 		local unitName = UnitName("playertarget")
-- 		local unitGUID = UnitGUID("playertarget")

-- 		-- print( "--"..(unitName or "nil") )
-- 		if unitGUID and unitName and Rested.FarmIsCrop(unitName) and not string.match(unitGUID, "^Pet") then
-- 			Rested.me.farm = Rested.me.farm or {}
-- 			Rested.me.farm.lastHarvest = time()
-- 		end
-- 	end
-- end

-- Rested.EventCallback( "PLAYER_SOFT_FRIEND_CHANGED", Rested.FarmSoftFriendChanged )

-- Rested.InitCallback( Rested.FarmGetPlotSize )
-- Rested.InitCallback( Rested.FarmGetDailyReset )

-- function Rested.FarmReport( realm, name, charStruct )
-- 	if not Rested.FarmPrev then Rested.FarmGetDailyReset() end
-- 	local rn = Rested.FormatName( realm, name )
-- 	if charStruct.farm then
-- 		-- print( realm, name, charStruct.farm, charStruct.farm.lastHarvest, charStruct.farm.numPlots )
-- 		table.insert( Rested.charList, { 150 - (((charStruct.farm.lastHarvest or 1) - Rested.FarmPrev) * (150/86400)),
-- 				string.format( "%i :: %s :: %s", (charStruct.farm.numPlots or 0), SecondsToTime( time() - (charStruct.farm.lastHarvest or 1) ), rn ) } )
-- 		return 1
-- 	end
-- end

-- -- Rested.reportReverseSort["Farm"] = true
-- Rested.dropDownMenuTable["Farm"] = "farm"
-- Rested.commandList["farm"] = {["help"] = {"","Show Farm report"}, ["func"] = function()
-- 		Rested.reportName = "Farm"
-- 		Rested.UIShowReport( Rested.FarmReport )
-- 	end
-- }
