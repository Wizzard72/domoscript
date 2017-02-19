--[[      Put a device off when it doesn't use energy

ScriptFileName = script_device_0watt_device_v1.0.lua
Type = Device
	
-- Autors  ----------------------------------------------------------------
V1.1 - Wizzard
	
-- Uservariables ----------------------------------------------------------
uv0wattTotal                   = Integer
uv0wattDeviceInstances<number> = String
uv0wattDevice<number>          = String
		
-- Examples ----------------------------------------------------------
uv0wattTotal            = 2
uv0wattDeviceInstances1 = 1,8
uv0wattDevice1          = Device,Power Meter Device,Standby Time,MaxWatt,Notify Yes/No,Watt1,Watt2,Watt3,Watt4,Watt5
uv0wattDeviceInstances2 = 2,6
uv0wattDevice2          = Device,Power Meter Device,Standby Time,MaxWatt,Notify Yes/No,Watt1,Watt2,Watt3

]]--
 
-- Variables to customize ------------------------------------------------
local sDEBUG = 0             -- 0 , 1 for domoticz log
local time = os.date("*t")
local CurrentTime = os.time()
local sScriptName = "0watt - device"
local s0wattTotal = uservariables["uv0wattTotal"]
local DomoticzPath = "/home/mydomo"
local ScriptPath = "/domoticz/scripts/lua"
local ModuleFileName = "/modules.lua"

-- Below , edit at your own risk ------------------------------------------
package.path = package.path .. ";" .. DomoticzPath .. ScriptPath .. ModuleFileName
mymodule = require "mymodule"
commandArray = {}
if (devicechanged ~= nil) then
	for InstanceTotal = 1, s0wattTotal, 1 do
		s0wattInstances = split(uservariables["uv0wattDeviceInstances" .. InstanceTotal], ",")
		local sInstanceNumber       = s0wattInstances[1]
		local sInstanceTotalDevices = s0wattInstances[2]
		sRecord = split(uservariables["uv0wattDevice" .. sInstanceNumber], ",")
		s0wattDevice  = sRecord[1]
		s0wattDeviceWatt = sRecord[2]
		s0WattDeviceLua = sRecord[3]
		s0WattDeviceLua = otherdevices_idx['Wasmachine (lua)']
		sStandbyTime = tonumber(sRecord[4])
		s0wattMaxWatt = tonumber(sRecord[5])
		s0wattNofity = sRecord[6]
		for deviceName,deviceValue in pairs(devicechanged) do
			if (deviceName == s0wattDevice) then
				if (deviceValue == "On") then
					DEBUG(sScriptName,"The switch " .. deviceName .. " is activated.",sDEBUG)
					if (string.lower(s0wattNofity) == "yes") then
						NOTIFY(0,deviceName .. " activated#I let you know when device " .. deviceName .. " is turned off",sDEBUG)
					end
				elseif (deviceValue == "Off") then
					DEBUG(sScriptName,"The switch " .. deviceName .. " is turned off.",sDEBUG)
					if (string.lower(s0wattNofity) == "yes") then
						NOTIFY(0,deviceName .. " Ready#I'm informing you that the device " .. deviceName .. " is turned off.",sDEBUG)
					end
				end
			end
		end
	end
end
return commandArray
