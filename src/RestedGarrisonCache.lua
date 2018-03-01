-- RestedGarrisonCache.lua

Rested.cacheReminderValues = {
	[5] = COLOR_GREEN.."G-CACHE:"..COLOR_END.." Garrison cache is ready for %s-%s.",
	[12] = COLOR_GREEN.."G-CACHE:"..COLOR_END.." 12 resources for %s-%s.",
	[100] = COLOR_GREEN.."G-CACHE:"..COLOR_END.." 100 resources for %s-%s.",
	[144] = COLOR_GREEN.."G-CACHE:"..COLOR_END.." 144 resources for %s-%s.", -- 1 day
	[200] = COLOR_GREEN.."G-CACHE:"..COLOR_END.." 200 resources for %s-%s.",
	[288] = COLOR_ORANGE.."G-CACHE:"..COLOR_END.." 288 resources for %s-%s.", -- 2 days
	[300] = COLOR_ORANGE.."G-CACHE:"..COLOR_END.." 300 resources for %s-%s.",
	[400] = COLOR_ORANGE.."G-CACHE:"..COLOR_END.." 400 resources for %s-%s.",
	[432] = COLOR_RED.."G-CACHE:"..COLOR_END.." 432 resources for %s-%s.", -- 3 days
	[500] = COLOR_RED.."G-CACHE:"..COLOR_END.." Is full for %s-%s.", -- Full
}
Rested.dropDownMenuTable["G-Cache"] = "gcache"
Rested.commandList["gcache"] = function()
	Rested.reportName="Garrison Cache"
	Rested.ShowReport( Rested.Gcache )
end
Rested.cacheRate = 6 -- 6/hour (144/day)
Rested.cacheMax = 500  -- Todo:  This needs to come from a variable, and be stored per character...  :|
Rested.cacheMin = 5
function Rested.GcacheWhenAt( targetAmount, gCacheTS )
	return ( gCacheTS + ( ( targetAmount / Rested.cacheRate ) * 3600 ) )
end
function Rested.Gcache( realm, name, charStruct )
	local rn = realm..":"..name
	if (realm == Rested.realm and name == Rested.name) then
		rn = COLOR_GREEN..rn..COLOR_END;
	end
	local lineCount = 0
	if charStruct.garrisonCache then
		lineCount = 1
		local timeSince = time() - charStruct.garrisonCache
		local timeSinceStr = SecondsToTime(timeSince)

		local resourcesInCache = math.min( ( timeSince / 3600 ) * Rested.cacheRate, Rested.cacheMax )

		Rested.strOut = string.format("%i - %s :: %s",
				(resourcesInCache >= Rested.cacheMin and resourcesInCache or 0),
				timeSinceStr,
				rn)
		table.insert( Rested.charList,
				{ (resourcesInCache / Rested.cacheMax) * 150 ,
					Rested.strOut
				}
		)
	end
	return lineCount
end