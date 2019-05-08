-- RestedUI.lua
Rested.showNumBars = 6
Rested.displayList = {}
-- Rested.displayList = { { displayValue (% of 100), "display text" }, {value, 'text'}, ... }

function Rested.UIBuildBars()
	if( not Rested.bars ) then
		Rested.bars = {}
		for idx = 1, Rested.showNumBars do
			Rested.bars[idx] = {}
			local item = CreateFrame("StatusBar", "Rested_ItemBar"..idx, RestedScrollContents, "Rested_RestedBarTemplate")
			Rested.bars[idx].bar = item
			if idx == 1 then
				item:SetPoint("TOPLEFT", "RestedScrollFrame", "TOPLEFT", 5, -5)
			else
				item:SetPoint("TOPLEFT", Rested.bars[idx-1].bar, "BOTTOMLEFT", 0, 0)
			end
			item:SetMinMaxValues(0, 150)
			item:SetValue(0)
			--item:SetScript("OnClick", Rested.BarClick);
			local text = item:CreateFontString("Rested_ItemText"..idx, "OVERLAY", "Rested_RestedBarTextTemplate")
			Rested.bars[idx].text = text
			text:SetPoint("TOPLEFT", item, "TOPLEFT", 5, 0)
		end
		print( "Bars built" )
	end
end
Rested.InitCallback( Rested.UIBuildBars )

function Rested.UIOnDragStart()
	RestedUIFrame:StartMoving()
end
function Rested.UIOnDragStop()
	RestedUIFrame:StopMovingOrSizing()
end