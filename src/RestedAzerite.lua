-- RestedAzerite.lua

function Rested.CaptureAzerothItem()
    if C_AzeriteItem.HasActiveAzeriteItem() then
        local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
        local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo( azeriteItemLocation )
        local azeriteItem = Item:CreateFromItemLocation( azeriteItemLocation )
        Rested.me["heart"] = {
            ["currentiLvl"] = azeriteItem:GetCurrentItemLevel(),
            ["currentLevel"] = C_AzeriteItem.GetPowerLevel( azeriteItemLocation ),
            ["currentXP"] = xp,
            ["totalLevelXP"] = totalLevelXP,
        }
    end
end
--Rested.EventCallback( "PLAYER_ENTERING_WORLD", Rested.CaptureAzerothItem )  -- seems to set the item level to 0
Rested.EventCallback( "UNIT_INVENTORY_CHANGED", Rested.CaptureAzerothItem )
Rested.EventCallback( "AZERITE_ITEM_EXPERIENCE_CHANGED", Rested.CaptureAzerothItem )

Rested.dropDownMenuTable["Azerite"] = "azerite"
Rested.commandList["azerite"] = {["help"] = {"","Show azerite neck values"}, ["func"] = function()
        Rested.reportName = "Hearts of Azeroth"
        Rested.UIShowReport( Rested.AzeriteReport )
    end
}
function Rested.AzeriteReport( realm, name, charStruct )
    local rn = Rested.FormatName( realm, name )
    if charStruct.heart then
        totalLevel = charStruct.heart.currentLevel + ( charStruct.heart.currentXP / charStruct.heart.totalLevelXP )
        Rested_misc["heartMaxLevel"] = math.max( Rested_misc["heartMaxLevel"] or 0, math.ceil( totalLevel ) )
        Rested.strOut = string.format( "%0.2f (%d / %d) - %s",
                totalLevel,
                charStruct.heart.currentiLvl,
                charStruct.iLvl,
                rn )
        table.insert( Rested.charList, { (totalLevel / Rested_misc.heartMaxLevel) * 150, Rested.strOut } )
        return 1
    end
    return 0
end

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

    GetItemInfo("Heart of Azeroth")
end

azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation)
azeriteItem:GetCurrentItemLevel()


]]
