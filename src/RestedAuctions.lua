-- RestedAzerite.lua

function Rested.AuctionAuction( AuctionId )
    Rested.Print( "AuctionAuction( "..AuctionId.." )" )
    Rested.me["Auctions"] = Rested.me["Auctions"] or {}
    Rested.me.Auctions[AuctionId] = { ["created"] = time() }
end

Rested.EventCallback( "AUCTION_HOUSE_AUCTION_CREATED", Rested.AuctionAuction )

Rested.dropDownMenuTable["Auctions"] = "auctions"
Rested.commandList["auctions"] = {["help"] = {"","Show auction counts"}, ["func"] = function()
        Rested.reportName = "Auctions"
        Rested.UIShowReport( Rested.AuctionsReport )
    end
}
function Rested.AuctionsReport( realm, name, charStruct )
    local AuctionAge = 48 * 3600 -- 48 hours
    local rn = Rested.FormatName( realm, name )
    if charStruct.Auctions then
        local now = time()
        local activeCount, activeOldest = 0, now
        local expiredCount, expiredOldest = 0, now
        for id in pairs( charStruct.Auctions ) do
            if charStruct.Auctions[id].created <= now - AuctionAge then
                expiredCount = expiredCount + 1
                expiredOldest = min( expiredOldest, charStruct.Auctions[id].created )
            else
                activeCount = activeCount + 1
                activeOldest = min( activeOldest, charStruct.Auctions[id].created )
            end
        end
        local lineCount = 0
        if activeCount > 0 then
            Rested.strOut = string.format( "%d (%s to go) %s",
                    activeCount, SecondsToTime( now - activeOldest ), rn )
            table.insert( Rested.charList,
                    { ( ( activeOldest + AuctionAge - time() ) / AuctionAge ) * 150,
                    Rested.strOut } )
            lineCount = lineCount + 1
        end
        if expiredCount > 0 then
            Rested.strOut = string.format( "%d (EXPIRED) %s",
                    expiredCount, rn )
            table.insert( Rested.charList,
                    { 0, Rested.strOut } )
            lineCount = lineCount + 1
        end

--[[
table.insert( Rested.charList,
                    { ( ( struct.mostRecent + Rested_options.mountHistoryAge - time() ) / Rested_options.mountHistoryAge ) * 150,
                    Rested.strOut } )
]]
        return lineCount
    end
    return 0
end

--[[
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
]]
