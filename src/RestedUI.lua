-- RestedUI.lua
Rested_options.showNumBars = 6
Rested.displayList = {}
Rested.charList = {}
Rested.reportReverseSort = {} -- ["reportName"] = nil|true (for reverse)
-- Rested.displayList = { { displayValue (% of 100), "display text" }, {value, 'text'}, ... }

--  UI Handling code
---------------------------------
function Rested.UISetShowNumBars()
	local frameWidth, frameHeight = RestedUIFrame:GetSize()
	--print( "Resize: "..frameWidth..", "..frameHeight )
	Rested_options.showNumBars = math.floor( ( ( frameHeight - 53 ) / 12 ) + 0.5 )  -- 53 is a 'constant'
	return Rested_options.showNumBars
end
function Rested.UIBuildBars()
	if( not Rested.bars ) then
		Rested.bars = {}
	end
	if not Rested_options.showNumBars then
		Rested.UISetShowNumBars()
	end
	local count = #Rested.bars
	if ( Rested_options.showNumBars > count ) then
		for idx = count+1, Rested_options.showNumBars do
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
	elseif ( Rested_options.showNumBars < count ) then
		for idx = Rested_options.showNumBars+1, count do
			Rested.bars[idx].bar:SetValue(0)
			Rested.bars[idx].text:SetText("")
			Rested.bars[idx].bar:Hide()
		end
	end
end
Rested.InitCallback( Rested.UIBuildBars )

function Rested.UIOnDragStart()
	if not Rested_options.UIIsLocked then
		RestedUIFrame:StartMoving()
	end
end
function Rested.UIOnDragStop()
	RestedUIFrame:StopMovingOrSizing()
end
function Rested.UIResize( start )
	if start and not Rested_options.UIIsLocked then
		RestedUIFrame:StartSizing( "BOTTOM", true )  -- always start from mouse = true
		Rested.isSizing = true
	else
		Rested.isSizing = nil
		RestedUIFrame:StopMovingOrSizing()
		--local frameWidth, frameHeight = RestedUIFrame:GetSize()
		--print(frameWidth..", "..frameHeight )
		--Rested_options.showNumBars = math.floor( ( ( frameHeight - 53 ) / 12 ) + 0.5 )  -- 53 is a 'constant'
		local barCountSize = Rested_options.showNumBars * 12
		RestedUIFrame:SetHeight( barCountSize + 53 )
		RestedScrollFrame:SetHeight( barCountSize + 10 )
		RestedScrollFrame_VSlider:SetHeight( barCountSize + 10 )
		Rested.UIBuildBars()
		--Rested.UIResetFrame()
	end
end
function Rested.UIResetFrame()
	for i = 1, Rested_options.showNumBars do
		Rested.bars[i].bar:SetValue(0)
		Rested.bars[i].text:SetText("")
		Rested.bars[i].bar:Hide()
	end
end
function Rested.UIUpdateFrame()
	if( RestedUIFrame:IsVisible() and Rested.reportFunction ) then  -- a non-set reportFunction will break this.
		if not Rested_options.showNumBars then
			Rested_options.showNumBars = Rested.UISetShowNumBars()
		end
		count = Rested.ForAllChars( Rested.reportFunction, ( Rested.reportName == "Ignored" ) )
		RestedUIFrame_TitleText:SetText( "Rested - "..Rested.reportName.." - "..count )
		RestedScrollFrame_VSlider:SetMinMaxValues( 0, max( 0, count-Rested_options.showNumBars ) )
		if count > 0 then
			if Rested.reportReverseSort[Rested.reportName] then
				table.sort( Rested.charList, function( a, b ) return a[1] < b[1] end )  -- sort in ascending order
			else
				table.sort( Rested.charList, function( a, b ) return a[1] > b[1] end )  -- sort in descending order
			end
			offset = math.floor( RestedScrollFrame_VSlider:GetValue() )
			for i = 1, Rested_options.showNumBars do
				idx = i + offset
				if idx <= count then
					Rested.bars[i].bar:SetValue( max( 0, Rested.charList[idx][1] ) ) -- sorted on value
					Rested.bars[i].text:SetText( Rested.charList[idx][2] )
					Rested.bars[i].bar:Show()
				else
					Rested.bars[i].bar:Hide()
				end
			end
		elseif( Rested.bars and count == 0 ) then
			for i = 1, Rested_options.showNumBars do
				Rested.bars[i].bar:Hide()
			end
		end
	end
