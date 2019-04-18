-- RestedDeaths.lua

function Rested.SaveDeaths()
	-- update death count
	Rested_restedState[Rested.realm][Rested.name].deaths = tonumber( GetStatistic( 60 ) or 0 )  -- 60 is number of deaths

	Rested_options["maxDeaths"] = math.max( Rested_options["maxDeaths"] or 0,
			Rested_restedState[Rested.realm][Rested.name].deaths or 0 )
end

Rested.InitCallback( Rested.SaveDeaths )
Rested.EventCallback( "PLAYER_ENTERING_WORLD", Rested.SaveDeaths )

--[[
Rested.dropDownMenuTable["Deaths"] = "deaths";
Rested.commandList["deaths"] = function()
	Rested.reportName = "Deaths";
	Rested.ShowReport( Rested.Deaths );
end
function Rested.Deaths( realm, name, charStruct )
	-- lvl
	local rn = realm..":"..name;
	if (realm == Rested.realm and name == Rested.name) then
		rn = COLOR_GREEN..rn..COLOR_END;
	end
	Rested.strOut = string.format("%s :: %s",
			charStruct.deaths or "Unscanned",
			rn);
	table.insert( Rested.charList, {((charStruct.deaths or -1) / Rested_options["maxDeaths"]) * 150, Rested.strOut} );
	return 1;
--	end
--	return 0;
end
]]