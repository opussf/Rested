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




function Rested.OptionsPanel_CheckButton_OnShow( self, option, text )
	getglobal(self:GetName().."Text"):SetText(text);
	self:SetChecked(Rested_options[option]);
end
function Rested.OptionsPanel_CheckButton_OnClick( self, option )
	Rested_options[option] = self:GetChecked()
end
function Rested.OptionsPanel_RadioButton_OnClick( self, otherRadioButtons ) --"nagIncludeToEndOfLevel",[RestedOptionsFrame_IncludeOverPercent])
	print(self:GetChecked(), self:GetAttribute("var"))
	for _, f in ipairs(otherRadioButtons) do
		print(_,f)
		f:SetChecked(false)
	end
end
function Rested.OptionsPanel_DurationEditBox_Onload( self, option, text )
	self:SetText(Rested.SecondsToText(Rested_options[option]))
end
function Rested.OptionsPanel_DurationEditBo_TextChanged( self, option )
	Rested_options[option] = Rested.TextToSeconds( self:GetText() )
end


Rested.commandList["options"] = {
		["help"] = {"","Open the options panel"},
		["func"] = function() Settings.OpenToCategory( RestedOptionsFrame.category:GetID() ) end,
}


--[[

RestedOptionsFrame_IncludeOverPercent:SetChecked(false);self:SetChecked(true)


function INEED.OptionsPanel_Duration_TextChanged( self, option )
	if self:HasFocus() then
		local myName = strmatch(self:GetName(), "_(%a*)$")
		local duration = INEED_options[option]
		local newValue = duration
		local calcStruct = INEED.durationKeys[myName]
		if calcStruct then
			local displayValue = tonumber( self:GetNumber() ) or 0
			local originalSec = math.floor( (duration/calcStruct[1])%calcStruct[2] ) * calcStruct[1]
			newValue = ( duration - originalSec ) + ( displayValue * calcStruct[1] )
		end
		INEED.OptionPanel_KeepOriginalValue( option )
		INEED_options[option] = newValue
	end
end

]]