end
function Rested.UIMouseWheel( delta )
	RestedScrollFrame_VSlider:SetValue(
		RestedScrollFrame_VSlider:GetValue() - delta
	)
end
function Rested.UIOnUpdate( arg1 )
	if Rested.isSizing then
		Rested.UISetShowNumBars()
		local barCountSize = Rested_options.showNumBars * 12
		RestedScrollFrame:SetHeight( barCountSize + 10 )
		RestedScrollFrame_VSlider:SetHeight( barCountSize + 10 )
		Rested.UIBuildBars()
		Rested.UIlastUpdate = 0
	end
	-- only gets called when the report frame is shown
	if( Rested.UIlastUpdate == nil ) or ( Rested.UIlastUpdate <= time() ) then
		Rested.UIlastUpdate = time() + 1 -- only update once a second
		Rested.UIUpdateFrame()
	end
	if( Rested.autoCloseAfter and Rested.autoCloseAfter <= time() ) then
		RestedUIFrame:Hide()
		Rested.autoCloseAfter = nil
	end
end

function Rested.UIShowReport( reportFunction )
	-- use reportFunction to drive the report
	-- print( "Rested.UIShowReport( "..Rested.reportName..")" )
	Rested.reportFunction = reportFunction
	RestedUIFrame:Show()
	Rested.UIResetFrame()

	Rested.UIUpdateFrame()
	UIDropDownMenu_SetText( RestedUIFrame.DropDownMenu, Rested.reportName )
	Rested.autoCloseAfter = nil
end

function Rested.ResetUIPosition()
	RestedUIFrame:ClearAllPoints()
	RestedUIFrame:SetPoint("LEFT", "$parent", "LEFT")
	Rested_options.showNumBars = 6
	RestedUIFrame:SetHeight( 125 )
	Rested.UIResize()
end
Rested.commandList["uireset"] = { ["help"] = {"","Reset the location of the UI frame"}, ["func"] = Rested.ResetUIPosition }

-- DropDown code
function Rested.UIDropDownOnClick( self, cmd )
	--print( "Rested.UIDropDownOnClick( "..cmd.." )" )
	Rested.commandList[cmd].func()
end
function Rested.UIDropDownInitialize( self, level, menuList )
	-- This is called when the drop down is initialized, when it needs to build the choice box
	-- level and menuList are ignored here
	-- based on Rested.dropDownMenuTable["Full"] = "full"
	-- the Key is what to show, the value is what rested command to call
	-- using Rested.commandList["full"] = {["func"] = function() end }
	--local info = UIDropDownMenu_CreateInfo()
	local sortedKeys, i = {}, 1
	for text, _ in pairs( Rested.dropDownMenuTable ) do
		sortedKeys[i] = text
		i = i + 1
	end
	table.sort( sortedKeys, function( a, b ) return string.lower(a) < string.lower(b) end )
	for _, text in ipairs( sortedKeys ) do
		cmd = Rested.dropDownMenuTable[text]
		info = UIDropDownMenu_CreateInfo()
		info.text = text
		info.notCheckable = true
		info.arg1 = cmd
		info.func = Rested.UIDropDownOnClick

		UIDropDownMenu_AddButton( info, level )
	end
end
function Rested.UIDropDownOnLoad( self )
	UIDropDownMenu_Initialize( RestedUIFrame.DropDownMenu, Rested.UIDropDownInitialize ) -- displayMode, level, menuList
	UIDropDownMenu_JustifyText( RestedUIFrame.DropDownMenu, "LEFT" )
end

-- Filter Code
function Rested.updateFilter()
	if RestedEditBox:GetNumLetters() then
		Rested.filter = string.upper(RestedEditBox:GetText())
		Rested.UIUpdateFrame()
	else
		Rested.filter = nil
	end
end

-- Report Suport
--------------------------------------
