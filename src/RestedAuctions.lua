-- RestedAzerite.lua

function Rested.AuctionsClear()
    local AuctionAge = 48 * 3600 -- 48 hours
    local activeCount = 0
    if Rested.me.Auctions then
        for aID in pairs( Rested.me.Auctions ) do
            if Rested.me.Auctions[aID].created <= time() - AuctionAge then
                Rested.me.Auctions[aID] = nil
            else
                activeCount = activeCount + 1
            end
        end
        if activeCount == 0 then
            Rested.me.Auctions = nil
        end
    end
end

function Rested.AuctionCreate( AuctionId )
    Rested.Print( "AuctionAuction( "..AuctionId.." )" )
    Rested.me["Auctions"] = Rested.me["Auctions"] or {}
    Rested.me.Auctions[AuctionId] = { ["created"] = time() }
end

Rested.InitCallback( Rested.AuctionsClear )
Rested.EventCallback( "AUCTION_HOUSE_AUCTION_CREATED", Rested.AuctionCreate )

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

-- Reminders

function Rested.AuctionsExpired( realm, name, struct )
    local AuctionAge = 48 * 3600
    returnStruct = {}
    reminderTime = time() + 60
    expiredCount = 0
    if struct.Auctions then
        for aID in pairs( struct.Auctions ) do
            if struct.Auctions[aID].created <= time() - AuctionAge then
                expiredCount = expiredCount + 1
            end
        end
        table.insert( returnStruct[reminderTime],
                string.format( "%s has expired auctions.",
                        Rested.FormatName( realm, name )
                )
        )
    end
    return returnStruct
end
Rested.ReminderCallback( Rested.AuctionsExpired )

--[[

function Rested.ReminderIsNotResting( realm, name, struct )
    returnStruct = {}
    reminderTime = time() + 60
    if( not struct.isResting ) then
        if( not returnStruct[reminderTime] ) then
            returnStruct[reminderTime] = {}
        end
        table.insert( returnStruct[reminderTime],
                string.format( "%s is not resting.", Rested.FormatName( realm, name, false ) ) )
    end
    return returnStruct
end
Rested.ReminderCallback( Rested.ReminderIsNotResting )


]]
