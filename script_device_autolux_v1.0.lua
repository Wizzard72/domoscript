    --[[      Automaticly enable lights depending the amount of lux
	
    /home/domoticz/domoticz/scripts/lua/script_device_autolux_v1.0.lua
	
    -- Autors  ----------------------------------------------------------------
    V1.0 - Paul Slats
	
	
    -- Uservariables --------------------------------------------------------
		uvAutoLuxDebug               = String = True / False
		uvAutoLuxTotal               = Integer = Total number of instances
		uvAutoLuxInstances<number>   = String = Instance number, total number of fields in uvAutoLuxDevice<number>
		uvAutoLuxDevice<number>      = String = Lux Device,Desired Lux,Increase by,PIR Device,PIR Timeout,Time Start, Time End,Dimmer1,Dimmer2,Dimmer3, etc.
		
	-- Switches --------------------------------------------------------
		Security panel          = Security panel
		
	-- Examples ----------------------------------------------------------
		uvAutoLuxDebug = True
		uvAutoLuxTotal = 1
		uvAutoLuxInstances1 = 1,10
		uvAutoLuxDevice1 = Living Lux,25,5,Living PIR,05:35,22:30,Living 1, Living 2, Diner 1
		
    ]]--
 
    -- Default Variables      ------------------------------------------------
	local sDEBUG = 0             -- 0 , 1 for domoticz log
	local time = os.date("*t")
	local CurrentTime = os.time()
	-- Variables to customize ------------------------------------------------
	local sScriptName = "AUTOLUX"
	local sSecurityPanel = "SecPanel"
	local sKill = otherdevices['Huiskamer Lichten Uit Override']
	local sKODI = otherdevices['Huiskamer KODI']
	local sAnybodyHome = uservariables["uvAlarmFamilySwitch"]
	local sLivingOnTime = uservariables["uvLivingOnTime"]
	local sLivingOffTime = uservariables["uvLivingOffTime"]

	-- Below , edit at your own risk ------------------------------------------
	package.path = package.path .. ";/home/mydomo/domoticz/scripts/lua/modules.lua"
	mymodule = require "mymodule"
	commandArray = {}
    sAUtoluxRun = "False"

	DEBUG(sScriptName,"Auto Lux script is running...",sDEBUG)

