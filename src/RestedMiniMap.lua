-- RestedIsNext.lua
RESTED_SLUG, Rested  = ...

Rested.InitCallback( function()
		Rested_options.minimapAngle = Rested_options.minimapAngle or 225 -- 225?
	end
)

local function AngleToPosition(angle, radius)
	local rad = math.rad(angle)
	return math.cos(rad) * radius, math.sin(rad) * radius
end

function Rested.MinimapButton_UpdatePosition(angle)
	print("UpdatePosition")
	local radius = Minimap:GetWidth() / 2
	local x, y = AngleToPosition(angle, radius) -- hardcoded radius
	RestedMinimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function Rested.MinimapButton_OnLoad(self)
	self:RegisterForDrag("LeftButton")
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	self:RegisterEvent("ADDON_LOADED")
	self:SetScript("OnEvent", function(self, event, addonName)
		if addonName == RESTED_SLUG then
			-- print("OnEvent: "..event..","..addonName..","..RESTED_SLUG)
			Rested.MinimapButton_UpdatePosition(Rested_options.minimapAngle)
			self:UnregisterEvent("ADDON_LOADED")
		end
	end)
end

function Rested.MinimapButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:AddLine("Rested")
	GameTooltip:AddLine(COLOR_GREY.."Left-click|r to toggle", 1, 1, 1)
	GameTooltip:AddLine(COLOR_GREY.."Drag|r to move", 1, 1, 1)
	GameTooltip:Show()
end

function Rested.MinimapButton_OnLeave(self)
	GameTooltip:Hide()
end

function Rested.MinimapButton_OnClick(self, button)
	print("OnClick", button, self.isDragging)
	if not self.isDragging then
		if button == "LeftButton" then
			if RestedUIFrame:IsVisible() then
				RestedUIFrame:Hide()
			else
				RestedUIFrame:Show()
			end
		end
	end
end

function Rested.MinimapButton_OnDragStart(self, button)
	self.isDragging = true
	print("OnDragStart: ",self.isDragging, button)
	self:SetScript("OnUpdate", function()
		local mx, my = Minimap:GetCenter()
		local cx, cy = GetCursorPosition()
		local scale = UIParent:GetEffectiveScale()
		cx, cy = cx / scale, cy / scale
		Rested_options.minimapAngle = math.deg(math.atan2(cy - my, cx - mx))
		print(Rested_options.minimapAngle)
		Rested.MinimapButton_UpdatePosition(Rested_options.minimapAngle)
	end)
end

function Rested.MinimapButton_OnDragStop(self)
	self.isDragging = nil
	self:SetScript("OnUpdate", nil)
end

-- function MyAddon_MinimapButton_OnDragStart(self)
--     isDragging = true
--     self:SetScript("OnUpdate", function()
--         local mx, my = Minimap:GetCenter()
--         local cx, cy = GetCursorPosition()
--         local scale  = UIParent:GetEffectiveScale()
--         cx, cy = cx / scale, cy / scale

--         local angle = math.deg(math.atan2(cy - my, cx - mx))
--         SaveAngle(angle)
--         UpdateButtonPosition(angle)
--     end)
-- end

-- function MyAddon_MinimapButton_OnDragStop(self)
--     isDragging = false
--     self:SetScript("OnUpdate", nil)
-- end