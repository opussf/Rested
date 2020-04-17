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
        local auctionCount, oldestAuction = 0, time()
        for id in pairs( charStruct.Auctions ) do
            auctionCount = auctionCount + 1
            oldestAuction = min( oldestAuction, charStruct.Auctions[id].created )
        end
        Rested.strOut = string.format( "%d (%s to go) %s",
                auctionCount, SecondsToTime( time() - oldestAuction ), rn )
        table.insert( Rested.charList,
                { ( ( oldestAuction + AuctionAge - time() ) / AuctionAge ) * 150,
                Rested.strOut } )

--[[
table.insert( Rested.charList,
                    { ( ( struct.mostRecent + Rested_options.mountHistoryAge - time() ) / Rested_options.mountHistoryAge ) * 150,
                    Rested.strOut } )
]]
        return 1
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