if (sAUtoluxRun == "False") then
    sAUtoluxRun = "True"
    if (otherdevices[sSecurityPanel] == "Normal") then
	    for device, v in pairs(devicechanged) do
		    if (string.match(device, "Lux") == "Lux" or string.match(device, "PIR") == "PIR") then
			    if (globalvariables['Security'] == "Disarmed" and sKill == "Off" and otherdevices[sAnybodyHome] == "On") then
                    sTotalRecords = uservariables["uvAutoLuxTotal"]
        	        for InstanceTotal = 1, sTotalRecords, 1 do
	        	        sAutoLuxInstances = split(uservariables["uvAutoLuxInstances" .. InstanceTotal], ",")
    	        	    sInstanceNumber       = sAutoLuxInstances[1]
                        sInstanceTotalDevices = sAutoLuxInstances[2]
		                sRecord = split(uservariables["uvAutoLuxDevice" .. sInstanceNumber], ",")
		                sLuxDevice  = sRecord[1]
		                sDesiredLux = tonumber(sRecord[2])
                        sIncreaseBy = tonumber(sRecord[3])
                        sPIRDevice  = sRecord[4]
                        sPIRTimeout = tonumber(sRecord[5])
                        sTimeStart  = sRecord[6]
                        sTimeStartHour = tonumber(string.sub(sTimeStart,1,string.find(sTimeStart,":",1,true)-1))
                        sTimeStartMinute = tonumber(string.sub(sTimeStart,string.find(sTimeStart,":",1,true)+1))
                        sTimeStart = Time("False",sTimeStartHour,sTimeStartMinute)
                        sTimeEnd    = sRecord[7]
                        if (sTimeEnd == "sunset") then
                            sWeekdayOnTime = (timeofday['SunsetInMinutes']) / 60
                            sTimeEndHour = string.sub(sWeekdayOnTime,1,string.find(sWeekdayOnTime,".",1,true)-1)
                            sTimeEndMinute = (sWeekdayOnTime - sTimeEndHour) * 60
                        else
                            sTimeEndHour = tonumber(string.sub(sTimeEnd,1,string.find(sTimeEnd,":",1,true)-1))
                            sTimeEndMinute = tonumber(string.sub(sTimeEnd,string.find(sTimeEnd,":",1,true)+1))
                        end
                        sTimeEnd = Time("False",sTimeEndHour,sTimeEndMinute)
                        DEBUG(sScriptName,"The current light intensity is " .. otherdevices_svalues[sRecord[1]] .. " Lux",sDEBUG)
                        if (CurrentTime > sTimeStart and CurrentTime < sTimeEnd) then
                            sDesiredLuxMin = sDesiredLux - 1
                            sDesiredLuxMax = sDesiredLux + 1
						    DEBUG(sScriptName,"The current time falls between the set times",sDEBUG)
                            DEBUG(sScriptName,sDesiredLuxMin .. " <= " .. otherdevices_svalues[sRecord[1]] .. " >= " .. sDesiredLuxMax,sDEBUG)
                            if (tonumber(otherdevices_svalues[sRecord[1]]) >= sDesiredLuxMin and tonumber(otherdevices_svalues[sRecord[1]]) <= sDesiredLuxMax) then
                                DEBUG(sScriptName,"The light intensity values fall within the configured range",sDEBUG)
                                if (otherdevices[sPIRDevice] == "Off" and timedifference(otherdevices_lastupdate[sPIRDevice]) >= sPIRTimeout) then
                                    sValue = 0
                                    for LightDevicesCount = 8, sInstanceTotalDevices, 1 do
                                        DEBUG(sScriptName,"Lately no motion is detected. The light '" .. sRecord[LightDevicesCount] .. "' is turned off.",sDEBUG)
                                        DeviceOnOffDim(sRecord[LightDevicesCount],sValue)
                                    end
                                end
                            else
                                if (tonumber(otherdevices_svalues[sRecord[1]]) < sDesiredLux) then
                                    DEBUG(sScriptName,"The current light intensity is less than the set light intensity",sDEBUG)
                                    for LightDevicesCount = 8, sInstanceTotalDevices, 1 do
                                        DEBUG(sScriptName,"sRecord[" .. LightDevicesCount .. "] = " .. sRecord[LightDevicesCount],sDEBUG)
                                        sValue = tonumber(otherdevices_svalues[sRecord[LightDevicesCount]])
                                        if (otherdevices[sPIRDevice] == "Off" and timedifference(otherdevices_lastupdate[sPIRDevice]) >= sPIRTimeout) then
                                            sValue = 0
                                            DEBUG(sScriptName,"Lately no motion is detected. The light '" .. device .. "' is turned off.",sDEBUG)
                                            DeviceOnOffDim(sRecord[LightDevicesCount],sValue)
                                        else
                                            if (otherdevices[sRecord[LightDevicesCount]] == "Off" or sValue == 0) then
                                                sValue = sIncreaseBy
                                                DEBUG(sScriptName,"sIncreaseBy = " .. sIncreaseBy,sDEBUG)
											    DEBUG(sScriptName,"The device '" .. sRecord[LightDevicesCount] .. "' is off.",sDEBUG)
                                                DEBUG(sScriptName,"Set dim level for '" .. sRecord[LightDevicesCount] .. "' to " .. sIncreaseBy .. "%",sDEBUG)
                                            else
                                                if (sValue == 100 or sValue == 255) then
                                                    DEBUG(sScriptName,"The device '" .. sRecord[LightDevicesCount] .. "' is at maximum dim level",sDEBUG)
                                                elseif (sValue >= 100 - sIncreaseBy) then
                                                    sValue = 100
                                                    DEBUG(sScriptName,"The light intensity for device '".. sRecord[LightDevicesCount] .. "' is not reached yet. The dim level is increased to " .. sValue .. "%",sDEBUG)
                                                else
                                                    sValue = sValue + sIncreaseBy
                                                    DEBUG(sScriptName,"The light intensity for device '".. sRecord[LightDevicesCount] .. "' is not reached yet. The dim level is increased to " .. sValue .. "%",sDEBUG)
                                                end
                                            end
                                            if (CurrentTime >= sLivingOnTime and CurrentTime <= sLivingOffTime) then
                                                DEBUG(sScriptName,"The lights are controlled by the Livingroom App",sDEBUG)
                                            else
                                                DEBUG(sScriptName,"The lights are adjusted to the specified dim level",sDEBUG)
                                                DeviceOnOffDim(sRecord[LightDevicesCount],sValue)
                                            end
                                        end
                                    end
                                elseif (tonumber(otherdevices_svalues[sRecord[1]]) > sDesiredLux) then
                                    DEBUG(sScriptName,"The current light intensity is higher than the set light intensity",sDEBUG)
                                    for LightDevicesCount = 8, sInstanceTotalDevices, 1 do
                                        sValue = tonumber(otherdevices_svalues[sRecord[LightDevicesCount]])
                                        DEBUG(sScriptName,"sValue = " .. otherdevices_svalues[sRecord[9]],sDEBUG)
                                        DEBUG(sScriptName,"sIncreaseBy = " .. sIncreaseBy,sDEBUG)
                                        if (otherdevices[sPIRDevice] == "Off" and timedifference(otherdevices_lastupdate[sPIRDevice]) >= sPIRTimeout) then
                                            sValue = 0
                                            DEBUG(sScriptName,"Lately no motion is detected. The light '" .. sRecord[LightDevicesCount] .. "' is turned off.",sDEBUG)
                                            DeviceOnOffDim(sRecord[LightDevicesCount],sValue)
                                        else
                                            if (otherdevices[sRecord[LightDevicesCount]]) == "Off" then
                                                DEBUG(sScriptName,"Lights are off",sDEBUG)
                                                sValue = 0
                                            elseif (sValue == 100 or sValue == 255) then
                                                sValue = 100 - sIncreaseBy
											    DEBUG(sScriptName,"The device '" .. sRecord[LightDevicesCount] .. "' is at maximum dim level",sDEBUG)
                                                DEBUG(sScriptName,"The light intensity for device '".. sRecord[LightDevicesCount] .. "' is to high. The dim level is decreased to " .. sValue .. "%",sDEBUG)
                                            elseif (sValue <= tonumber(sIncreaseBy)) then
                                                DEBUG(sScriptName,"The dim level is smaller than the dim step. The device '" .. sRecord[LightDevicesCount] .. "' is turned off",sDEBUG)
                                                --sValue = 0
                                                if (sValue == 0) then
                                                    sValue = 0
                                                else
                                                    sValue = sValue -1
                                                end
                                            else
                                                sValue = sValue - sIncreaseBy
                                                DEBUG(sScriptName,"The light intensity for device '".. sRecord[LightDevicesCount] .. "' is to high. The dim level is decreased to " .. sValue .. "%",sDEBUG)
                                            end
                                            if (CurrentTime >= sLivingOnTime and CurrentTime <= sLivingOffTime) then
                                                DEBUG(sScriptName,"The lights are controlled by the Livingroom App",sDEBUG)
                                            else
                                                DEBUG(sScriptName,"The lights are adjusted to the specified dim level",sDEBUG)
                                                DeviceOnOffDim(sRecord[LightDevicesCount],sValue)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    DEBUG(sScriptName,"Logging Script - AUTOLUX - Ended",sDEBUG)
			    end
		    end
        end
    end
end    
    sAUtoluxRun = "False"
	return commandArray

