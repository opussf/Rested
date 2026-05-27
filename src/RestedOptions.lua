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
end
function Rested.OptionsPanel_OKAY()
	-- Data was recorded, clear the temp
	-- this is now the 'close' button
end

function Rested.OptionsPanel_Refresh()
	-- Called when options panel is opened.
	-- print("Rested Options Panel Refresh: ")
end

-------------

function Rested.OptionsPanel_CheckButton_OnShow( self, option, text )
	getglobal(self:GetName().."Text"):SetText(text);
	self:SetChecked(Rested_options[option]);
end
function Rested.OptionsPanel_CheckButton_OnClick( self, option )
	Rested_options[option] = self:GetChecked()
end
function Rested.OptionsPanel_RadioButton_OnClick( self, otherRadioButtons ) --"nagIncludeToEndOfLevel",[RestedOptionsFrame_IncludeOverPercent])
	Rested_options[self:GetAttribute("var")] = true
	for _, f in ipairs(otherRadioButtons) do
		f:SetChecked(false)
		Rested_options[f:GetAttribute("var")] = nil
	end
end
function Rested.OptionsPanel_DurationEditBox_Onload( self, option, text )
	self:SetText(Rested.SecondsToText(Rested_options[option]))
end
function Rested.OptionsPanel_DurationEditBox_OnEditFocusLost( self, option )
	Rested_options[option] = Rested.TextToSeconds( self:GetText() )
	self:SetText(Rested.SecondsToText(Rested_options[option]))
end

function Rested.OptionsPanel_EditBox_OnShow( self, option )
	self:SetText( tostring( Rested_options[option] ) )
	self:SetCursorPosition(0)
end
function Rested.OptionsPanel_EditBox_OnEditFocusLost( self, option )
	Rested_options[option] = tonumber( self:GetText() )
end

Rested.commandList["options"] = {
		["help"] = {"","Open the options panel"},
		["func"] = function() Settings.OpenToCategory( RestedOptionsFrame.category:GetID() ) end,
}
