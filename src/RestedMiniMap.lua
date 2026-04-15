-- Minimap Button (no libraries)
local MyAddon = MyAddon or {}

-- Default settings
local DEFAULT_ANGLE = 225 -- starting position on minimap (degrees)

-- Math helpers
local function AngleToPosition(angle, radius)
    local rad = math.rad(angle)
    return math.cos(rad) * radius, math.sin(rad) * radius
end

-- Create the button
local minimapButton = CreateFrame("Button", "MyAddonMinimapButton", Minimap)
minimapButton:SetSize(32, 32)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetFrameLevel(8)

-- Circular masking (clips the button to a circle like other minimap buttons)
minimapButton:SetClampedToScreen(false)

-- Normal texture (your icon)
local icon = minimapButton:CreateTexture(nil, "BACKGROUND")
icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark") -- replace with your icon
icon:SetAllPoints()
minimapButton:SetNormalTexture(icon)

-- Highlight texture (hover glow)
local highlight = minimapButton:CreateTexture(nil, "HIGHLIGHT")
highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
highlight:SetAllPoints()
minimapButton:SetHighlightTexture(highlight)

-- Pushed texture (click feedback)
local pushed = minimapButton:CreateTexture(nil, "BACKGROUND")
pushed:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
pushed:SetAllPoints()
minimapButton:SetPushedTexture(pushed)

-- Border overlay (the circular frame border around minimap buttons)
local border = minimapButton:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetSize(56, 56)
border:SetPoint("CENTER", minimapButton, "CENTER", 0, 0)

-- Position the button on the minimap edge
local function UpdateButtonPosition(angle)
    local radius = 80 -- distance from minimap center
    local x, y = AngleToPosition(angle, radius)
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- Save and load angle
local function GetAngle()
    MyAddonDB = MyAddonDB or {}
    return MyAddonDB.minimapAngle or DEFAULT_ANGLE
end

local function SaveAngle(angle)
    MyAddonDB = MyAddonDB or {}
    MyAddonDB.minimapAngle = angle
end

-- Dragging logic
local isDragging = false

minimapButton:RegisterForDrag("LeftButton")

minimapButton:SetScript("OnDragStart", function(self)
    isDragging = true
    self:SetScript("OnUpdate", function()
        local mx, my = Minimap:GetCenter()
        local cx, cy = GetCursorPosition()
        local scale  = UIParent:GetEffectiveScale()
        cx, cy = cx / scale, cy / scale

        local angle = math.deg(math.atan2(cy - my, cx - mx))
        SaveAngle(angle)
        UpdateButtonPosition(angle)
    end)
end)

minimapButton:SetScript("OnDragStop", function(self)
    isDragging = false
    self:SetScript("OnUpdate", nil)
end)

-- Click handlers
minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

minimapButton:SetScript("OnClick", function(self, button)
    if isDragging then return end

    if button == "LeftButton" then
        -- TODO: toggle your main frame here
        print("MyAddon: left clicked!")

    elseif button == "RightButton" then
        -- TODO: show a menu, or toggle something else
        print("MyAddon: right clicked!")
    end
end)

-- Tooltip
minimapButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("MyAddon")
    GameTooltip:AddLine("|cffadadadadLeft-click|r to toggle", 1, 1, 1)
    GameTooltip:AddLine("|cffadadadadDrag|r to move", 1, 1, 1)
    GameTooltip:Show()
end)

minimapButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Initialize on load
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, addonName)
    if addonName ~= "MyAddon" then return end -- replace with your addon name
    UpdateButtonPosition(GetAngle())
end)