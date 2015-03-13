#!/usr/bin/env lua

dofile("/Applications/World of Warcraft/WTF/Account/OPUSSF/SavedVariables/Rested.lua");

restingRate = {};
restingRate[0] = (5/(32*3600));
restingRate[1] = (5/(8*3600));

strOut = "<?xml version='1.0' encoding='utf-8' ?>\n";
strOut = strOut .. "<restedToons>\n";
strOut = strOut .. "\t<resting>"..restingRate[1].."</resting>\n";
strOut = strOut .. "\t<notresting>"..restingRate[0].."</notresting>\n";
strOut = strOut .. "\t<maxLevel>"..Rested_options.maxLevel.."</maxLevel>\n";
strOut = strOut .. "\t<cacheRate>6</cacheRate>\n"

for realm, chars in pairs(Rested_restedState) do
	for name, c in pairs(chars) do
		if not c.ignore or c.ignore < os.time() then

			strOut = strOut .. string.format('\t<c rn="%s" cn="%s" isResting="%s" class="%s" initAt="%s" updated="%s" '..
					'race="%s" xpNow="%s" xpMax="%s" restedPC="%s" lvlNow="%s" faction="%s" iLvl="%s" gender="%s"/>\n',
					realm, name, (c.isResting and "1" or "0"), c.class, c.initAt, c.updated, c.race, c.xpNow, c.xpMax, c.restedPC,
					c.lvlNow, c.faction, c.iLvl or 0, c.gender);

			if c.missions then
				for id, mi in pairs(c.missions) do
					strOut = strOut .. string.format('\t<m rn="%s" cn="%s" id="%s" started="%s" duration="%s" etc="%s" emc="%s" name="%s" />\n',
							realm, name, id, mi.started, mi.duration, mi.etcSeconds, (mi.emc or 0), mi.name )
				end
			end
			if c.garrisonCache then
				strOut = strOut .. string.format('\t<gc rn="%s" cn="%s" claimed="%s" />\n',
						realm, name, c.garrisonCache )
			end
		end
	end
end

strOut = strOut .. "</restedToons>";

print(strOut);
