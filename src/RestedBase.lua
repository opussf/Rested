-- RestedBase.lua

Rested.restedRates = { [ true ] = 5/(8*3600), [ false ] = 5/(32*3600) }  -- 5% every 8 hours
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
Rested.reminderValues = {
	[0] = COLOR_GREEN.."RESTED:"..COLOR_END.." %s:%s is now fully rested.",
	[60] = COLOR_GREEN.."RESTED:"..COLOR_END.." 1 minute until %s:%s is fully rested.",
	[300] = COLOR_GREEN.."RESTED:"..COLOR_END.." 5 minutes until %s:%s is fully rested.",
	[600] = COLOR_GREEN.."RESTED:"..COLOR_END.." 10 minutes until %s:%s is fully rested.",
	[900] = COLOR_GREEN.."RESTED:"..COLOR_END.." 15 minutes until %s:%s is fully rested.",
	[1800] = COLOR_GREEN.."RESTED:"..COLOR_END.." 30 minutes until %s:%s is fully rested.",
	[3600] = COLOR_GREEN.."RESTED:"..COLOR_END.." 1 hour until %s:%s is fully rested.",
	[7200] = COLOR_GREEN.."RESTED:"..COLOR_END.." 2 hours until %s:%s is fully rested.",
	[14400] = COLOR_GREEN.."RESTED:"..COLOR_END.." 4 hours until %s:%s is fully rested.",
	[21600] = COLOR_GREEN.."RESTED:"..COLOR_END.." 6 hours until %s:%s is fully rested.",
	[28800] = COLOR_GREEN.."RESTED:"..COLOR_END.." 8 hours until %s:%s is fully rested.",
	[43200] = COLOR_GREEN.."RESTED:"..COLOR_END.." 12 hours until %s:%s is fully rested.",
	[57600] = COLOR_GREEN.."RESTED:"..COLOR_END.." 16 hours until %s:%s is fully rested.",
	[86400] = COLOR_GREEN.."RESTED:"..COLOR_END.." 1 day until %s:%s is fully rested.",
	[172800] = COLOR_GREEN.."RESTED:"..COLOR_END.." 2 days until %s:%s is fully rested.",
	[432000] = COLOR_GREEN.."RESTED:"..COLOR_END.." 5 days until %s:%s is fully rested.",
}
function Rested.RestedReminderValues( realm, name, struct )
	returnStruct = {}
	now = time()
	timeSince = now - struct.updated
	restRate = Rested.restedRates[ struct.isResting ]
	restAdded = restRate * timeSince
	restedVal = struct.restedPC + restAdded
	restedAt = now + ( ( 150 - restedVal ) / restRate )
	--print( restedAt )
	for diff, format in pairs( Rested.reminderValues ) do
		reminderTime = tonumber( restedAt - diff )
		--print( ".."..reminderTime..( reminderTime > now and " > " or " <= " )..now )
		if( reminderTime > now ) then
			if( not returnStruct[reminderTime] ) then
				returnStruct[reminderTime] = {}
			end
			table.insert( returnStruct[reminderTime], string.format( format, realm, name ) )
		end
	end
	return returnStruct
end

Rested.InitCallback( Rested.SaveRestedState )
Rested.EventCallback( "PLAYER_ENTERING_WORLD", Rested.SaveRestedState )
Rested.EventCallback( "PLAYER_XP_UPDATE", Rested.SaveRestedState )
Rested.EventCallback( "PLAYER_UPDATE_RESTING", Rested.SaveRestedState )
Rested.EventCallback( "UPDATE_EXHAUSTION", Rested.SaveRestedState )
Rested.EventCallback( "CHANNEL_UI_UPDATE", Rested.SaveRestedState )  -- what IS this event?
Rested.ReminderCallback( Rested.RestedReminderValues )

--[[

function Rested.MakeReminderSchedule()
	Rested.reminders = {};
	for realm in pairs(Rested_restedState) do
		for name, charStruct in pairs(Rested_restedState[realm]) do
			if (charStruct.ignore) or
				(realm == Rested.realm and name == Rested.name) or
				(charStruct.lvlNow == Rested.maxLevel) then
				-- skip ignored, this char, or maxLvl chars.
				-- do nothing... Nicer logic to do it this way
				--Rested.Print(string.format("Do not process %s:%s", realm, name));
			else
				now = time();
				timeSince = now - charStruct.updated;
				if charStruct.isResting then  -- http://www.wowwiki.com/Rested
					restRate = (5/(8*3600));  -- 5% every 8 hours (5 seems a tad too much)
				else
					restRate = (5/(32*3600));  -- quarter rate 5% every 32 hours
				end
				restAdded = restRate * timeSince;
				restedVal = charStruct.restedPC + restAdded;
				restedAt = now + ((150-restedVal) / restRate);
				--Rested.Print(string.format("%s:%s rested at %s", realm, name, date("%x %X", restedAt)));
				for diff, format in pairs(Rested.reminderValues) do
					reminderTime = string.format("%i",(restedAt - diff)) * 1;
					if (reminderTime > now) then
						if (not Rested.reminders[reminderTime]) then
							Rested.reminders[reminderTime] = {};
						end
						table.insert( Rested.reminders[reminderTime], {["msg"]=string.format(format, realm, name)});
					end
				end
				if charStruct.xpNow then
					needPC = 100 - ((charStruct.xpNow / charStruct.xpMax) * 100);
					lvlRestedAt = string.format("%i", now + ((needPC - restedVal) / restRate)) *1;
					if (lvlRestedAt > now) then
						if (not Rested.reminders[lvlRestedAt]) then
							Rested.reminders[lvlRestedAt] = {};
						end
						table.insert( Rested.reminders[lvlRestedAt],
								{["msg"]=string.format("%s:%s is rested to end of level.", realm, name)});
						Rested.Print(string.format("Level %s:%s at %s",
								realm, name, date("%x %X",lvlRestedAt)));
					end
				end





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
