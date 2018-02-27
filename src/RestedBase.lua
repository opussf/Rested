-- RestedBase.lua
-- lvlNow
function Rested.SaveRestedState()
	-- update anything based on rested state
	-- lvlNow, xpNow, xpMax, isResting, restedPC, rested
	Rested.rested = GetXPExhaustion() or 0  -- XP till Exhaustion
	Rested.xpMax = UnitXPMax( "player" )
	Rested.restedPC = ( Rested.rested > 0 and ( ( Rested.rested / Rested.xpMax ) * 100 ) or 0 )

	Rested_restedState[Rested.realm][Rested.name].lvlNow = UnitLevel( "player" )
	Rested_restedState[Rested.realm][Rested.name].xpNow = UnitXP( "player" )
	Rested_restedState[Rested.realm][Rested.name].xpMax = Rested.xpMax
	Rested_restedState[Rested.realm][Rested.name].isResting = IsResting()
	Rested_restedState[Rested.realm][Rested.name].rested = Rested.rested
	Rested_restedState[Rested.realm][Rested.name].restedPC = Rested.restedPC
	Rested_restedState[Rested.realm][Rested.name].updated = time()
end

--[[
function Rested.SaveRestedState()
	--Rested.Print("Save Rested State");
	Rested.rested = GetXPExhaustion() or 0;		-- XP till Exhaustion
	if (Rested.rested > 0) then
		Rested.restedPC = (Rested.rested / UnitXPMax("player")) * 100;
	else
		Rested.restedPC = 0;
	end

	if (Rested.info) then
		Rested.Print("UPDATE_EXHAUSTION fired at "..time()..": "..Rested.restedPC.."%");
	end
	if (Rested.realm ~= nil) and (Rested.name ~= nil) then
		Rested_restedState[Rested.realm][Rested.name].restedPC = Rested.restedPC;
		Rested_restedState[Rested.realm][Rested.name].updated = time();
		Rested_restedState[Rested.realm][Rested.name].lvlNow = UnitLevel("player");
		Rested_restedState[Rested.realm][Rested.name].xpMax = UnitXPMax("player");
		Rested_restedState[Rested.realm][Rested.name].xpNow = UnitXP("player");
		Rested_restedState[Rested.realm][Rested.name].isResting = IsResting();
		Rested_restedState[Rested.realm][Rested.name].deaths = tonumber(GetStatistic(60) or 0);
		Rested_options["maxDeaths"] = math.max(Rested_options["maxDeaths"] or 0,
													Rested_restedState[Rested.realm][Rested.name].deaths or 0);
	else
		Rested.Print("Realm and name not known");
	end
end

]]

Rested.InitCallback( Rested.SaveRestedState )
Rested.EventCallback( "PLAYER_ENTERING_WORLD", Rested.SaveRestedState )
Rested.EventCallback( "PLAYER_XP_UPDATE", Rested.SaveRestedState )
Rested.EventCallback( "PLAYER_UPDATE_RESTING", Rested.SaveRestedState )
Rested.EventCallback( "UPDATE_EXHAUSTION", Rested.SaveRestedState )
Rested.EventCallback( "CHANNEL_UI_UPDATE", Rested.SaveRestedState )  -- what IS this event?
