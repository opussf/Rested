-- RestedPandarianFarm.lua
RESTED_SLUG, Rested  = ...

function Rested.FarmSoftFriendChanged( ... )
	if GetSubZoneText() == "Sunsong Ranch" then
		local unitName = UnitName("playertarget")
		local unitGUID = UnitGUID("playertarget")

		if unitGUID and unitName and unitName == "Tilled Soil" then

			Rested.me.farm = Rested.me.farm or {}
			Rested.me.farm[unitGUID] = unitName

			local plotCount = 0
			for k,v in pairs(Rested.me.farm) do
				plotCount = plotCount + 1
			end
		end
		print( "PLAYER_SOFT_FRIEND_CHANGED: "..(unitName or "nil").." ("..(unitGUID or "nil")..") - "..(plotCount or "nil") )
	else
		print( "PLAYER_SOFT_FRIEND_CHANGED: NOT ON THE RANCH" )
	end
end

-- function Rested.FarmSpellCastSent( ... )
-- 	print( "FarmSpellCastSent: ", ... )
-- end

Rested.EventCallback( "PLAYER_SOFT_FRIEND_CHANGED", Rested.FarmSoftFriendChanged )
-- Rested.EventCallback( "UNIT_SPELLCAST_SENT", Rested.FarmSpellCastSent )

function Rested.FarmReport( realm, name, charStruct )
	local rn = Rested.FormatName( realm, name )
	if charStruct.farm then
		local plotCount = 0
		for k,v in pairs(charStruct.farm) do
			plotCount = plotCount + 1
		end
		table.insert( Rested.charList, { plotCount * 150 / 8, string.format( "%i :: %s", plotCount, rn ) } )
		return 1
	end
end

Rested.dropDownMenuTable["Farm"] = "farm"
Rested.commandList["farm"] = {["help"] = {"","Show Farm report"}, ["func"] = function()
		Rested.reportName = "Farm"
		Rested.UIShowReport( Rested.FarmReport )
	end
}
