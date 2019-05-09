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
end
Rested.InitCallback( function() Rested_options.mountHistoryAge = Rested_options.mountHistoryAge or 7200; end )
-- set the history age to 2 hours
Rested.EventCallback( "COMPANION_UPDATE", Rested.GetCurrentMount )
Rested.EventCallback( "COMPANION_LEARNED", Rested.BuildMountSpells )
--Rested.EventCallback( "COMPANION_UPDATE", function( ... ) cType, arg2 = ...; Rested.Print( string.format( "COMPANION_UPDATE( %s, %s )", (cType or "nil"), (arg2 or "nil") ) ); end )
