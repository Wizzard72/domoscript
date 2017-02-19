--[[      Put a device off when it doesn't use energy

/home/domoticz/domoticz/scripts/lua/script_device_0watt_device_v1.0.lua

-- Autors  ----------------------------------------------------------------
V1.0 - Wizzard72


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

-- Default Variables      ------------------------------------------------
local sDEBUG = 0             -- 0 , 1 for domoticz log
local time = os.date("*t")
local CurrentTime = os.time()
-- Variables to customize ------------------------------------------------
local sScriptName = "0WATT"
local s0wattTotal = uservariables["RAIN"]
local sMinutes = 115

-- Below , edit at your own risk ------------------------------------------
package.path = package.path .. ";/home/mydomo/domoticz/scripts/lua/modules.lua"
mymodule = require "mymodule"
commandArray = {}


if  ((time.min % 5)==0)  then 
	sRain = IsItGonnaRain(sMinutes)
	DEBUG(sScriptName,'Regen verwacht: ' .. sRain .. ' binnen ' .. sMinutes .. ' minuten.',sDEBUG)
	if (sRain == 0) then
		DEBUG(sScriptName,"It's not gonna rain in the next " .. sMinutes .. " minutes.",sDEBUG) 
	elseif (sRain > 0 and sRain <= 0.3) then
		NOTIFY(1,"It rains almost",sDEBUG)
	elseif (sRain > 0.3 and sRain <= 1) then
		NOTIFY(1,"It rains below average",sDEBUG)
	elseif (sRain > 1 and sRain <= 3) then
		NOTIFY(1,"It rains on average.",sDEBUG)
	elseif (sRain > 3 and sRain <= 10) then
		NOTIFY(1,"It rains above average",sDEBUG)
	elseif (sRain > 10 and sRain <= 30) then
		NOTIFY(1,"It rains heavily",sDEBUG)
	end
end
return commandArray
