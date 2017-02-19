--[[      Set the WakeUpLight

ScriptFileName = script_time_wakeuplight_v1.0.lua
Type = Time
	
-- Autors  ----------------------------------------------------------------
V1.0 - Wizzard72

	
-- Uservariables --------------------------------------------------------
-- Switches --------------------------------------------------------
ComingHome              = On/Off switch (Disable alarm when phone is near the house)
NotHome                 = On/Off switch (Enable alarm when phone is not near the house)
Security panel          = Security panel

-- Examples ----------------------------------------------------------

		
]]--
 
-- Variables to customize ------------------------------------------------
local sDEBUG = 0             -- 0 , 1 for domoticz log
local time = os.date("*t")
local CurrentTime = os.time()
local sScriptName = "TEST"
local sDay = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
local Current_week = os.date("%V")
Local sWakeUpSwitch = otherdevices["Wake Up Light"]

-- Variables to customize ------------------------------------------------
sWakeUpLightTotal = uservariables["uvWakeUpLightTotal"]
sVacationDevice = uservariables["uvVacationDevice"]

-- Below , edit at your own risk -----------------------------------------
package.path = package.path .. ";/home/mydomo/domoticz/scripts/lua/modules.lua"
mymodule = require "mymodule"
commandArray = {}

if (sWakeUpSwitch == "On") then
	if (otherdevices[sVacationDevice] ~= "On") then
		DEBUG(sScriptName,"Current time (" .. CurrentTime .. ")",sDEBUG)
		for sWakeUpLightCount = 1, sWakeUpLightTotal, 1 do
			sWakeUpLightInstance = split(uservariables["uvWakeUpLightInstance" .. sWakeUpLightCount], ",")
			sInstanceNumber = sWakeUpLightInstance[1]
			sInstanceTotalDevices = sWakeUpLightInstance[2]
			sRecord = split(uservariables["uvWakeUpLight" .. sWakeUpLightCount], ",")
			sWakeUpLightSunday = sRecord[1]
			sWakeUpLightMonday  = sRecord[2]
			sWakeUpLightTuesday = sRecord[3]
			sWakeUpLightWednesday = sRecord[4]
			sWakeUpLightThursday = sRecord[5]
			sWakeUpLightFriday = sRecord[6]
			sWakeUpLightSaturday = sRecord[7]
			sWakeUpLightWeek = string.lower(sRecord[8])
			sWakeUpLightStart = sRecord[9]
			sWakeUpLightEnd = sRecord[10]
			sWakeUpLightStartHour = tonumber(string.sub(sWakeUpLightStart,1,string.find(sWakeUpLightStart,":",1,true)-1))
			sWakeUpLightStartMinute = tonumber(string.sub(sWakeUpLightStart,string.find(sWakeUpLightStart,":",1,true)+1))
			sWakeUpLightEndHour = tonumber(string.sub(sWakeUpLightEnd,1,string.find(sWakeUpLightEnd,":",1,true)-1))
			sWakeUpLightEndMinute = tonumber(string.sub(sWakeUpLightEnd,string.find(sWakeUpLightEnd,":",1,true)+1))
			sWakeUpLightStart = os.time{year=os.date("%Y"), month=os.date("%m"), day=os.date("%d"), hour=sWakeUpLightStartHour, min=sWakeUpLightStartMinute, sec=00}
			sWakeUpLightEnd = os.time{year=os.date("%Y"), month=os.date("%m"), day=os.date("%d"), hour=sWakeUpLightEndHour, min=sWakeUpLightEndMinute, sec=00}
			if (Current_week % 2 == 0) then
				DEBUG(sScriptName,"Current_week = " .. Current_week .. " (EVEN WEEK)",sDEBUG)
				sWakeUpLightCurrentWeek = "even"
			else
				DEBUG(sScriptName,"Current_week = " .. Current_week .. " (UNEVEN WEEK)",sDEBUG)
				sWakeUpLightCurrentWeek = "uneven"
			end
			sWeekday = tonumber(os.date("%w")) + 1
			if (sWakeUpLightWeek == sWakeUpLightCurrentWeek) then
				for i, v in ipairs(sDay) do
					if (tonumber(sRecord[i]) == sWeekday) then
						DEBUG(sScriptName,"Start time of the wake up light (" .. uservariables["uvWakeUpLightInstance" .. sWakeUpLightCount] .. ") is "  .. sWakeUpLightStart,sDEBUG)
						DEBUG(sScriptName,"Start time of the wake up light (" .. uservariables["uvWakeUpLightInstance" .. sWakeUpLightCount] .. ") is "  .. sWakeUpLightEnd,sDEBUG)
						if (CurrentTime >= sWakeUpLightStart and CurrentTime <= sWakeUpLightEnd + 65) then
							for LightCount = 11, sInstanceTotalDevices, 1 do 
								sCurrentDimLevel = tonumber(otherdevices_svalues[sRecord[LightCount]])
								sDimStep = 100 / ((sWakeUpLightEnd - sWakeUpLightStart) / 60)
								DEBUG(sScriptName,"The Current Dim Level of device " .. otherdevices[sRecord[LightCount]] .. " is " .. sCurrentDimLevel .. "%",sDEBUG)
								DEBUG(sScriptName,"The Current Dim Level will be increased by " .. sDimStep .. "%",sDEBUG)
								if (otherdevices[sRecord[LightCount]] == "Off") then
									sDimLevel = sDimStep
								elseif (tonumber(sCurrentDimLevel) + sDimStep <= 100) then
									sDimLevel = sCurrentDimLevel + sDimStep
								elseif (tonumber(sCurrentDimLevel) + sDimStep > 100) then
									sDimLevel = "Off"
								end
								DeviceOnOffDim(sRecord[LightCount], sDimLevel)
							end
						end
					end
				end
			else
				DEBUG(sScriptName,"Not the right week (Even/Uneven)",sDEBUG)
			end
		end
	end
else
	DEBUG(sScriptName,"The Wake Up Light switch if Off",sDEBUG) 
end
return commandArray
