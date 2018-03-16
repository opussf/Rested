-- RestedArtifactInfo.lua

-- https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/FrameXML/ArtifactBar.lua

-- API to use:
-- HasArtifactEquipped()

-- local artifactItemID, _, _, _, artifactTotalXP, artifactPointsSpent, _, _, _, _, _, _, artifactTier = C_ArtifactUI.GetEquippedArtifactInfo();
-- local numPointsAvailableToSpend, xp, xpForNextPoint = ArtifactBarGetNumArtifactTraitsPurchasableFromXP(artifactPointsSpent, artifactTotalXP, artifactTier);
-- self:SetBarValues(xp, 0, xpForNextPoint, numPointsAvailableToSpend + artifactPointsSpent);



-- function ArtifactBarGetNumArtifactTraitsPurchasableFromXP(pointsSpent, artifactXP, artifactTier)
-- 	local numPoints = 0;
-- 	local xpForNextPoint = C_ArtifactUI.GetCostForPointAtRank(pointsSpent, artifactTier);
-- 	while artifactXP >= xpForNextPoint and xpForNextPoint > 0 do
-- 		artifactXP = artifactXP - xpForNextPoint;

-- 		pointsSpent = pointsSpent + 1;
-- 		numPoints = numPoints + 1;

-- 		xpForNextPoint = C_ArtifactUI.GetCostForPointAtRank(pointsSpent, artifactTier);
-- 	end
-- 	return numPoints, artifactXP, xpForNextPoint;
-- end

-- self:RegisterEvent("PLAYER_ENTERING_WORLD");
-- self:RegisterEvent("UNIT_INVENTORY_CHANGED");
-- self:RegisterEvent("ARTIFACT_XP_UPDATE");
-- self:RegisterEvent("UPDATE_EXTRA_ACTIONBAR");
-- self:RegisterEvent("CVAR_UPDATE");

function Rested.CaptureArtifactInfo()
	local artifactItemID, _, artifactName, _, artifactTotalXP, artifactPointsSpent, _, _, _, _, _, _, artifactTier = C_ArtifactUI.GetEquippedArtifactInfo()
	local xpForNextPoint = C_ArtifactUI.GetCostForPointAtRank( artifactPointsSpent, artifactTier )

	Rested_restedState[Rested.realm][Rested.name].artifact =
			Rested_restedState[Rested.realm][Rested.name].artifact or {}
	Rested_restedState[Rested.realm][Rested.name].artifact[artifactItemID] =
			Rested_restedState[Rested.realm][Rested.name].artifact[artifactItemID] or {}
	Rested_restedState[Rested.realm][Rested.name].artifact[artifactItemID].name = artifactName
	Rested_restedState[Rested.realm][Rested.name].artifact[artifactItemID].level = artifactPointsSpent
	Rested_restedState[Rested.realm][Rested.name].artifact[artifactItemID].tier = artifactTier
	Rested_restedState[Rested.realm][Rested.name].artifact[artifactItemID].currentXP = artifactTotalXP
	Rested_restedState[Rested.realm][Rested.name].artifact[artifactItemID].maxLvlXP = xpForNextPoint

	if( not Rested.updateArtifactTS or Rested.updateArtifactTS <= time() ) then
		print( string.format( "Your weapon (%s) is level: %i.", artifactName, artifactPointsSpent ) )
		print( artifactTotalXP.." / "..xpForNextPoint )
		Rested.updateArtifactTS = time() + 1
	end
end

Rested.InitCallback( Rested.CaptureArtifactInfo )
Rested.EventCallback( "PLAYER_ENTERING_WORLD", Rested.CaptureArtifactInfo )
Rested.EventCallback( "ARTIFACT_XP_UPDATE", Rested.CaptureArtifactInfo )
Rested.EventCallback( "UNIT_INVENTORY_CHANGED", Rested.CaptureArtifactInfo )
