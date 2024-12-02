-- RestedTalents.lua
RESTED_SLUG, Rested = ...

function Rested.TalentsGetStr()
	local activeConfigID = C_ClassTalents.GetActiveConfigID()
	local importString = C_Traits.GenerateImportString(activeConfigID)

	Rested.me.talentHash = importString
end

--Rested.InitCallback( Rested.TalentsGetStr )
Rested.EventCallback( "SPELLS_CHANGED", Rested.TalentsGetStr )
Rested.EventCallback( "TRAIT_CONFIG_UPDATED", Rested.TalentsGetStr )

table.insert( Rested.CSVFields, {"TalentString", "talentHash"} )
