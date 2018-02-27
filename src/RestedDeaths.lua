-- RestedDeaths.lua

function Rested.SaveDeaths()
	-- update death count
	Rested_restedState[Rested.realm][Rested.name].deaths = tonumber( GetStatistic( 60 ) or 0 )  -- 60 is number of deaths
	Rested_restedState[Rested.realm][Rested.name].updated = time()

	Rested_options["maxDeaths"] = math.max( Rested_options["maxDeaths"] or 0,
			Rested_restedState[Rested.realm][Rested.name].deaths or 0 )
end

Rested.InitCallback( Rested.SaveDeaths )
Rested.EventCallback( "PLAYER_ENTERING_WORLD", Rested.SaveDeaths )
