-- RestedNext.lua
RESTED_SLUG, Rested  = ...

function Rested.GetCharacterIndex()
	Rested_restedState[Rested.realm][Rested.name].characterIndex = GetCVar("lastCharacterIndex")
	Rested_restedState[Rested.realm][Rested.name].isNextIndex = nil
	Rested.ShiftIsNextCharacterIndex()
	_, _, Rested.nextCharacterIndex = Rested.IsNext_GetMinMaxNext()

end
function Rested.SetNextCharacterIndex()
	if Rested.nextCharacterIndex then
		SetCVar("lastCharacterIndex", Rested.nextCharacterIndex)
	end
end

function Rested.IsNext_GetMinMaxNext()
	local isNextMin,isNextMax, isNextCharacterIndex = nil, nil, nil
	for r, _ in pairs( Rested_restedState ) do
		for n, cs in pairs( Rested_restedState[r] ) do
			if cs.isNextIndex then
				isNextMin = math.min( cs.isNextIndex, isNextMin or cs.isNextIndex )
				isNextMax = math.max( cs.isNextIndex, isNextMax or cs.isNextIndex )
				if isNextMin == cs.isNextIndex then
					isNextCharacterIndex = cs.characterIndex
				end
			end
		end
	end
	return isNextMin, isNextMax, isNextCharacterIndex
end
function Rested.ShiftIsNextCharacterIndex()
	local indexMin, indexMax = Rested.IsNext_GetMinMaxNext()
	local maxOut = nil
	if indexMin then
		local shiftVal = indexMin - 1
		for r, _ in pairs( Rested_restedState ) do
			for n, cs in pairs( Rested_restedState[r] ) do
				if cs.isNextIndex then
					cs.isNextIndex = cs.isNextIndex - shiftVal
					maxOut = math.max( cs.isNextIndex, maxOut or cs.isNextIndex )
				end
			end
		end
	end
	return maxOut
end
function Rested.SetNextCharacters( param )
	if( param and strlen( param ) > 0 ) then
		local currentIndex= Rested.ShiftIsNextCharacterIndex() or 0
		for searchName in string.gmatch( param, "([^ ]+)" ) do
			searchName = string.lower(searchName)
			for r, _ in pairs( Rested_restedState ) do
				for n, cs in pairs( Rested_restedState[r] ) do
					if string.find(string.lower(n), searchName) then
						currentIndex = currentIndex + 1
						cs.isNextIndex = currentIndex
					end
				end
			end
		end
		_, _, Rested.nextCharacterIndex = Rested.IsNext_GetMinMaxNext()
	else
		Rested.reportName = "Play Next"
		Rested.UIShowReport( Rested.NextCharsReport, true )
	end
end

Rested.InitCallback( Rested.GetCharacterIndex )
Rested.EventCallback( "PLAYER_LOGOUT", Rested.SetNextCharacterIndex )

Rested.dropDownMenuTable["IsNext"] = "isnext"
Rested.commandList["isnext"] = {
	["help"] = {"comma seperated character list", "Add the next characters to visit."},
	["func"] = Rested.SetNextCharacters,
}

function Rested.NextCharsReport( realm, name, charStruct )
	local rn = Rested.FormatName( realm, name )
	if charStruct.isNextIndex then
		Rested.strOut = string.format( "%s :: %s (%s)",
			charStruct.isNextIndex,
			rn,
			(charStruct.characterIndex or "?") )
		table.insert( Rested.charList, { 150 - charStruct.isNextIndex, Rested.strOut } )
		return 1
	end
end


--[[

/run local ci=2;for r,rs in pairs( Rested_restedState ) do for n,cs in pairs(rs) do cs.characterIndex=ci;ci=ci+1;end;end

/rested isnext ^a. ^b. ^c. ^d. ^e. ^f. ^g. ^h. ^i. ^j. ^k. ^l. ^m. ^n. ^o. ^p. ^q. ^r. ^s. ^t. ^u. ^v. ^w. ^x. ^y. ^z.

]]