-- RestedVault.lua

function Rested.Rewards_Update( ... )
	print( "WEEKLY_REWARDS_UPDATE:" )
end

function Rested.Rewards_ItemChanged( ... )
	print( "WEEKLY_REWARDS_ITEM_CHANGED:" )
end

function Rested.Rewards_Hide( ... )
	print( "WEEKLY_REWARDS_HIDE:" )
end

Rested.EventCallback( "WEEKLY_REWARDS_UPDATE", Rested.Rewards_Update )
Rested.EventCallback( "WEEKLY_REWARDS_ITEM_CHANGED", Rested.Rewards_ItemChanged )
Rested.EventCallback( "WEEKLY_REWARDS_HIDE", Rested.Rewards_Hide )
