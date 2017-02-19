    --[[      Control lights in the living room
 
    /home/domoticz/domoticz/scripts/lua/script_time_livingroom_v1.0.lua
	
    -- Autors  ----------------------------------------------------------------
    V1.0 - Wizzard72
	
	
    -- Uservariables ----------------------------------------------------------
		uvLivingDebug           = String = True / False
		uvLivingDimTimeRunOnce  = Integer = 0 (Default) / 1
		uvLivingMonday          = Time = Time when the lights must go off
		uvLivingTuesday         = Time = Time when the lights must go off
		uvLivingWednesday       = Time = Time when the lights must go off
		uvLivingThursday        = Time = Time when the lights must go off
		uvLivingFriday          = Time = Time when the lights must go off
		uvLivingSaturday        = Time = Time when the lights must go off
		uvLivingSunday          = Time = Time when the lights must go off
		uvLivingLights<number>  = String = Name of the switch/dimmer
		uvLivingDimTime         = Integer = Initial set to 0, Time when 25% Dim is started
		uvLivingDimTimeRunOnce  = Integer = 0 (Default) / 1
		uvLivingRoomRunOnceADay = Integer = 0 (Off) / 1 (On)
		uvLivingOnTime          = Integer = 0
		uvLivingOffTime         = Integer = 0
    -- Switches -----------------------------------------------------------                                                            
		Huiskamer Lichten Uit Override = On / Off switch

    ]]--
 
    -- Default Variables      ------------------------------------------------
	local sDEBUG = 0             -- 0 , 1 for domoticz log , 2 for file log
	local time = os.date("*t")
	local CurrentTime = os.time()
	local sScriptName = "LIVINGROOM"
	-- Variables to customize ------------------------------------------------
	local sLivingLights = {}
	local DisableLightTime = "False"
	local DisableLightTime25 = "False"
	local sLivingOnTime = uservariables["uvLivingOnTime"]
	local sLivingOffTime = uservariables["uvLivingOffTime"]
	local sLivingDimTime = uservariables["uvLivingDimTime"]
	local sLivingLightsCount = uservariables["uvLivingLightsCount"]
	local sKill = otherdevices['Huiskamer Lichten Uit Override']
	local sRunOnceADay = tonumber(uservariables["uvLivingRoomRunOnceADay"])
	local sLightCountOn = 0
	sDimLevel = 15
	sLevel = 50

    -- Below , edit at your own risk ------------------------------------------
	package.path = package.path .. ";/home/mydomo/domoticz/scripts/lua/modules.lua"
	mymodule = require "mymodule"
	commandArray = {}

	DEBUG(sScriptName,"Control lights in the livingroom",sDEBUG)
	DEBUG(sScriptName,"CurrentTime is " .. CurrentTime,sDEBUG)
	DEBUG(sScriptName,"UTC time when lights go off is " .. sLivingOffTime,sDEBUG)
	DEBUG(sScriptName,"UTC time when lights dim is " .. sLivingOffTime,sDEBUG)
	DEBUG(sScriptName,"Run Once A Day Switch = " .. sRunOnceADay .. " (0 = Off / 1 = On) --",sDEBUG)

	if (CurrentTime >= sLivingOnTime and CurrentTime <= sLivingDimTime and globalvariables['Security'] ~= "Armed Away") then
		for c = 1, sLivingLightsCount, 1 do
			if (uservariables["uvLivingLights" .. c] ~= nil) then
				sLivingLights[c] = uservariables["uvLivingLights" .. c]
				DEBUG(sScriptName,"uvLivingLights" .. c .. " = " .. sLivingLights[c],sDEBUG)
				if (otherdevices[sLivingLights[c]] ~= "Off") then
					sLightCountOn = sLightCountOn + 1
				end
			end
		end

		if (sLivingLightsCount ~= sLightCountOn) then
	
			local sWeekdayOffTime = uservariables["uvLiving" .. tostring(os.date("%A"))]
			DEBUG(sScriptName,"Day of the week = " .. tostring(os.date("%A")) .. "",sDEBUG)

			local sHour = string.sub(sWeekdayOffTime,1,string.find(sWeekdayOffTime,":",1,true)-1)
			local sMinute = string.sub(sWeekdayOffTime,string.find(sWeekdayOffTime,":",1,true)+1)
			DEBUG(sScriptName,"Lights Off Time = " .. sHour .. ":" .. sMinute .. "",sDEBUG)

			local DisableLightTime = DisableTime("True",sHour,sMinute)

