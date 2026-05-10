-- RestedGarrisonShipments.lua

function Rested.Shipments_CRAFTER_CLOSED()
	-- this IS the prune function.
	if Rested.me.garrisonShipments then
		local buildingCount = 0
		for buildingName, si in pairs( Rested.me.garrisonShipments ) do
			buildingCount = buildingCount + 1
			-- print(buildingName, #Rested.me.garrisonShipments[buildingName].shipments, buildingCount)
			if #Rested.me.garrisonShipments[buildingName].shipments == 0 then
				Rested.me.garrisonShipments[buildingName] = nil
				buildingCount = buildingCount - 1
			end
		end
		if buildingCount == 0 then
			Rested.me.garrisonShipments = nil
		end
	end
end
function Rested.Shipments_CRAFTER_INFO( ... )
	local _, queuedShipments, maxShipments, ownedShipments, plotID = ...
	local z, buildingName = C_Garrison.GetOwnedBuildingInfoAbbrev(plotID)
	Rested.buildingName = buildingName
	local numPending = C_Garrison.GetNumPendingShipments()
	local name, texture, quality, itemID, followerID, duration = C_Garrison.GetShipmentItemInfo();

	-- print("SHIPMENT_CRAFTER_INFO", ...)
	-- print(z, buildingName, ownedShipments, "/", queuedShipments, numPending)
	-- durration = 14400

	Rested.me.garrisonShipments = Rested.me.garrisonShipments or {}
	Rested.me.garrisonShipments[buildingName] = Rested.me.garrisonShipments[buildingName] or {}
	Rested.me.garrisonShipments[buildingName].sampleTS = time()
	if numPending then
		Rested.me.garrisonShipments[buildingName].shipments = {}
		for i = 1, numPending do
			local t = {C_Garrison.GetPendingShipmentInfo(i)}
			Rested.me.garrisonShipments[buildingName].shipments[i] = t[7]
			Rested.me.garrisonShipments[buildingName].duration = duration
		end
	end
--[[
local function GetCurrentMapPosition()
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then return end

    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    if not pos then return end

    local mapInfo = C_Map.GetMapInfo(mapID)
    return {
        mapID   = mapID,
        mapName = mapInfo and mapInfo.name or "Unknown",
        x       = math.floor(pos.x * 10000) / 100,  -- 0-100 range
        y       = math.floor(pos.y * 10000) / 100,
    }
end

local function MapCoordsToYards(mapID, x, y)
    local width, height = C_Map.GetMapWorldSize(mapID)
    if not width or not height then return end
    return x * width, y * height
end

-- Distance between two map coord pairs on the same map
local function DistanceYards(mapID, x1, y1, x2, y2)
    local ax, ay = MapCoordsToYards(mapID, x1, y1)
    local bx, by = MapCoordsToYards(mapID, x2, y2)
    return math.sqrt((bx - ax)^2 + (by - ay)^2)
end
]]

end
Rested.WORK_ORDER_OBJECTS = {
	[235885] = "Herb Garden",
	[235886] = "Lunarfall Excavation",  -- Alliance Mine
	[236650] = "Scribe's Quarters",
	[237666] = "Tailoring Emporium",
	[239238] = "Herb Garden",
	[239237] = "Frostwall Mines", -- Horde Mine
}
function Rested.Shipments_LOOT_READY()
	for i = 1, GetNumLootItems() do
		local guid, quantity = GetLootSourceInfo(i)
		local type, _, _, _, _, id = strsplit("-", guid)
		local buildingName = Rested.WORK_ORDER_OBJECTS[tonumber(id)]

		-- if not buildingName then
			-- print("Looting from GUID:", guid, buildingName, quantity)
		-- end
		if buildingName then
			-- print("Trim down", buildingName, Rested.me.garrisonShipments[buildingName])
			if Rested.me.garrisonShipments and Rested.me.garrisonShipments[buildingName] then
				-- print("Have Table, will trim.", #Rested.me.garrisonShipments[buildingName].shipments)
				for i = #Rested.me.garrisonShipments[buildingName].shipments, 1, -1 do
					-- print(i, Rested.me.garrisonShipments[buildingName].shipments[i],
							-- Rested.me.garrisonShipments[buildingName].sampleTS + Rested.me.garrisonShipments[buildingName].shipments[i], "<?", time() )
					if Rested.me.garrisonShipments[buildingName].sampleTS + Rested.me.garrisonShipments[buildingName].shipments[i] < time() then
						table.remove(Rested.me.garrisonShipments[buildingName].shipments, i)
						-- print("Removing", i)
					end
				end
			end
		end
    end
    Rested.Shipments_CRAFTER_CLOSED()
end

Rested.EventCallback("SHIPMENT_CRAFTER_CLOSED", Rested.Shipments_CRAFTER_CLOSED)
Rested.EventCallback("SHIPMENT_CRAFTER_INFO", Rested.Shipments_CRAFTER_INFO)
Rested.EventCallback("LOOT_READY", Rested.Shipments_LOOT_READY)

Rested.dropDownMenuTable["Garrison Work Orders"] = "gwo"
Rested.commandList["gwo"] = { ["help"] = {"","Show garrison work order report."}, ["func"] = function()
		Rested.reportName="Garrison Work Orders"
		Rested.UIShowReport( Rested.GShipmentReport )
	end
}

function Rested.GShipmentReport( realm, name, charStruct )
	if( charStruct.garrisonShipments ) then
		local rn = Rested.FormatName( realm, name )
		local count = 0
		for buildingName, si in Rested.SortedPairs( charStruct.garrisonShipments ) do
			local firstComplete = 0
			local working = 0

			for i, duration in ipairs(charStruct.garrisonShipments[buildingName].shipments or {}) do
				if si.sampleTS + duration > time() then
					working = working + 1
					if firstComplete == 0 then
						firstComplete = si.sampleTS + duration
						-- print(i, SecondsToTime(firstComplete - time()), firstComplete - 14400, (time()-(firstComplete-14400))/14400 )
					end
				end
			end
			local queued = #charStruct.garrisonShipments[buildingName].shipments
			local complete = queued - working
			table.insert( Rested.charList,
				{ ((time() - (firstComplete - 14400)) / 14400) * 150,
					string.format("%s%02i%s/%02i %s :: %s : %s",
							complete > 0 and COLOR_GREEN or "",
							complete,
							complete > 0 and COLOR_END or "",
							queued,
							SecondsToTime(firstComplete - time()),
							buildingName,
							rn)
				}
			)
			count = count + 1
		end
		return count
	end
end
