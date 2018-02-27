--=================
-- Played Info
--=================

Rested.dropDownMenuTable["Played"] = "played"
Rested.commandList["played"] = function()
	Rested.reportName="Time Played"
	Rested.ShowReport( Rested.ShowPlayed )
end
function Rested.PLAYER_LEAVING_WORLD()
	RequestTimePlayed()
end
function Rested.TIME_PLAYED_MSG( total, currentLvl )
	print("Rested.TIME_PLAYED_MSG: "..total.." - "..currentLvl )
	Rested_restedState[Rested.realm][Rested.name].totalPlayed = total
end
function Rested.ShowPlayed( realm, name, charStruct )
	local rn = realm..":"..name
	if (realm == Rested.realm and name == Rested.name) then
		rn = COLOR_GREEN..rn..COLOR_END;
	end
	local lineCount = 0
	if charStruct.totalPlayed then
		lineCount = 1
		Rested.maxPlayed = max( Rested.maxPlayed or 0, charStruct.totalPlayed )

		Rested.strOut = string.format("%s :: %s",
				SecondsToTime( charStruct.totalPlayed ),
				rn)
		table.insert( Rested.charList,
				{ ( charStruct.totalPlayed / Rested.maxPlayed ) * 150,
					Rested.strOut
				}
		)
	end
	return lineCount
end