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
	local x, y = C_Map.GetPlayerMapPosition( C_Map.GetBestMapForUnit("player"), "player" ):GetXY();
	Rested.me.garrisonShipments[buildingName].x = x*100
	Rested.me.garrisonShipments[buildingName].y = y*100
end
function Rested.IsWithInDistance(x, y, d)
	if x and y then
		local cx, cy = C_Map.GetPlayerMapPosition( C_Map.GetBestMapForUnit("player"), "player" ):GetXY()
		cx = cx*100; cy = cy*100
		local distance = math.sqrt((cx-x)^2 + (cy-y)^2)
		print(string.format("%0.2f,%0.2f %0.2f,%0.2f Distance: %0.4f", cx,cy, x,y, distance))
		if distance <= d then
			return true
		end
	end
end
function Rested.Shipments_LOOT_READY()
	local mapID = C_Map.GetBestMapForUnit("player")
	if mapID == 582 or mapID == 590 then -- only if in the garrison map
		for buildingName, si in pairs(Rested.me.garrisonShipments or {}) do
			if Rested.IsWithInDistance(si.x, si.y, 5) then  -- distance of 1.5 might be good.
				print(buildingName)
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
		Rested.Shipments_CRAFTER_CLOSED()
	end
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
