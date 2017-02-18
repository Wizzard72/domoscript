    --[[      Set the alarm
	
    /home/domoticz/domoticz/scripts/lua/script_device_alarm_v1.0.lua
	
    -- Autors  ----------------------------------------------------------------
    V1.0 - Paul Slats
	
	
    -- Uservariables --------------------------------------------------------
		uvAlarmWeekdayOnTime    = Integer = 0
		uvAlarmWeekdayOffTime   = Integer = 0
		
	-- Switches --------------------------------------------------------
		ComingHome              = On/Off switch (Disable alarm when phone is near the house)
		NotHome                 = On/Off switch (Enable alarm when phone is not near the house)
		Security panel          = Security panel
		
	-- Examples ----------------------------------------------------------

		
    ]]--
 
    -- Default Variables      ------------------------------------------------
	local sDEBUG = 0             -- 0 , 1 for domoticz log
	local time = os.date("*t")
	local CurrentTime = os.time()
	local sScriptName = "ALARM"
	-- Variables to customize ------------------------------------------------
	local sAlarmTriggeredValue = uservariables['uvAlarmTriggered']
	local sAlarmWeekdayOnTime = tonumber(uservariables["uvAlarmWeekdayOnTime"])
	local sAlarmWeekdayOffTime = tonumber(uservariables["uvAlarmWeekdayOffTime"])
	local sFamilySwitch = "Anybody Home"
	local sFamilySWType = "Geo,Tel"
	local sFamilySWCount = 2
	local sAlarmSuspendTime = 300
	local sAlarmDurationTime = uservariables["uvAlarmDurationTime"] * 60
	local sWaitTime = uservariables['uvAlarmWaitTime']
	local sNightOffLightTime = uservariables["uvNightOffLightTime"]
	local sVacationRunning = uservariables["uvVacationRunning"]
	local sKill = otherdevices['Huiskamer Lichten Uit Override']
	local sDimValue = 15
	sSecurityPanel = "SecPanel"
	sAlarmDevice = uservariables["uvAlarmDevice"]
	sVacationDevice = uservariables["uvVacationDevice"]
	sAlarmRunOnceADay = tonumber(uservariables["uvAlarmRunOnceADay"])
	local sDimmer = "Dimmer"
	sDimmerPerc = "98"


	-- Below , edit at your own risk ------------------------------------------
	package.path = package.path .. ";/home/mydomo/domoticz/scripts/lua/modules.lua"
	mymodule = require "mymodule"
	commandArray = {}


	for deviceName,deviceValue in pairs(devicechanged) do
		DEBUG(sScriptName," >==================================================================<",sDEBUG)
		DEBUG(sScriptName," >=== Find phones ",sDEBUG)
		-- If phone switch is turned on switch on sFamilySwitch
		sFamilySWTypen = split(sFamilySWType, ",")
		for sSWType = 1, sFamilySWCount, 1 do
			if (string.lower(deviceName:sub(1,3)) == string.lower(sFamilySWTypen[sSWType]) and deviceValue == "On") then
				DeviceOnOffDim(sFamilySwitch,"On")
				DEBUG(sScriptName," - >=== A Family member is home, the switch " .. sFamilySwitch .. " is enabled",sDEBUG)
			end
	    	end
	    	DEBUG(sScriptName," - >=== End of section",sDEBUG)
		-- If a family member comes home, disable the alarm
		DEBUG(sScriptName," - >==================================================================<",sDEBUG)
		DEBUG(sScriptName," - >=== Coming Home",sDEBUG)
		if (deviceName == sFamilySwitch and deviceValue == "Off") then
			if (CurrentTime >= sAlarmWeekdayOnTime and CurrentTime <= sAlarmWeekdayOffTime) then
				DEBUG(sScriptName,"- >=== Nobody is home. Set the alarm to 'Arm Away'",sDEBUG)
				SecurPanel("Arm Away")
			else
				DEBUG(sScriptName," - >=== Nobody is home. Set the alarm to 'Arm Away'",sDEBUG)
				SecurPanel("Arm Away")
			end
		elseif (deviceName == sFamilySwitch and deviceValue == "On") then	
			sChangeStatus = "False"
			sAlarmOffLastUpdate = otherdevices_lastupdate[deviceName]
			DEBUG(sScriptName,"- >=== Last time when the Home switch was triggered is " .. sAlarmOffLastUpdate,sDEBUG)

			local year = string.sub(sAlarmOffLastUpdate, 1, 4)
			local month = string.sub(sAlarmOffLastUpdate, 6, 7)
			local day = string.sub(sAlarmOffLastUpdate, 9, 10)
			local hour = string.sub(sAlarmOffLastUpdate, 12, 13)
			local minutes = string.sub(sAlarmOffLastUpdate, 15, 16)
			local seconds = string.sub(sAlarmOffLastUpdate, 18, 19)

			tAlarmOffLastUpdate = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
			DEBUG(sScriptName," - >=== UTC Time when the Home switch was triggered is " .. tAlarmOffLastUpdate,sDEBUG)
	
			difference = (os.difftime (CurrentTime, tAlarmOffLastUpdate))
			DEBUG(sScriptName," - >=== Time Difference is " ..difference .. " seconds",sDEBUG)
	
			if (difference <= sAlarmSuspendTime) then
				DEBUG(sScriptName," - >=== The occupant is coming home. alarm has to be disarmed for " ..  sAlarmSuspendTime .. " seconds.",sDEBUG)
				sChangeStatus = "True"
			end

			DEBUG(sScriptName,"- >=== sChangeStatus = " .. sChangeStatus,sDEBUG)	
			if (sChangeStatus == "False" and (CurrentTime >= sAlarmWeekdayOnTime or CurrentTime <= sAlarmWeekdayOffTime)) then
				DEBUG(sScriptName," - >===Nighttime: Set alarm to Armed Home",sDEBUG)
				SecurPanel("Arm Home")
			elseif (CurrentTime < sAlarmWeekdayOnTime) then
				DEBUG(sScriptName," - > ===Dayttime: Set alarm to disarmed",sDEBUG)
				SecurPanel("Disarm")
				VarMOD("uvAlarmTriggered","False",0)
			elseif (sChangeStatus == "True") then
				DEBUG(sScriptName," - >=== The occupant is coming home. alarm has to be disarmed",sDEBUG)
				SecurPanel("Disarm")
				VarMOD("uvAlarmTriggered","False",0)
			else
				DEBUG(sScriptName," - >=== Daytime, alarm is not set",sDEBUG)
			end
	    	end
	   	 DEBUG(sScriptName," - >=== End of section",sDEBUG)
		-- Signaling if Sensor or PIR is triggered while alarm is armed
		DEBUG(sScriptName," - >==================================================================<",sDEBUG)
		DEBUG(sScriptName," - >=== Alarm triggerd?",sDEBUG)
		if (globalvariables['Security'] == "Armed Away") then
		    if (string.lower(deviceName:sub(1,6)) == "sensor" or string.lower(deviceName:sub(1,3)) == "pir" or string.lower(deviceName:sub(1,6)) == "dimmer") then
			    DEBUG(sScriptName," - >=== The device " .. deviceName .. " is triggered (" .. deviceValue .. ")",sDEBUG)
				if (deviceValue == "Open" or deviceValue == "On") then
					print(sScriptName," - >=== Alarm Triggered by " .. deviceName .. " now!")
					if (sAlarmTriggeredValue == "False") then
						VarMOD("uvAlarmTriggered","True",0)
					end
				end
		    end
	    	end
	    	DEBUG(sScriptName," - >=== End of section",sDEBUG)
	end

	-- Turn off the sFamilySwitch when all phones are off
	DEBUG(sScriptName," - >==================================================================<",sDEBUG)
	DEBUG(sScriptName," - >=== Turn off " .. sFamilySwitch,sDEBUG)
	sFamilyCount = 0
	for deviceName,deviceValue in pairs(otherdevices) do
		-- Dim Dimmers to 99% when status is On
		if (string.lower(deviceName:sub(1,6)) == string.lower(sDimmer)) then
			if (deviceValue == "On") then
				DEBUG(sScriptName,"Device " .. deviceName .. " is dimmed to " .. sDimmerPerc .. "%",sDEBUG)
				DeviceOnOffDim(deviceName,sDimmerPerc)
			end
		end
		-- Enable the family switch
		sFamilySWTypen = split(sFamilySWType, ",")
		for sSWType = 1, sFamilySWCount, 1 do
			if (string.lower(deviceName:sub(1,3)) == string.lower(sFamilySWTypen[sSWType])) then
				if (deviceValue == "On") then
					sFamilyCount = 100
					DEBUG(sScriptName," - >=== deviceName = " .. deviceName .. " deviceValue = " .. deviceValue,sDEBUG)
				elseif (deviceValue == "Off") then
					sFamilyCount = sFamilyCount + 0
					DEBUG(sScriptName," - >=== deviceName = " .. deviceName .. " deviceValue = " .. deviceValue,sDEBUG)
				end
			end
		end
		DEBUG(sScriptName," - >=== End of section",sDEBUG)
		-- Disable Alarm if Domoticz fails and is rebooted
		DEBUG(sScriptName," - >==================================================================<",sDEBUG)
		DEBUG(sScriptName," - >=== Turn off alarm when domoticz crashed",sDEBUG)
		if (deviceName == sAlarmDevice and deviceValue == "All On") then
			if (timedifference(otherdevices_lastupdate[sAlarmDevice]) >= sAlarmDurationTime) then
				DeviceOnOffDim(sAlarmDevice,"All Off")
				VarMOD("uvAlarmTriggered","False",0)
				DEBUG(sScriptName," - >=== Disable alarm",sDEBUG)
			end
		end
        	DEBUG(sScriptName," - >=== End of section",sDEBUG)
        	-- Arm and deactive the alarm
        	DEBUG(sScriptName," - >==================================================================<",sDEBUG)
	    	DEBUG(sScriptName," - >=== Arm and deactive the alarm",sDEBUG)
		if (deviceName == sSecurityPanel and deviceValue == "Normal") then
			if (otherdevices[sFamilySwitch] == "On" and (CurrentTime < sAlarmWeekdayOnTime or CurrentTime > sAlarmWeekdayOffTime)) then
				DEBUG(sScriptName," - >=== Daytime: Set alarm to Disarmed",sDEBUG)
			    	--SecurPanel("Disarm")
			elseif (otherdevices[sFamilySwitch] == "On" and (CurrentTime >= sAlarmWeekdayOnTime or CurrentTime <= sAlarmWeekdayOffTime)) then
				DEBUG(sScriptName," - >=== Nighttime: Set alarm to Armed Home",sDEBUG)
			    	SecurPanel("Arm Home")
			end
        	elseif (deviceName == sSecurityPanel and deviceValue == "Arm Home") then
            		if (otherdevices[sFamilySwitch] == "On" and otherdevices['SecurityPanel Armed Home by script'] == "On" and (CurrentTime <= tonumber(sAlarmWeekdayOnTime) or CurrentTime >= tonumber(sAlarmWeekdayOffTime))) then
                		DEBUG(sScriptName," - >=== Deactivate the alarm",sDEBUG)
                		SecurPanel("Disarm")
            		elseif (otherdevices[sFamilySwitch] == "On" and otherdevices['SecurityPanel Armed Home by script'] == "Off" and (CurrentTime >= (tonumber(sAlarmWeekdayOffTime) - 180) and  CurrentTime >= (tonumber(sAlarmWeekdayOffTime) - 120))) then
                		DeviceOnOffDim("SecurityPanel Armed Home by script","On")
            		end
            		if (sKill == "Off" and sVacationRunning == "False") then
                		for deviceName2,deviceValue2 in pairs(otherdevices) do
	                		if (deviceValue2:sub(1,11) == "Set Level: ") then
                        			DEBUG(sScriptName," - >=== deviceName2 = " .. deviceName2 .. " and value = " .. deviceValue2 .. " number = " .. string.match(deviceValue2,"%d+"),sDEBUG)
                        			if (tonumber(string.match(deviceValue2,"%d+")) > sDimValue) then
                            				DEBUG(sScriptName," - >=== Dim the light " .. string.match(deviceValue2,"%d+") .. " to " .. sDimValue .. "%",sDEBUG)
				            		DeviceOnOffDim(deviceName2,sDimValue)
				        	end
				        	DEBUG(sScriptName,"timedifference(otherdevices_lastupdate[deviceName2]) = " .. timedifference(otherdevices_lastupdate[deviceName2]),sDEBUG)
                        			if (timedifference(otherdevices_lastupdate[deviceName2]) >= sNightOffLightTime) then
				            		DEBUG(sScriptName," - >=== Light " .. deviceName2 .. " is disabled after " .. sNightOffLightTime .. " seconds",sDEBUG)
				            		DeviceOnOffDim(deviceName2,0)
				        	else
					        	sTimeDiff = sNightOffLightTime - timedifference(otherdevices_lastupdate[deviceName2])
				            		DEBUG(sScriptName," - >=== Turn the light " .. deviceName2 .. " off after " .. sTimeDiff .. " seconds",sDEBUG)
				        	end
                    			end
                		end
            		end
	    	elseif (deviceName == sSecurityPanel and deviceValue == "Arm Away") then
	        	if (sKill == "Off" and sVacationRunning == "False") then
	            		DEBUG(sScriptName," - >=== Alarm is Armed Away",sDEBUG)
	            		for deviceName2,deviceValue2 in pairs(otherdevices) do
	                		if (deviceValue2:sub(1,11) == "Set Level: " or (deviceName2:sub(1,6) == "Dimmer" and deviceValue2 == "On")) then
	                    			if (deviceValue2 == "On") then
	                       				deviceValue2 = 100
	                    			end
                        			DEBUG(sScriptName," - >=== deviceValue2 = " .. deviceName2 .. " and value = " .. deviceValue2 .. " number = " .. string.match(deviceValue2,"%d+"),sDEBUG)
                        			if (tonumber(string.match(deviceValue2,"%d+")) > sDimValue) then
                            				DEBUG(sScriptName,"Dim the light " .. string.match(deviceValue2,"%d+") .. " to " .. sDimValue .. "%",sDEBUG)
					        	DeviceOnOffDim(deviceName2,sDimValue)
				        	end
				        	DEBUG(sScriptName,"timedifference(otherdevices_lastupdate[deviceName2]) = " .. timedifference(otherdevices_lastupdate[deviceName2]),sDEBUG)
                        			if (timedifference(otherdevices_lastupdate[deviceName2]) >= sNightOffLightTime) then
					        	DEBUG(sScriptName," - >=== Light " .. deviceName2 .. " is disabled after " .. sNightOffLightTime .. " seconds",sDEBUG)
					        	DeviceOnOffDim(deviceName2,0)
				        	else
				    	    		sTimeDiff = sNightOffLightTime - timedifference(otherdevices_lastupdate[deviceName2])
					        	DEBUG(sScriptName," - >=== Turn the light " .. deviceName2 .. " off after " .. sTimeDiff .. " seconds",sDEBUG)
				        	end
                    			end
                		end
            		end
		end
	end
    	DEBUG(sScriptName," - >=== End of section",sDEBUG)
    	DEBUG(sScriptName," - >==================================================================<",sDEBUG)
	DEBUG(sScriptName," - >=== The actual swiching of " .. sFamilySwitch,sDEBUG)
	if (sFamilyCount == 0) then 
		DeviceOnOffDim(sFamilySwitch,"Off")
	elseif (sFamilyCount == 100) then
	    	DeviceOnOffDim(sFamilySwitch,"On")
	end
	DEBUG(sScriptName," - >=== End of section",sDEBUG)

	-- Alarm is triggered
	DEBUG(sScriptName," - >==================================================================<",sDEBUG)
	DEBUG(sScriptName," - >=== Alarm is triggered",sDEBUG)
	for variableName,variableValue in pairs(uservariables) do
		if (variableName == "uvAlarmTriggered" and variableValue == "True") then
			AlarmTriggerDiff = timedifference(uservariables_lastupdate['uvAlarmTriggered'])
			if (AlarmTriggerDiff <= sWaitTime) then
				DEBUG(sScriptName," - >=== The Alarm grace period is started",sDEBUG)
			elseif (AlarmTriggerDiff > sWaitTime) then
				NOTIFY(2,"Alarm is triggered. Some one is entering your house without permissions!",sDEBUG)
				if (globalvariables['Security'] ~= "Disarmed") then
				    DeviceOnOffDim(sAlarmDevice,"All On",sAlarmDurationTime)
					VarMOD("uvAlarmTriggered","False",0)
				end
			end
		end
    	end
    	DEBUG(sScriptName," - >=== End of section",sDEBUG)

    	-- Set the times when the alarm must go on and off
    	DEBUG(sScriptName," - >==================================================================<",sDEBUG)
	DEBUG(sScriptName," - >=== Set the times when the alarm must go on and off",sDEBUG)
	sAlarmDisable = uservariables["uvAlarmDisable" .. tostring(os.date("%A"))]
	sAlarmDisableHour = tonumber(string.sub(sAlarmDisable,1,string.find(sAlarmDisable,":",1,true)-1))
	sAlarmDisableMinute = tonumber(string.sub(sAlarmDisable,string.find(sAlarmDisable,":",1,true)+1)) + 1
	
	DEBUG(sScriptName," - >=== Day of the week = " .. tostring(os.date("%A")) .. "",sDEBUG)
	DEBUG(sScriptName," - >=== Time to set the new enable and disable alarm times (" .. sAlarmDisableHour .. ":" .. sAlarmDisableMinute .. ")",sDEBUG)

	if (sAlarmRunOnceADay == 0) then
	    -- Calculate when the alarm must be armed
		sWeekday = tostring(os.date("%A"))
		sWeekdayOnTime = uservariables["uvLiving" .. tostring(sWeekday)]
		sHourEnable = tonumber(string.sub(sWeekdayOnTime,1,string.find(sWeekdayOnTime,":",1,true)-1))
		sMinuteEnable = tonumber(string.sub(sWeekdayOnTime,string.find(sWeekdayOnTime,":",1,true)+1))
		if (tonumber(sHourEnable) >= 1 and tonumber(sHourEnable) < 9) then
		    sWeekdayOnTime = os.time{year=os.date("%Y"), month=os.date("%m"), day=(tonumber(os.date("%d")) + 1), hour=sHourEnable, min=sMinuteEnable, sec=00}
		else
		    sWeekdayOnTime = os.time{year=os.date("%Y"), month=os.date("%m"), day=os.date("%d"), hour=sHourEnable, min=sMinuteEnable, sec=00}
		end
		DEBUG(sScriptName," - >=== Alarm Enable time is " .. sWeekdayOnTime .. " (" .. sWeekday .. " - " .. sHourEnable .. ":" .. sMinuteEnable .. ")",sDEBUG)
		VarMOD("uvAlarmWeekdayOnTime",tostring(sWeekdayOnTime),0)
		-- Calculate when the alarm must be turned off
		sWeekday = tonumber(os.date("%d")) + 1
		sWeekday = os.time{year=os.date("%Y"), month=os.date("%m"), day=sWeekday, hour=os.date("%H"), min=os.date("%M"), sec=os.date("%S")}
		sWeekday = os.date("%A", sWeekday)
		sWeekdayOffTime = uservariables["uvAlarmDisable" .. tostring(sWeekday)]
		sHourDisable = tonumber(string.sub(sWeekdayOffTime,1,string.find(sWeekdayOffTime,":",1,true)-1))
		sMinuteDisable = tonumber(string.sub(sWeekdayOffTime,string.find(sWeekdayOffTime,":",1,true)+1))
		sWeekdayOffTime = os.time{year=os.date("%Y"), month=os.date("%m"), day=tonumber(os.date("%d")) + 1, hour=sHourDisable, min=sMinuteDisable, sec=00}
		DEBUG(sScriptName," - >=== Alarm Disable time is " .. sWeekdayOffTime .. " (" .. sWeekday .. " - " .. sHourDisable .. ":" .. sMinuteDisable .. ")",sDEBUG)
		VarMOD("uvAlarmWeekdayOffTime",tostring(sWeekdayOffTime),0)
		VarMOD("uvAlarmRunOnceADay",1,0)
	elseif (tonumber(os.date("%H")) == tonumber(sAlarmDisableHour) and tonumber(os.date("%M")) == (tonumber(sAlarmDisableMinute) + 5)) then
		DEBUG(sScriptName," - >=== It is time to reset the uservariable sAlarmRunOnceADay (" .. sAlarmDisableHour .. ":" .. sAlarmDisableMinute .. ")",sDEBUG)
		if (tostring(sAlarmRunOnceADay) ~= "0") then
			VarMOD("uvAlarmRunOnceADay",0,0)
			DEBUG(sScriptName," - >=== Resetting the uservariable uvAlarmRunOnceADay",sDEBUG)
		end
	else
		DEBUG(sScriptName," - >=== Nothing to do, run once a day",sDEBUG)
	end
    	DEBUG(sScriptName," - >=== End of section",sDEBUG)
    	DEBUG(sScriptName," - >=== End of script",sDEBUG)
    	DEBUG(sScriptName," - >==================================================================<",sDEBUG)
	return commandArray


