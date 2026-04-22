-- RestedIsNext.lua
RESTED_SLUG, Rested  = ...

Rested.InitCallback( function()
		Rested_options.minimapAngle = Rested_options.minimapAngle or 180 -- 225?
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
			print("OnEvent: "..event..","..addonName..","..RESTED_SLUG)
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
	print("OnLeave")
	GameTooltip:Hide()
end

function Rested.MinimapButton_OnClick(self)
	print("OnClick")
end

function Rested.MinimapButton_OnDragStart(self)
	print("OnDragStart: ",self.isDragging)
end

function Rested.MinimapButton_OnDragStop(self)
	print("OnDragStop: ",self.isDragging)
end
-- function MyAddon_MinimapButton_OnClick(self, button)
--     if isDragging then return end

--     if button == "LeftButton" then
--         -- TODO: toggle your main frame
--         print("MyAddon: left clicked!")
--     elseif button == "RightButton" then
--         -- TODO: open a menu
--         print("MyAddon: right clicked!")
--     end
-- end

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