--		commandArray['Variable:uvLivingRoomRunOnceADay'] = '1'

			if (otherdevices["SecPanel"] == "Normal" and sKill == "Off" or otherdevices["Huiskamer PIR"] == "Off" and timedifference(otherdevices_lastupdate["Huiskamer PIR"]) >= 6000) then
				DEBUG(sScriptName,"Kill Switch is OFF",sDEBUG)
	        	if (DisableLightTime == "False") then
        	        	DEBUG(sScriptName,"Not yet time to switch on the lights",sDEBUG)
	        	else
        	        	DEBUG(sScriptName,"Time to light on the lichts for " .. DisableLightTime .. " minutes",sDEBUG)
            			for c = 1, sLivingLightsCount, 1 do
		                	if (uservariables["uvLivingLights" .. c] ~= nil) then
				                sLivingLights = uservariables["uvLivingLights" .. c]
				                DeviceOnOffDim(sLivingLights,sLevel)
			                end
		                end
				end
			else
		        DEBUG(sScriptName,"Kill Switch is ON",sDEBUG)
			end
			DEBUG(sScriptName,"Reset the uvLivingDimTimeRunOnce uservariable to 0",sDEBUG)
			VarMOD("uvLivingDimTimeRunOnce",0,0)
			--commandArray ['Variable:uvLivingDimTimeRunOnce']= "0"
		else
			DEBUG(sScriptName,"Livingroom lights are on",sDEBUG)

		end
    --elseif (CurrentTime >= sLivingDimTime and CurrentTime <= sLivingOffTime) then
        --if (sLightCountTotal == sLightCountOn and globalvariables['Security'] ~= "Armed Away") then
			--sDimLevel = (sDimMinValue / sDimMaxValue) * 100
			--DEBUG(sScriptName,"We must dim the lights to " .. sDimLevel .. "%",sDEBUG)
			--LightsOnLiving(sDimLevel,0)

			--DEBUG(sScriptName,"Set the RunOnce flag",sDEBUG)
			--VarMOD(uvLivingDimTimeRunOnce,0,0)
			--commandArray ['Variable:uvLivingDimTimeRunOnce']="1"
		
			-- Store values in user variables
			--DEBUG(sScriptName,"We must adjust the XBMC restored values",sDEBUG)

			--sMaxDeviceCount = 10
        	--for f = 1, sMaxDeviceCount, 1 do
        	--	if (uservariables["uvXBMCLight" .. f] ~= nil) then
	        --   	        sLivingLights[f] = uservariables["uvLivingLights" .. f]
            --       	DEBUG(sScriptName,"uvLivingLights" .. f .. " = " .. sLivingLights[f],sDEBUG)
		      --  		sXBMCLight = uservariables["uvXBMCLight" .. f]
        	    --        commandArray ['Variable:uvXBMCLight[f]']=sDimLevel
	       	     --       DEBUG(sScriptName,"Updated uservariable " .. sXBMCLight .. " to " .. sDimLevel,sDEBUG)
                --end
		    --end
	    --end
	elseif (CurrentTime >= sLivingDimTime and CurrentTime <= sLivingOffTime and tonumber(uservariables["uvLivingDimTimeRunOnce"]) == 0 and globalvariables['Security'] ~= "Armed Away") then
		DEBUG(sScriptName,"We must dim the lights to " .. sDimLevel .. "%",sDEBUG)
		for c = 1, sLivingLightsCount, 1 do
			if (uservariables["uvLivingLights" .. c] ~= nil) then
				sLivingLights = uservariables["uvLivingLights" .. c]
				DeviceOnOffDim(sLivingLights,sDimLevel)
			end
		end
		DEBUG(sScriptName,"Set the RunOnce flag (uvLivingDimTimeRunOnce = 1)" ,sDEBUG)
		VarMOD("uvLivingDimTimeRunOnce",1,0)
    else
		DEBUG(sScriptName,"Nothing to do",sDEBUG)
	end

	DEBUG(sScriptName,"Logging Script Ended",sDEBUG)
	return commandArray

