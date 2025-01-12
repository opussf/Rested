-- RestedGarrisonCache.lua

function Rested.GatherGarrisonResources( ... )
	local type, link, amount = ...
	-- Rested.Print( "GatherGarrisonResources: "..type..":"..link..":"..amount )
	if type == "currency" and strfind( link, "Garrison Resources" ) then
		Rested.me.garrisonCache = time()
	end
end

Rested.EventCallback( "SHOW_LOOT_TOAST", Rested.GatherGarrisonResources )

Rested.dropDownMenuTable["Garrison Cache"] = "gcache"
Rested.commandList["gcache"] = { ["help"] = {"","Show garrison cache report."}, ["func"] = function()
		Rested.reportName="Garrison Cache"
		Rested.UIShowReport( Rested.GcacheReport )
	end
}
Rested.cacheRate = 6 -- 6/hour (144/day)
Rested.cacheMax = 500  -- Todo:  This needs to come from a variable, and be stored per character...  :|
Rested.cacheMin = 5
function Rested.GcacheWhenAt( targetAmount, gCacheTS )
	return ( gCacheTS + ( ( targetAmount / Rested.cacheRate ) * 3600 ) )
end
function Rested.GcacheReport( realm, name, charStruct )
	if charStruct.garrisonCache then
		local rn = Rested.FormatName( realm, name )
		local timeSince = time() - charStruct.garrisonCache

		local resourcesInCache = math.min( ( timeSince / 3600 ) * Rested.cacheRate, Rested.cacheMax )

		local fullAt = ( (Rested.cacheMax / Rested.cacheRate) * 3600 ) + charStruct.garrisonCache

		if fullAt > time() then
			table.insert( Rested.charList,
					{ (resourcesInCache / Rested.cacheMax) * 150,
						string.format( "%i : %s :: %s",
							(resourcesInCache >= Rested.cacheMin and resourcesInCache or 0),
							SecondsToTime( fullAt - time() ),
							rn) } )
		else
			table.insert( Rested.charList,
					{ timeSince,
						string.format( "%i : %s :: %s",
							Rested.cacheMax,
							SecondsToTime( time() - fullAt ),
							rn) } )
		end

		return 1
	end
end