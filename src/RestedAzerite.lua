-- RestedAzerite.lua

function Rested.CaptureAzerothItem()
    if C_AzeriteItem.HasActiveAzeriteItem() then
        local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
        local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo( azeriteItemLocation )
        Rested.me["heart"] = {
            ["currentLevel"] = C_AzeriteItem.GetPowerLevel( azeriteItemLocation ),
            ["currentXP"] = xp,
            ["totalLevelXP"] = totalLevelXP,
        }
    end
end
Rested.EventCallback( "PLAYER_ENTERING_WORLD", Rested.CaptureAzerothItem )
--Rested.EventCallback( "UNIT_INVENTORY_CHANGED", Rested.CaptureAzerothItem )
Rested.EventCallback( "AZERITE_ITEM_EXPERIENCE_CHANGED", Rested.CaptureAzerothItem )


--[[
if C_AzeriteItem.HasActiveAzeriteItem() then

        tooltip:AddLine(" ")

        local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
        local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)

        tooltip:AddDoubleLine(L["Artifact"], "Heart of Azeroth",1, 1, 1, 0, 1, 1)
        tooltip:AddDoubleLine(L["Artifact Power"],C_AzeriteItem.GetPowerLevel(azeriteItemLocation), 1, 1, 1, 0, 1, 0)
        tooltip:AddDoubleLine(L["Power to next rank"],totalLevelXP - xp, 1, 1, 1, 1, 0, 0)
        tooltip:AddDoubleLine(L["Progress in rank %"], string_format("%.1f", xp/totalLevelXP*100) , 1, 1, 1, 0, 1, 0)

end



local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
if azeriteItemLocation then
    local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation);
    print(azeriteItem:GetItemName())
end


]]
