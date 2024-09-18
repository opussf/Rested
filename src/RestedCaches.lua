-- RestedCaches.lua
-----------------------------------------
-- Track WarWithIn Caches

Rested.cacheQuests = {84736,84737,84738,84739}
function Rested.GetCompletedCaches()
	Rested.me.weeklyCacheCount = 0
	for _,qnum in ipairs( Rested.cacheQuests ) do
		Rested.me.weeklyCacheCount = Rested.me.weeklyCacheCount + (C_QuestLog.IsQuestFlaggedCompleted(qnum) and 1 or 0)
	end
end
function Rested.CachesReport( realm, name, charStruct )
	if charStruct.weeklyCacheCount then
		table.insert( Rested.charList, { (charStruct.weeklyCacheCount / #Rested.cacheQuests) * 150 ,
			string.format( "%i :: %s", charStruct.weeklyCacheCount, Rested.FormatName( realm, name ) )
		} )
		return 1
	end
end

Rested.dropDownMenuTable["Caches"] = "caches"
Rested.commandList["caches"] = { ["help"] = {"","Caches opened."}, ["func"] = function()
		Rested.reportName = "Caches"
		Rested.UIShowReport( Rested.CachesReport )
	end
}
Rested.EventCallback( "QUEST_LOG_UPDATE", Rested.GetCompletedCaches )
Rested.EventCallback( "PLAYER_ENTERING_WORLD", Rested.GetCompletedCaches )

-- Special thanks to whomever identified the quests, and wrote an amazing macro for this.
