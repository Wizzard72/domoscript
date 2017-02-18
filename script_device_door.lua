    --[[      Put the lights on when the door sensor is triggered
 
    /home/domoticz/domoticz/scripts/lua/script_device_door_sensor_v1.0.lua
	
    -- Autors  ----------------------------------------------------------------
    V1.0 - Paul Slats
	
	
    -- Uservariables ----------------------------------------------------------
		uvLivingDebug           = String = True / False
		vLivingRoomRunOnceADay  = Integer = 0 (Off) / 1 (On)
		
    ]]--
 
    -- Variables to customize ------------------------------------------------
	local sDEBUG = 0             -- 0 , 1 for domoticz log
	local time = os.date("*t")
	local CurrentTime = os.time()
	local sScriptName = "DOOR SENSOR"
	local sDoorDeviceTotal = uservariables["uvDoorDeviceTotal"]



    -- Below , edit at your own risk ------------------------------------------
	package.path = package.path .. ";/home/mydomo/domoticz/scripts/lua/modules.lua"
	mymodule = require "mymodule"
	commandArray = {}
	
	DEBUG(sScriptName,"Set lights on when door opens",sDEBUG)
	if (devicechanged ~= nil) then
	for deviceName,deviceValue in pairs(devicechanged) do
    	for InstanceTotal = 1, sDoorDeviceTotal, 1 do
			local sDoorSensorInstances = split(uservariables["uvDoorDeviceInstances" .. InstanceTotal], ",")
			local sInstanceNumber = sDoorSensorInstances[1]
			local sInstanceTotalDevices = sDoorSensorInstances[2]
			local sRecord = split(uservariables["uvDoorDevice" .. sInstanceNumber], ",")
			local sSensorDevice  = sRecord[1]
			sDimmerDevice = sRecord[2]
			sDimPercentage = tonumber(sRecord[3])
			sDimTime = tonumber(sRecord[4])

			if (deviceName == sSensorDevice and timeofday['Nighttime']) then
				DEBUG(sScriptName,deviceName .. " is open, let's activate the light (" .. sDimmerDevice .. ") at " .. sDimPercentage .. "%",sDEBUG)
				LightsOn(sDimmerDevice,sDimPercentage,sDimTime)
			else
				DEBUG(sScriptName,"Nothing to do",sDEBUG)
			end
		end
	end
	end
	DEBUG(sScriptName,"Logging Script - DEUR SENSOR - Ended",sDEBUG)
	return commandArray
