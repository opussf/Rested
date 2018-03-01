-- RestedGarrisonMissions.lua

Rested.missionReminderValues = {
	[0] = COLOR_RED.."MISSION:"..COLOR_END.." A mission has finished for %s-%s.",
	[300] = COLOR_RED.."MISSION:"..COLOR_END.." 5 minutes until a mission finishes for %s-%s.",
	[600] = COLOR_RED.."MISSION:"..COLOR_END.." 10 minutes until a mission finishes for %s-%s.",
	[900] = COLOR_RED.."MISSION:"..COLOR_END.." 15 minutes until a mission finishes for %s-%s.",
	[1800] = COLOR_RED.."MISSION:"..COLOR_END.." 30 minutes until a mission finishes for %s-%s.",
}

Rested.maxTimeLeftSecondsTable = {}
Rested.dropDownMenuTable["Missions"] = "missions"
Rested.minMissionTime = 300 -- 5 minutes
--Rested.followerTypeIDInfo = {[1] = "G", [2] = "F"}
Rested.commandList["missions"] = function()
	Rested.reportName = "Missions"
	Rested.ShowReport( Rested.Missions )
	Rested.firstCompleted = nil
	Rested.firstCompletedWho = nil
end
function Rested.Missions( realm, name, charStruct )
	local rn = realm..":"..name
	if (realm == Rested.realm and name == Rested.name) then
		rn = COLOR_GREEN..rn..COLOR_END
	end
	local lineCount = 0

	if charStruct.missions and  -- missions
			( ( (not charStruct.garrisonCache) or  -- no gCache info
				( charStruct.garrisonCache and ( (time() - charStruct.garrisonCache)/3600 * Rested.cacheRate < Rested.cacheMax ) ) ) or  -- less than max cache
			(realm == Rested.realm and name == Rested.name) ) then -- missions and current character
		local now = time()
		local countDone, total = {[1]=0, [2]=0}, {[1]=0, [2]=0}
		local displayCompletedAtSeconds = 0
		myFirstCompleted = time()

		for i,m in pairs(charStruct.missions) do
			-- Display::   time :: count done/ total :: name
			-- Show time to complete of shortest non-complete mission or 100%
			local completedAtSeconds = m.started + (m.duration * (1 / (m.emc and m.emc*2 or 1)))

			if (completedAtSeconds > now) then -- completes in the futue (not done)
				if (displayCompletedAtSeconds == 0) or (completedAtSeconds < displayCompletedAtSeconds) then -- completes earlier than current display value (not done)
					displayCompletedAtSeconds = completedAtSeconds
				end
			else
				m.followerTypeID = m.followerTypeID or 1
				countDone[m.followerTypeID] = ( countDone[ m.followerTypeID] and countDone[m.followerTypeID] + 1 or 1 )
				-- countDone = countDone + 1
			end
			total[m.followerTypeID] = ( total[m.followerTypeID] and total[m.followerTypeID] + 1 or 1 )
			--total = total + 1
			--
			--Rested.firstCompleted = math.min(Rested.firstCompleted or time(), completedAtSeconds)
			myFirstCompleted = math.min(myFirstCompleted, completedAtSeconds)
			Rested.firstCompleted = math.min(Rested.firstCompleted or time(), completedAtSeconds)
			if Rested.firstCompleted == time() then Rested.firstCompleted = nil end
			if Rested.firstCompleted == completedAtSeconds then
				Rested.firstCompletedWho = rn
				--
				-- table.insert( Rested.charList,
				-- 		{ time(), "--> "..rn.." :: "..m.name } )
				-- lineCount = lineCount + 1
				--
			end
			--
		end
		local timeLeft = displayCompletedAtSeconds - time()
		timeLeft = (timeLeft >= 0) and timeLeft or 0

		Rested.maxTimeLeftSecondsTable[now] = (Rested.maxTimeLeftSecondsTable[now] and  -- test to see if a value is present
				max(max(timeLeft,Rested.minMissionTime), Rested.maxTimeLeftSecondsTable[now]) or  -- if so, set a value,
				max(timeLeft,Rested.minMissionTime))

		Rested.maxTimeLeftSeconds = 0
		for ts,v in pairs(Rested.maxTimeLeftSecondsTable) do
			Rested.maxTimeLeftSeconds = max( Rested.maxTimeLeftSeconds, v )
			if ts + 3 < now then
				Rested.maxTimeLeftSecondsTable[ts] = nil
			end
		end

		local timeLeftStr = (timeLeft == 0) and "Finished" or SecondsToTime(timeLeft, false, false, (timeLeft > 3600 and 2 or 1) )

		totalMissions = 0
		for i in ipairs(total) do
			totalMissions = totalMissions + total[i]
		end
		mCounts = table.concat(countDone, "-")
		mTotals = table.concat(total, "-")

		Rested.strOut = string.format("%s%s :: %s/%s :: %s",
				(Rested.firstCompletedWho == rn and "-->" or ""),
				timeLeftStr,
				mCounts,
				mTotals,
				rn)
		table.insert( Rested.charList,
				--{ (timeLeft==0 and (150+ (time()-displayCompletedAtSeconds)) or 150 - ((timeLeft / Rested.maxTimeLeftSeconds) * 150)),
				{ (timeLeft==0 and (time() - myFirstCompleted + time())or 150 - ((timeLeft / Rested.maxTimeLeftSeconds) * 150)),
					Rested.strOut
				}
		)
		lineCount = lineCount + 1
	end
	return lineCount
end
