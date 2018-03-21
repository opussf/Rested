-- RestedMounts.lua

-- Event...
--[[

"PLAYER_AURAS_CHANGED"


name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId
 = UnitAura("unit", index or "name"[, "rank"[, "filter"] ] )

 ]]
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
	if( arg1 == "player" ) then  -- only look if the event is for the player
		if( IsMounted() ) then   -- and then, only if you are mounted
			if( not Rested.mountSpells ) then
				Rested.BuildMountSpells()
			end
			for an=1,40 do
				aName, _, aIcon, _, aType, _, _, _, _, _, aID = UnitAura( "player", an )
				if( aName ) then
					-- print( "Aura "..an..": "..aName.." ("..(aID or "nil")..")" )
					if( Rested.mountSpells[aID] and Rested.mountSpells[aID] == aName ) then
						-- print( aName.." is a mount." )
						if( not Rested.currentMount ) then
							print( "You have mounted: "..aName.." at "..date() )
							Rested.currentMount = aID
							Screenshot()
						end
					end
					--print( string.format( "Aura %s: %s (%s) (id=%s)", an, aName, aType, aId ) )
				else
					break
				end
			end
		else   -- not mounted, clear the currentMount
			--print( "is NOT mounted" )
			Rested.currentMount = nil
		end
	end
end

--Rested.InitCallback( Rested.BuildMountSpells )
Rested.EventCallback( "UNIT_AURA", Rested.GetCurrentMount )