-- RestedVault.lua
Rested.maxActivities = 9

function Rested.Rewards_Update( ... )
	print( "WEEKLY_REWARDS_UPDATE:" )
	Rested.me.weeklyRewards = ( C_WeeklyRewards.HasAvailableRewards() or nil )
	print( "Has Available Rewards: "..(Rested.me.weeklyRewards and "True" or "False"))
	activities = { "Dungeon", "PvP", "Raid" }
	countActivities, Rested.maxActivities = 0, 0
	for k,name in ipairs( activities ) do
		-- print( k, name )
		activityInfo = C_WeeklyRewards.GetActivities( tonumber(k) )
		for level, info in ipairs( activityInfo ) do
			Rested.maxActivities = Rested.maxActivities + 1
			if info.progress >= info.threshold then countActivities = countActivities + 1 end
			if info.progress > 0 and info.progress < info.threshold then
				print( string.format( "%s: (%i) %i/%i", name, info.index, info.progress, info.threshold ) )
			end
		end
	end
	if countActivities > 0 then
		Rested.me.weeklyActivity = countActivities
	end
end

function Rested.Rewards_ItemChanged( ... )
	print( "WEEKLY_REWARDS_ITEM_CHANGED:" )
end

-- function Rested.Rewards_Hide( ... )
-- 	print( "WEEKLY_REWARDS_HIDE:" )
-- end

Rested.EventCallback( "WEEKLY_REWARDS_UPDATE", Rested.Rewards_Update )
Rested.EventCallback( "WEEKLY_REWARDS_ITEM_CHANGED", Rested.Rewards_ItemChanged )
-- Rested.EventCallback( "WEEKLY_REWARDS_HIDE", Rested.Rewards_Hide )

Rested.InitCallback( function()
		LoadAddOn("Blizzard_WeeklyRewards")
	end
)

Rested.dropDownMenuTable["Vault"] = "vault"
Rested.commandList["vault"] = { ["help"] = {"","Show vault info"}, ["func"] = function()
		Rested.reportName = "Vault Report"
		Rested.UIShowReport( Rested.VaultReport )
	end
}

function Rested.VaultReport( realm, name, charStruct )
	local rn = Rested.FormatName( realm, name )
	if charStruct.weeklyRewards then
		table.insert( Rested.charList, { 150, rn } )
		return 1
	elseif charStruct.weeklyActivity then
		table.insert( Rested.charList, { charStruct.weeklyActivity * (150 / Rested.maxActivities), string.format( "%s: %i/%i", rn, charStruct.weekklyActivity, Rested.maxActivities )})
		return 1
	end
end