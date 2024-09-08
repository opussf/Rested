

--[[

SecondsToTime( charStruct.totalPlayed )


C_TradeSkillUI.GetConcentrationCurrencyID(C_TradeSkillUI.GetChildProfessionInfo().professionID)

GetProfessionInfo( 8 ) = Engineering  (202?)



C_TradeSkillUI.GetBaseProfessionInfo()
C_TradeSkillUI.GetChildProfessionInfo().professionID
{
            Name = "ProfessionInfo",
            Type = "Structure",
            Fields =
            {
                { Name = "profession", Type = "Profession", Nilable = true },
                { Name = "professionID", Type = "number", Nilable = false },
                { Name = "sourceCounter", Type = "number", Nilable = false },
                { Name = "professionName", Type = "cstring", Nilable = false },
                { Name = "expansionName", Type = "cstring", Nilable = false },
                { Name = "skillLevel", Type = "number", Nilable = false },
                { Name = "maxSkillLevel", Type = "number", Nilable = false },
                { Name = "skillModifier", Type = "number", Nilable = false },
                { Name = "isPrimaryProfession", Type = "bool", Nilable = false },
                { Name = "parentProfessionID", Type = "number", Nilable = true },
                { Name = "parentProfessionName", Type = "cstring", Nilable = true },
            },
        },


/dump C_TradeSkillUI.GetConcentrationCurrencyID(C_TradeSkillUI.GetChildProfessionInfo().professionID)


C_CurrencyInfo.GetCurrencyInfo( tonumber( currencyID ) ).quantity      .maxQuantity






175880

function Rested.Cooldowns( realm, name, charStruct )
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
]]
--[[


https://www.wowinterface.com/forums/showthread.php?t=53953

https://wow.gamepedia.com/API_C_TradeSkillUI.GetRecipeInfo



C_TradeSkillUI.AnyRecipeCategoriesFiltered
C_TradeSkillUI.AreAnyInventorySlotsFiltered
C_TradeSkillUI.CanObliterateCursorItem
C_TradeSkillUI.CanTradeSkillListLink
C_TradeSkillUI.ClearInventorySlotFilter
C_TradeSkillUI.ClearPendingObliterateItem
C_TradeSkillUI.ClearRecipeCategoryFilter
C_TradeSkillUI.ClearRecipeSourceTypeFilter
C_TradeSkillUI.CloseObliterumForge
C_TradeSkillUI.CloseTradeSkill
C_TradeSkillUI.CraftRecipe
C_TradeSkillUI.DropPendingObliterateItemFromCursor
C_TradeSkillUI.GetAllFilterableInventorySlots
C_TradeSkillUI.GetAllRecipeIDs
C_TradeSkillUI.GetCategories
C_TradeSkillUI.GetCategoryInfo
C_TradeSkillUI.GetFilterableInventorySlots
C_TradeSkillUI.GetFilteredRecipeIDs
C_TradeSkillUI.GetObliterateSpellID
C_TradeSkillUI.GetOnlyShowLearnedRecipes
C_TradeSkillUI.GetOnlyShowMakeableRecipes
C_TradeSkillUI.GetOnlyShowSkillUpRecipes
C_TradeSkillUI.GetOnlyShowUnlearnedRecipes
C_TradeSkillUI.GetPendingObliterateItemID
C_TradeSkillUI.GetPendingObliterateItemLink
C_TradeSkillUI.GetRecipeCooldown
C_TradeSkillUI.GetRecipeDescription
C_TradeSkillUI.GetRecipeInfo
C_TradeSkillUI.GetRecipeItemLevelFilter
C_TradeSkillUI.GetRecipeItemLink
C_TradeSkillUI.GetRecipeItemNameFilter
C_TradeSkillUI.GetRecipeLink
C_TradeSkillUI.GetRecipeNumItemsProduced
C_TradeSkillUI.GetRecipeNumReagents
C_TradeSkillUI.GetRecipeReagentInfo
C_TradeSkillUI.GetRecipeReagentItemLink
C_TradeSkillUI.GetRecipeRepeatCount
C_TradeSkillUI.GetRecipeSourceText
C_TradeSkillUI.GetRecipeTools
C_TradeSkillUI.GetSubCategories
C_TradeSkillUI.GetTradeSkillLine
C_TradeSkillUI.GetTradeSkillLineForRecipe
C_TradeSkillUI.GetTradeSkillListLink
C_TradeSkillUI.GetTradeSkillTexture
C_TradeSkillUI.IsAnyRecipeFromSource
C_TradeSkillUI.IsDataSourceChanging
C_TradeSkillUI.IsInventorySlotFiltered
C_TradeSkillUI.IsNPCCrafting
C_TradeSkillUI.IsRecipeCategoryFiltered
C_TradeSkillUI.IsRecipeFavorite
C_TradeSkillUI.IsRecipeRepeating
C_TradeSkillUI.IsRecipeSearchInProgress
C_TradeSkillUI.IsRecipeSourceTypeFiltered
C_TradeSkillUI.IsTradeSkillGuild
C_TradeSkillUI.IsTradeSkillLinked
C_TradeSkillUI.IsTradeSkillReady
C_TradeSkillUI.ObliterateItem
C_TradeSkillUI.OpenTradeSkill
C_TradeSkillUI.SetInventorySlotFilter
C_TradeSkillUI.SetOnlyShowLearnedRecipes
C_TradeSkillUI.SetOnlyShowMakeableRecipes
C_TradeSkillUI.SetOnlyShowSkillUpRecipes
C_TradeSkillUI.SetOnlyShowUnlearnedRecipes
C_TradeSkillUI.SetRecipeCategoryFilter
C_TradeSkillUI.SetRecipeFavorite
C_TradeSkillUI.SetRecipeItemLevelFilter
C_TradeSkillUI.SetRecipeItemNameFilter
C_TradeSkillUI.SetRecipeRepeatCount
C_TradeSkillUI.SetRecipeSourceTypeFilter
C_TradeSkillUI.StopRecipeRepeat




if enchantID and string.len( enchantID ) > 0 then
        INEED.Print( string.format( "You need: %i %s (enchant:%s)", quantity, itemLink, enchantID ) )
        local recipeTable = C_TradeSkillUI.GetAllRecipeIDs()
        for i,recipeID in pairs(recipeTable) do
            if recipeID == tonumber(enchantID) then -- found the enchant link just needed
                --INEED.Print( "Needing :"..recipeID )
                local madeItemLink = C_TradeSkillUI.GetRecipeItemLink( recipeID )
                local minMade, maxMade = C_TradeSkillUI.GetRecipeNumItemsProduced( recipeID )
                INEED.addItem( madeItemLink, minMade * quantity ) -- If a tradeskill makes more than one at a time.

                local numReagents = C_TradeSkillUI.GetRecipeNumReagents( recipeID )
                for reagentIndex = 1, numReagents do
                    local _, _, reagentCount = C_TradeSkillUI.GetRecipeReagentInfo( recipeID, reagentIndex )
                    local reagentLink = C_TradeSkillUI.GetRecipeReagentItemLink( recipeID, reagentIndex )
                    INEED.addItem( reagentLink, reagentCount * quantity )
                end
                local toolName = C_TradeSkillUI.GetRecipeTools( recipeID )
                if toolName then
                    INEED.Print( toolName )
                    local _, toolLink = GetItemInfo( toolName )
                    INEED.addItem( toolLink, 1 )
                end
            end
        end
        return itemLink -- return done





prof1, prof2, archaeology, fishing, cooking, firstAid = GetProfessions();
^^^^ Indexes to be passed to:

name, icon, skillLevel, maxSkillLevel, numAbilities, spelloffset,
    skillLine, skillModifier, specializationIndex,
    specializationOffset = GetProfessionInfo(index)


This also seems to return some kind of data on the talent trees and guild perks.

Skill Line may be useful in internationalization using the number to check the profession rather than the text (which changes with localization).

The skill lines known are: Archaeology (794), Alchemy (171), Blacksmith (164), Cooking (184), Enchanting (333), Engineer (202), First Aid (129), Fishing (356), Herbalism (182), Inscription (773), Jewelcrafting (755), Leatherworking (165), Mining (186), Skinning (393), and Tailoring (197).

Alchemy Specializations known are: Elixir (2), Potion (3), Transmute (4)


# Report for this....

Do I *want* to see a report on this data?

what to report on?

Show:
How many chars have a profession?
[Alchemy :: 15]
Filtering on this makes a decent amount of sense... Filter on realm and now you know how many on this realm have the prof.
How to make this report?

First time through the alts, need to calculate sume.
2nd time through, need to create report, on the first alt...





Level of Profession...
How is this even measured with the new profession system?
Adding up to report on a max level no longer makes sense, except for Archeology.

Repoting on max level... Then needs to be 'adjusted'.

Keeping all of data seperate becomes confusing, and you hvae ( 4 * 7 ) * 50 + 50 (~1450) lines total...

Now you have:
Alt1: Harb: Base: 0-300
            BC: 0-75
            etc... 0-75
            etc... 0-150




Archeology is still 1-950
Other profs are segregated to expansions.





]]



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


Professions.
Cooking
Fishing
Arch



120 - Hunter
LW
Skinning
Engineering - goblin / gnome


Missing

300 75 75 75 75 100 100 150

profCount["Mining"] = 5
profCount["Tailoring"] = 5

5 - Mining
5 - Tailoring
4 -