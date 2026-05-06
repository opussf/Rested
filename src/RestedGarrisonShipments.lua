-- RestedGarrisonShipments.lua



-- Rested.EventCallback("SHIPMENT_CRAFTER_OPENED")
Rested.EventCallback("SHIPMENT_CRAFTER_CLOSED")
Rested.EventCallback("SHIPMENT_CRAFTER_INFO")
-- Rested.EventCallback("SHIPMENT_CRAFTER_REAGENT_UPDATE")
-- Rested.EventCallback("SHIPMENT_UPDATE")


function Rested.SHIPMENT_CRAFTER_OPENED( ... )
	print("SHIPMENT_CRAFTER_OPENED", ...)
end
function Rested.SHIPMENT_CRAFTER_CLOSED()
	print("SHIPMENT_CRAFTER_CLOSED", Rested.buildingName)
	if Rested.me.garrisonShipments then
		print(Rested.me.garrisonShipments[Rested.buildingName].queuedShipments)
	end
end
function Rested.SHIPMENT_CRAFTER_INFO( ... )
	local _, queuedShipments, maxShipments, ownedShipments, plotID = ...
	local z, buildingName = C_Garrison.GetOwnedBuildingInfoAbbrev(plotID)
	Rested.buildingName = buildingName
	local numPending = C_Garrison.GetNumPendingShipments()
	local name, texture, quality, itemID, followerID, duration = C_Garrison.GetShipmentItemInfo();



	local timeRemaining = numPending > 0 and select(7, C_Garrison.GetPendingShipmentInfo(numPending)) or 0;

	-- local available = max(maxShipments - numPending - ownedShipments, 0);  -- open slots (not what I want)


	print("SHIPMENT_CRAFTER_INFO", ...)
	print(z, buildingName, ownedShipments, "/", queuedShipments, numPending, duration, timeRemaining )
	-- durration = 14400

	Rested.me.garrisonShipments = Rested.me.garrisonShipments or {}
	Rested.me.garrisonShipments[buildingName] = Rested.me.garrisonShipments[buildingName] or {}
	Rested.me.garrisonShipments[buildingName].sampleTS = time()
	Rested.me.garrisonShipments[buildingName].queuedShipments = queuedShipments
	Rested.me.garrisonShipments[buildingName].singleTime = duration
	Rested.me.garrisonShipments[buildingName].timeComplete = time()+timeRemaining
end
function Rested.SHIPMENT_CRAFTER_REAGENT_UPDATE()
	print("SHIPMENT_CRAFTER_REAGENT_UPDATE")
end
function Rested.SHIPMENT_UPDATE()
	print("SHIPMENT_UPDATE")
end


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
			table.insert( Rested.charList,
				{ tonumber(si.timeComplete/(si.queuedShipments*si.singleTime))*150,
					string.format("%i :: %s : %s %s",
						si.queuedShipments,
						rn,
						buildingName,
						SecondsToTime( si.timeComplete - time() ))
			})
			count = count + 1
		end
		return count
	end
end
