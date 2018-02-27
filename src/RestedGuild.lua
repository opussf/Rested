--=================
-- Guild Info
--=================

Rested.dropDownMenuTable["Guild"] = "guild"
Rested.commandList["guild"] = function()
	Rested.reportName="Guild Standing"
	Rested.ShowReport( Rested.GuildStanding )
end
--table.insert( Rested.seachKeys, "guildName" )
function Rested.PLAYER_GUILD_UPDATE( ... )
	--Rested.Print("PLAYER_GUILD_UPDATE")
	local gName, gRankName, gRankIndex = GetGuildInfo("player")
	Rested_restedState[Rested.realm][Rested.name].guildName = gName
	Rested_restedState[Rested.realm][Rested.name].guildRank = gName and gRankName or nil
	Rested_restedState[Rested.realm][Rested.name].guildRankIndex = gName and gRankIndex or nil
	local rep, bottom, top = Rested.GetGuildRep()
	bottom = 0
	--rep = rep - bottom; top = top - bottom; bottom = 0
	Rested_restedState[Rested.realm][Rested.name].guildRep = gName and rep or nil
	Rested_restedState[Rested.realm][Rested.name].guildBottom = gName and bottom or nil
	Rested_restedState[Rested.realm][Rested.name].guildTop = gName and top or nil
	--Rested.Print(string.format("%s :: %i - %i - %i", gName or "None", bottom, rep, top))
end

function Rested.GetGuildRep( )
	-- Return the rep for the guild only
	for factionIndex = 1, GetNumFactions() do
		local name, description, standingId, bottomValue, topValue, earnedValue, atWarWith,
				canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfo(factionIndex);
		if isCollapsed then
			ExpandFactionHeader(factionIndex)
			return
		end
		if name == Rested_restedState[Rested.realm][Rested.name].guildName then
			return earnedValue, bottomValue, topValue
		end
	end
end
function Rested.GuildStanding( realm, name, charStruct )
	local rn = realm..":"..name
	if (realm == Rested.realm and name == Rested.name) then
		rn = COLOR_GREEN..rn..COLOR_END;
	end
	local lineCount = 0
	if charStruct.guildName then
		lineCount = 1
		Rested.strOut = string.format("%s :: %s",
				charStruct.guildName,
				rn)
		table.insert( Rested.charList,
				{ ( charStruct.guildRep / (( charStruct.guildTop - charStruct.guildBottom ) + 1 ) ) * 150,
					Rested.strOut
				}
		)
	end
	return lineCount
end