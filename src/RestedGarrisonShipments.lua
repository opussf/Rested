-- RestedGarrisonShipments.lua

function Rested.Shipments_CRAFTER_CLOSED()
	print("SHIPMENT_CRAFTER_CLOSED", Rested.buildingName)
	if Rested.me.garrisonShipments then
		print(Rested.me.garrisonShipments[Rested.buildingName].queuedShipments)
	end
end
function Rested.Shipments_CRAFTER_INFO( ... )
	local _, queuedShipments, maxShipments, ownedShipments, plotID = ...
	local z, buildingName = C_Garrison.GetOwnedBuildingInfoAbbrev(plotID)
	Rested.buildingName = buildingName
	local numPending = C_Garrison.GetNumPendingShipments()
	local name, texture, quality, itemID, followerID, duration = C_Garrison.GetShipmentItemInfo();

	-- local timeRemaining = (numPending and numPending > 0) and select(7, C_Garrison.GetPendingShipmentInfo(numPending)) or 0;

	-- local available = max(maxShipments - numPending - ownedShipments, 0);  -- open slots (not what I want)


	-- print("SHIPMENT_CRAFTER_INFO", ...)
	-- print(z, buildingName, ownedShipments, "/", queuedShipments, numPending, duration, timeRemaining )
	-- durration = 14400

	Rested.me.garrisonShipments = Rested.me.garrisonShipments or {}
	Rested.me.garrisonShipments[buildingName] = Rested.me.garrisonShipments[buildingName] or {}
	Rested.me.garrisonShipments[buildingName].sampleTS = time()
	Rested.me.garrisonShipments[buildingName].shipments = {}
	if numPending then
		for i = 1, numPending do
			local t = {C_Garrison.GetPendingShipmentInfo(i)}
			Rested.me.garrisonShipments[buildingName].shipments[i] = t[7]
			Rested.me.garrisonShipments[buildingName].duration = duration
		end
	end
	-- Rested.me.garrisonShipments[buildingName].queuedShipments = queuedShipments
	-- Rested.me.garrisonShipments[buildingName].singleTime = duration
	-- Rested.me.garrisonShipments[buildingName].timeComplete = time()+timeRemaining
end

Rested.EventCallback("SHIPMENT_CRAFTER_CLOSED", Rested.Shipments_CRAFTER_CLOSED )
Rested.EventCallback("SHIPMENT_CRAFTER_INFO", Rested.Shipments_CRAFTER_INFO )

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
					string.format("%02i/%02i %s :: %s : %s",
							complete,
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
