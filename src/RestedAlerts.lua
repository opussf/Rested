Rested.dropDownMenuTable["Alerts"] = "alerts"
Rested.commandList["alerts"] = function()
	Rested.reportName="Rested Alerts"
	Rested.ShowReport( Rested.Alerts )
end
function Rested.Alerts( realm, name, charStruct )
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