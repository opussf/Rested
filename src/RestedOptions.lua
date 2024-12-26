RESTED_SLUG, Rested  = ...

function Rested.OptionsPanel_OnLoad(panel)
	panel.name = "Rested"
	RestedOptionsFrame_Title:SetText(RESTED_MSG_ADDONNAME.." v"..RESTED_MSG_VERSION)

	panel.OnCommit = Rested.OptionsPanel_OKAY
	panel.OnDefault = function() end
	panel.OnRefresh = Rested.OptionsPanel_Refresh

	-- Register Options frame
	local category, layout = Settings.RegisterCanvasLayoutCategory( panel, panel.name )
	panel.category = category
	Settings.RegisterAddOnCategory(category)
end
function Rested.OptionsPanel_Reset()
	-- Called from Addon_Loaded
	-- INEED.OptionsPanel_Refresh()
end
function Rested.OptionsPanel_OKAY()
	-- Data was recorded, clear the temp
end

function Rested.OptionsPanel_Refresh()
	-- Called when options panel is opened.
end
