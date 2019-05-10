-- RestedMounts.lua
function Rested.BuildMountSpells( )
	-- Build a table of [spellID] = "mountName"
	Rested.mountSpells = {}
	local mountIDs = C_MountJournal.GetMountIDs()
	for _, mID in pairs(mountIDs) do
		--print( mID )
		mName, mSpellID = C_MountJournal.GetMountInfoByID( mID )
		Rested.mountSpells[ mSpellID ] = mName
	end
end
function Rested.GetCurrentMount( ... )
	arg1 = ...
	if( arg1 == "MOUNT" ) then   -- only look if the event is for MOUNT
		if( not IsMounted() ) then -- IsMounted() seems to be updated AFTER this event, and after the auras are updated.
			Rested.currentMount = nil  -- it will be True (you are mounted) if you were mounted when the event fired (probably not from you)
		end
		if( not Rested.mountSpells ) then
			Rested.BuildMountSpells()
		end
		for an=1,40 do
			aName, _, _, aType, _, _, _, _, _, aID = UnitAura( "player", an )
			if( aName ) then
				--print( "Aura "..an..": "..aName.." ("..(aID or "nil")..")" )
				if( Rested.mountSpells[aID] and Rested.mountSpells[aID] == aName ) then
					--print( aName.." is a mount." )
					if( not Rested.currentMount ) then
						print( "You have mounted: "..aName.." at "..date() )
						Rested.currentMount = aID
						Screenshot()
						Rested_misc.mountHistory = Rested_misc.mountHistory or {}
						Rested_misc.mountHistory[time()] = aName
						Rested.PruneByAge( Rested_misc.mountHistory, Rested_options.mountHistoryAge )
					end
				end
				--print( string.format( "Aura %s: %s (%s) (id=%s)", an, aName, aType, aId ) )
			else
				break
			end
		end
	end
	Rested.PruneByAge( Rested_misc.mountHistory, Rested_options.mountHistoryAge )
end
Rested.InitCallback( function() Rested_options.mountHistoryAge = Rested_options.mountHistoryAge or 7200; end )
-- set the history age to 2 hours
Rested.EventCallback( "COMPANION_UPDATE", Rested.GetCurrentMount )
Rested.EventCallback( "COMPANION_LEARNED", Rested.BuildMountSpells )
--Rested.EventCallback( "COMPANION_UPDATE", function( ... ) cType, arg2 = ...; Rested.Print( string.format( "COMPANION_UPDATE( %s, %s )", (cType or "nil"), (arg2 or "nil") ) ); end )

Rested.dropDownMenuTable["Mounts"] = "mounts"
Rested.commandList["mounts"] = { ["help"] = {"","Show recent mount history"}, ["func"] = function()
		Rested.reportName = "Mount history"
		Rested.UIShowReport( Rested.MountReport )
	end
}
function Rested.MountReport( realm, name, charStruct )
	print( "size of charList: "..#Rested.charList )
	if( #Rested.charList == 0 and Rested_misc.mountHistory ) then
		Rested.PruneByAge( Rested_misc.mountHistory, Rested_options.mountHistoryAge )
		local mountCount = {}
		for ts, mount in pairs( Rested_misc.mountHistory ) do
			if( mountCount[mount] ) then
				mountCount[mount].count = mountCount[mount].count + 1
				mountCount[mount].mostRecent = math.max( mountCount[mount].mostRecent, ts )
			else
				mountCount[mount] = { ["count"] = 1, ["mostRecent"] = ts }
			end
		end
		local lineCount = 0
		for mount, struct in pairs( mountCount ) do
			Rested.strOut = string.format( "%d (%s ago) %s", struct.count, SecondsToTime( time() - struct.mostRecent ), mount )
			table.insert( Rested.charList,
					{ ( ( struct.mostRecent + Rested_options.mountHistoryAge - time() ) / Rested_options.mountHistoryAge ) * 150, Rested.strOut } )
			lineCount = lineCount + 1
		end
		return lineCount
	end
end

--[[

ts + mountHistoryAge = future expire
ts + mountHistoryAge - time()  = timeToGo

15000 + 2000 - 15000 = 2000 / 2000 = 1
13000 + 2000 - 15000 = 0 / 2000 = 0

	if( charStruct.ignore ) then
		timeToGo = charStruct.ignore - time()
		Rested.strOut = string.format( "%s: %s", SecondsToTime( timeToGo ), Rested.FormatName( realm, name ) )
		table.insert( Rested.charList, {(timeToGo/Rested_options.ignoreTime)*150, Rested.strOut} )
		return 1
	end
	return 0


most recent timestamp:  count - mount name

with mountHistoryAge at 2000
and now is 15000

mount time of 15000 should calculate to 150
mount time of 14000 should calculate to 75
mount time of 13000 should calculate to 0


15000 / 15000   = 1   * 150 = 150

15000 ->  2000 - ( 15000 - 15000 ) = 2000  / 2000 = 1     * 150
14000 ->  2000 - ( 15000 - 14000 ) = 1000  / 2000 = 0.5
13000 ->  2000 - ( 15000 - 13000 ) = 0     / 2000 = 0

15000 ->  2000 / ( 15000 - 15000 ) = err
14000 ->  2000 / ( 15000 - 14000 ) = 0.5
13000 ->  2000 / ( 15000 - 13000 ) = 1

time() - 15000  = 0


calculate future time





( maxAge - ( ts - time() ) ) / maxAge ) * 150





Rested.dropDownMenuTable["iLvl"] = "ilvl"
Rested.commandList["ilvl"] = { ["help"] = {"","Show iLvl report"}, ["func"] = function()
		Rested.reportName = "Item Level"
		Rested.UIShowReport( Rested.iLevelReport )
	end
}
function Rested.iLevelReport( realm, name, charStruct )
	local rn = Rested.FormatName( realm, name )
	Rested.strOut = string.format( "%d :: %d :: %s",
			charStruct.iLvl or 0,
			charStruct.lvlNow,
			rn)
	table.insert( Rested.charList, {((charStruct.iLvl or 0) / Rested_options["maxiLvl"]) * 150, Rested.strOut} )
	return 1
end
]]