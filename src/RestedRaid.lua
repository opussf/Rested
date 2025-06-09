-- RestedRaid.lua
-- "@first /script for i=1,GetNumSavedInstances() do local n,_,_,_,l,_,_,R,_,d,e,p=GetSavedInstanceInfo(i);if R and l then for j=1,e do local bN,_,isK=GetSavedInstanceEncounterInfo(i,j);print(n..\":\"..d..\":\"..(isK and\"Killed\"or\"Alive\")..\":\"..bN);end;end;end",

function Rested.StoreRaidBosses()
	Rested.me.raidBosses = Rested.me.raidBosses or {}
	for i = 1, GetNumSavedInstances() do
		local name, _, _, _, isLocked, _, _, isRaid, _, diff, numEncounters, p = GetSavedInstanceInfo(i)
		if isRaid and isLocked then
			for j = 1, numEncounters do
				local bossName, _, isKilled = GetSavedInstanceEncounterInfo(i,j)
				Rested.me.raidBosses[diff..":"..name] = Rested.me.raidBosses[diff..":"..name] or {}
				Rested.me.raidBosses[diff..":"..name][bossName] = Rested.me.raidBosses[diff..":"..name][bossName] or (isKilled and time()+j or nil)
			end
		end
	end
end

Rested.EventCallback( "PLAYER_ENTERING_WORLD", Rested.StoreRaidBosses )
Rested.EventCallback( "UPDATE_INSTANCE_INFO", Rested.StoreRaidBosses )

Rested.dropDownMenuTable["Bosses"] = "bosses"
Rested.commandList["bosses"] = { ["help"] = {"","Raid Bosses"}, ["func"] = function()
		Rested.reportName = "Raid Bosses"
		Rested.UIShowReport( Rested.RaidBossesReport )
	end
}
function Rested.RaidBossesReport( realm, name, charStruct )
	local rn = Rested.FormatName( realm, name )
	local lineCount = 0
	Rested.previousWeekReset = Rested.previousWeekReset or Rested.GetWeeklyQuestResetTime()
	if( charStruct.raidBosses ) then
		local raidCount = 0
		for raid, struct in pairs( charStruct.raidBosses ) do
			local raidBossCount = 0
			Rested.strOut = ""
			local maxTS = 0
			raidCount = raidCount + 1
			for boss, ts in pairs( struct ) do
				raidBossCount = raidBossCount + 1
				if ts < Rested.previousWeekReset then
					charStruct.raidBosses[raid][boss] = nil
				elseif ts > maxTS then
					maxTS = ts
					Rested.strOut = string.format( "%s:%s : %s", raid, boss, rn )
				end
				if time() - ts < 3600 then
					table.insert( Rested.charList, { ts-1, string.format( "%s:%s : %s", raid, boss, SecondsToTime( time() - ts ) ) } )
					lineCount = lineCount + 1
				end
			end
			Rested.strOut = raidBossCount..":"..Rested.strOut
			if Rested.strOut ~= "" then
				table.insert( Rested.charList, { maxTS, Rested.strOut } )
				lineCount = lineCount + 1
			end
		end
		if raidCount == 0 then
			charStruct.raidBosses = nil
		end
	end
	return lineCount
end
