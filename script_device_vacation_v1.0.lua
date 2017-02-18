    --[[      Start the vacation lights
	
    /home/domoticz/domoticz/scripts/lua/script_device_vacation_v1.0.lua
	
    -- Autors  ----------------------------------------------------------------
    V1.0 - Paul Slats
	
	
    -- Uservariables --------------------------------------------------------
		uvVacationDebug            = String = True / False
		uvVacationControlled       = String = Contains the uvVacationLight[number] seperated ","
		uvVacationLight[number]    = String = Type,Devicename,OnTime,OffTime,DimLevel
		uvVacationDevice           = String = Name of the virtual switch
		uvVacationRunning          = String = False / True
		
	-- Switches --------------------------------------------------------
		Security panel          = Security panel
		Create virtual switch and put name in variable uvVacationDevice
		
	-- Examples ----------------------------------------------------------

		
    ]]--
 
    -- Default Variables      ------------------------------------------------
	local sDEBUG = 0             -- 0 , 1 for domoticz log
	local time = os.date("*t")
	local CurrentTime = os.time()
	-- Variables to customize ------------------------------------------------
	local sScriptName = "VACATION"
	local sVacationDevice = uservariables["uvVacationDevice"]
	local sVacationLightTotal = uservariables["uvVacationLightTotal"]
	local sVacationRunning = uservariables["uvVacationRunning"]

	-- Below , edit at your own risk ------------------------------------------
	package.path = package.path .. ";/home/mydomo/domoticz/scripts/lua/modules.lua"
	mymodule = require "mymodule"
	commandArray = {}

	for deviceName,deviceValue in pairs(otherdevices) do
		DEBUG(sScriptName,"Vacation script is running...",sDEBUG)
		if (deviceName == sVacationDevice and deviceValue == "On" and globalvariables['Security'] == "Armed Away") then
			for sVacCount = 1, sVacationLightTotal, 1 do
				sVacationRecord = uservariables["uvVacationLight" .. sVacCount]	
				sVacationRecord = split(sVacationRecord, ",")
				sVacationType = sVacationRecord[1]
				sVacationDevice = sVacationRecord[2]
				sVacationStartTime = sVacationRecord[3]
				sVacationEndTime = sVacationRecord[4]
				sVacationDimLevel = sVacationRecord[5]

				if (sVacationStartTime == "sunset") then
					sWeekdayOnTime = (timeofday['SunsetInMinutes']) / 60
					sHour = string.sub(sWeekdayOnTime,1,string.find(sWeekdayOnTime,".",1,true)-1)
					sMinute = (sWeekdayOnTime - sHour) * 60
					sWakeOnTime = DisableTime("False",sHour,sMinute)
				else
					sHour = string.sub(sVacationStartTime,1,string.find(sVacationStartTime,":",1,true)-1)
					sMinute = string.sub(sVacationStartTime,string.find(sVacationStartTime,":",1,true)+1)
					sWakeOnTime = DisableTime("False",sHour,sMinute)
				end
				DEBUG(sScriptName,"The time to turn on the lights is " .. sHour .. ":" .. sMinute,sDEBUG)		

				sHour = string.sub(sVacationEndTime,1,string.find(sVacationEndTime,":",1,true)-1)
				sMinute = string.sub(sVacationEndTime,string.find(sVacationEndTime,":",1,true)+1)
				sWakeOffTime = DisableTime("False",sHour,sMinute)
				DEBUG(sScriptName,"The time to turn off the lights is " .. sHour .. ":" .. sMinute,sDEBUG)

				if (otherdevices[sVacationDevice] == "Off") then
					DEBUG(sScriptName,sVacationDevice .. " is Off",sDEBUG)
					if (CurrentTime >= sWakeOnTime and CurrentTime < sWakeOffTime) then
						DEBUG(sScriptName,"The light " .. sVacationDevice .. " is Off, lets turn it on...",sDEBUG)
						DeviceOnOffDim(sVacationDevice,sVacationDimLevel)
						VarMOD("uvVacationRunning","True",0)
						--commandArray[sVacationLight[2]] = 'Set Level ' .. sVacationLight[5]
						--commandArray ['Variable:uvVacationRunning']= "True"
					else
						DEBUG(sScriptName,"Nothing to do...",sDEBUG)
					end
				end
			end
		elseif (otherdevices[sVacationDevice] == "Set Level" or otherdevices[sVacationDevice] == "On") then
			DEBUG(sScriptName,sVacationDevice .. " is On",sDEBUG)
			if (CurrentTime < sWakeOnTime or CurrentTime >= sWakeOffTime) then
				DEBUG(sScriptName"The light " .. sVacationDevice .. " is On, lets turn it off...",sDEBUG)
				DeviceOnOffDim(sVacationDevice,0)
				VarMOD("uvVacationRunning","False",0)
				--commandArray[sVacationLight[2]] = 'Off'
				--commandArray ['Variable:uvVacationRunning']= "False"
			else
				DEBUG(sScriptName,"Nothing to do...",sDEBUG)
			end
		elseif (deviceName == sVacationDevice and deviceValue == "Off") then
			sVacationRunning = uservariables["uvVacationRunning"]
			if (sVacationRunning == "True") then
				VarMOD("uvVacationRunning","False",0)
				--commandArray ['Variable:uvVacationRunning']= "False"
				DEBUG(sScriptName,"The variable was still enabled, disabling now",sDEBUG)
			end
		end
		DEBUG(sScriptName,"Logging Script - VACATION - Ended",sDEBUG)
	end
	
	return commandArray
