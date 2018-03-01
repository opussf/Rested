-- RestediLvl.lua

Rested.dropDownMenuTable["iLvl"] = "ilvl";
Rested.commandList["ilvl"] = function()
	Rested.reportName = "Item Level";
	Rested.ShowReport( Rested.iLevel );
end
function Rested.iLevel( realm, name, charStruct )
	-- lvl
	local rn = realm..":"..name;
	if (realm == Rested.realm and name == Rested.name) then
		rn = COLOR_GREEN..rn..COLOR_END;
	end
	--if charStruct.lvlNow < Rested.maxLevel then
	Rested.strOut = string.format("%d :: %d :: %s",
			charStruct.iLvl or 0,
			charStruct.lvlNow,
			rn);
	table.insert( Rested.charList, {((charStruct.iLvl or 0) / Rested_options["maxiLvl"]) * 150, Rested.strOut} );
	return 1;
--	end
--	return 0;
end