#!/usr/bin/env lua

dofile("/Applications/World of Warcraft/WTF/Account/OPUSSF/SavedVariables/Rested.lua");

restingRate = {};
restingRate[0] = (5/(32*3600));
restingRate[1] = (5/(8*3600));

strOut = "{\"restedToons\": {\n";
strOut = strOut .. "\t\"resting\": \""..restingRate[1].."\",\n";
strOut = strOut .. "\t\"notresting\": \""..restingRate[0].."\",\n";
strOut = strOut .. "\t\"maxLevel\": \""..Rested_options.maxLevel.."\",\n";
strOut = strOut .. "\t\"chars\": [\n";


for realm, chars in pairs(Rested_restedState) do
	for name, c in pairs(chars) do
		if not c.ignore or c.ignore < os.time()then
			if pastFirst then
				strOut = strOut .. ",\n";
			end

			strOut = strOut .. "\t\t{\"rn\": \"" .. realm .. "\", ";
			strOut = strOut .. "\"cn\": \"" .. name .. "\", ";
			strOut = strOut .. "\"isResting\": " .. (c.isResting and "1" or "0") .. ", ";
			strOut = strOut .. "\"class\": \"" .. c.class .. "\", ";
			strOut = strOut .. "\"initAt\": " .. c.initAt .. ", ";
			strOut = strOut .. "\"updated\": " .. c.updated .. ", ";
			strOut = strOut .. "\"race\": \"" .. c.race .. "\", ";
			strOut = strOut .. "\"xpNow\": " .. c.xpNow .. ", ";
			strOut = strOut .. "\"xpMax\": " .. c.xpMax .. ", ";
			strOut = strOut .. "\"restedPC\": " .. c.restedPC .. ", ";
			strOut = strOut .. "\"lvlNow\": " .. c.lvlNow .. ", ";
			strOut = strOut .. "\"faction\": \"" .. c.faction .. "\", ";
			strOut = strOut .. "\"iLvl\": " .. (c.iLvl or 0) .. ", ";
			strOut = strOut .. "\"guild\": \"" .. c.guildName .."\",";
			strOut = strOut .. "\"gender\": \"" .. c.gender .. "\"}";


			pastFirst = true;

		end

	end
end

strOut = strOut .. "\n\t]\n}}";


print(strOut);
