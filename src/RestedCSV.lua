-- RestedCSV.lua

function Rested.sorted_pairs( tableIn )  -- @TODO: Move this to Rested.lua and clean up some functions there.
	local keys = {}
	for k in pairs( tableIn ) do table.insert( keys, k ) end
	table.sort( keys )
	local lcv = 0
	local iter = function()
		lcv = lcv + 1
		if keys[lcv] == nil then return nil
		else return keys[lcv], tableIn[keys[lcv]]
		end
	end
	return iter
end

function Rested.MakeCSV()
	strOut = "Realm,Name,Faction,Race,Class,Gender,Level,iLvl\n"
	for realm, chars in Rested.sorted_pairs( Rested_restedState ) do
		for name, charStruct in Rested.sorted_pairs( chars ) do
			strOut = strOut .. string.format( [["%s",%s,%s,%s,%s,%s,%i,%i\n]],
				realm, name, charStruct.faction, charStruct.race, charStruct.class,
				charStruct.gender, charStruct.lvlNow, charStruct.iLvl )
		end
	end
	Rested_csv = strOut
	Rested.Print("CSV report created. /reload or log out to save.")
end

Rested.EventCallback( "PLAYER_ENTERING_WORLD", function() Rested_csv=nil; end )
Rested.commandList["csv"] = {["help"] = {"","Make CSV export"}, ["func"] = Rested.MakeCSV }
