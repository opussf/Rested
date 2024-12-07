-- RestedMythic.lua @VERSION@
RESTED_SLUG, Rested  = ...

-- Event CHALLENGE_MODE_MAPS_UPDATE

function Rested.MythicStuff()
	for b = 0, 4 do
		for s = 1, C_Container.GetContainerNumSlots(b) do
			local itemId = C_Container.GetContainerItemID(b, s)
			if (itemId == 180653) then
				local _, _, mythicPlusMapID = strsplit( ":", C_Container.GetContainerItemLink(b, s) )
				Rested.me.mythic_currentSeasonScore = C_PlayerInfo.GetPlayerMythicPlusRatingSummary("player").currentSeasonScore
				Rested.me.mythic_keyMapName = C_ChallengeMode.GetMapUIInfo( mythicPlusMapID )
				Rested.me.mythic_keyMapLevel = C_MythicPlus.GetOwnedKeystoneLevel()
				if Rested.me.mythic_currentSeasonScore == 0 and not Rested.me.mythic_keyMapName then
					Rested.my.mythic_currentSeasonScore = nil
				end
			end
		end
	end
end

Rested.EventCallback( "PLAYER_ENTERING_WORLD", Rested.MythicStuff )

function Rested.MythicReport( realm, name, charStruct )
	local rn = Rested.FormatName( realm, name )
	if charStruct.mythic_currentSeasonScore or charStruct.mythic_keyMapName then
		table.insert( Rested.charList, { charStruct.mythic_currentSeasonScore,
				string.format( "%s : %s :: %s",
					charStruct.mythic_currentSeasonScore, ( charStruct.mythic_keyMapLevel and charStruct.mythic_keyMapLevel.." - "..charStruct.mythic_keyMapName or "No Key" ),
					rn
				)
			}
		)
		return 1
	end
end

table.insert(Rested.filterKeys, mythic_keyMapName)
table.insert(Rested.filterKeys, mythic_keyMapLevel)

Rested.dropDownMenuTable["Mythic"] = "mythic"
Rested.commandList["mythic"] = {["help"] = {"", "Show Mythic key report"}, ["func"] = function()
		Rested.reportName = "Mythic",
		Rested.UIShowReport( Rested.MythicReport )
	end
}
