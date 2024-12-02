-- RestedTalents.lua
RESTED_SLUG, Rested = ...

function Rested.TalentsGetStr()
	local activeConfigID = C_ClassTalents.GetActiveConfigID()

	local configInfo = C_Traits.GetConfigInfo(activeConfigID)

	local importString = C_Traits.GenerateImportString(activeConfigID)

	Rested.me.talentHash = importString
	print( Rested.me.talentHash )
end

Rested.InitCallback( Rested.TalentsGetStr )
Rested.EventCallback( "PLAYER_ENTERING_WORLD", Rested.TalentsGetStr )
Rested.EventCallback( "TRAIT_CONFIG_UPDATED", Rested.TalentsGetStr )

table.insert( Rested.CSVFields, {"TalentString", "talentHash"} )
