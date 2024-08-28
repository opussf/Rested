-- RestedCSV.lua

function Rested.MakeCSV()
	strOut = "Realm,Name,Faction,Race,Class,Gender,Level,iLvl\n"
	for realm, chars in Rested.SortedPairs( Rested_restedState ) do
		for name, charStruct in Rested.SortedPairs( chars ) do
			strOut = strOut .. string.format( "%s,%s,%s,%s,%s,%s,%i,%i\n",
				realm, name, charStruct.faction, charStruct.race, charStruct.class,
				charStruct.gender, charStruct.lvlNow, charStruct.iLvl )
		end
	end
	Rested_csv = strOut
	Rested.Print("CSV report created. /reload or log out to save.")
end

Rested.EventCallback( "PLAYER_ENTERING_WORLD", function() Rested_csv=nil; end )
Rested.commandList["csv"] = {["help"] = {"","Make CSV export"}, ["func"] = Rested.MakeCSV }
