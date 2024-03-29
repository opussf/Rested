-- RestedPlayed.lua

function Rested.StoreTimePlayed( total, currentLvl )
	--print( "Rested.StoreTimePlayed: "..total.." - "..currentLvl )
	Rested_restedState[Rested.realm][Rested.name].totalPlayed = total
end

function Rested.TimePlayedRequest()
	if not Rested.lastTimePlayedRequest or Rested.lastTimePlayedRequest+600 < time() then
		Rested.lastTimePlayedRequest = time()
		RequestTimePlayed()
	end
end

Rested.EventCallback( "PLAYER_LEAVING_WORLD", function() Rested.lastTimePlayedRequest=nil; Rested.TimePlayedRequest() end )
Rested.EventCallback( "PLAYER_ENTERING_WORLD", Rested.TimePlayedRequest )
Rested.EventCallback( "TIME_PLAYED_MSG", Rested.StoreTimePlayed )

Rested.dropDownMenuTable["Played"] = "played"
Rested.commandList["played"] = { ["help"] = {"","Time played"}, ["func"] = function()
		Rested.reportName = "Time Played"
		Rested.UIShowReport( Rested.PlayedReport )
	end
}
function Rested.PlayedReport( realm, name, charStruct )
	local rn = Rested.FormatName( realm, name )
	if( charStruct.totalPlayed ) then
		Rested.maxPlayed = math.max( Rested.maxPlayed or 0, charStruct.totalPlayed or 0 )
		Rested.strOut = string.format( "%s : %s",
				SecondsToTime( charStruct.totalPlayed ),
				rn )
		table.insert( Rested.charList,
				{ ( charStruct.totalPlayed / Rested.maxPlayed ) * 150, Rested.strOut } )
		return 1
	end
end
