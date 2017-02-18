    --[[      Set the initial UTC times for controlling th lights in the living room
 
    /home/domoticz/domoticz/scripts/lua/script_time_livingroom_settime_v1.0.lua
	
    -- Autors  ----------------------------------------------------------------
    V1.0 - Paul Slats
	
	
    -- Uservariables ----------------------------------------------------------
		uvLivingDebug           = String = True / False
		vLivingRoomRunOnceADay  = Integer = 0 (Off) / 1 (On)
		
    ]]--
 
    -- Default Variables      ------------------------------------------------
	local sDEBUG = 0             -- 0 , 1 for domoticz log
	local time = os.date("*t")
	local CurrentTime = os.time()
	-- Variables to customize ------------------------------------------------
	local sScriptName = "LIVINGROOM SETTIME"
	local sRunOnceADay = tonumber(uservariables["uvLivingRoomRunOnceADay"])
	local sSunrise = (timeofday['SunriseInMinutes'] + 5) / 60


    -- Below , edit at your own risk ------------------------------------------
	package.path = package.path .. ";/home/mydomo/domoticz/scripts/lua/modules.lua"
	mymodule = require "mymodule"
	commandArray = {}

	DEBUG(sScriptName,"Set the uservariables for controlling the livingroom lights",sDEBUG)
	DEBUG(sScriptName,"Run Once A Day Switch = " .. sRunOnceADay .. " (0 = Off / 1 = On)",sDEBUG)


	if (string.find(sSunrise,".",1,true) == nil) then
		DEBUG(sScriptName,"It's a full hour, no seconds ..",sDEBUG)
		sSunriseHour = sSunrise
		sSunriseMinute = 00
	else
		DEBUG(sScriptName,"It's not a full hour ..",sDEBUG)
		sSunriseHour = string.sub(sSunrise,1,string.find(sSunrise,".",1,true)-1)
		sSunriseMinute = (sSunrise - sSunriseHour) * 60
	end

	sSunrise = DisableTime("False",sSunriseHour,sSunriseMinute)
	DEBUG(sScriptName,"Sunrise is at " .. sSunrise .. " UTC",sDEBUG)
	DEBUG(sScriptName,"CurrentTime = " .. CurrentTime .. " UTC",sDEBUG)


	if (timeofday['Daytime'] and tostring(sRunOnceADay) ~= "0") then
	-- Turn on the lights (UTC time)
		DEBUG(sScriptName,"time of day is (SunsetInMinutes) " .. timeofday['SunsetInMinutes'],sDEBUG)
		local sWeekdayOnTime = (timeofday['SunsetInMinutes']) / 60
		if (string.find(sWeekdayOnTime,".",1,true) == nil) then
	        DEBUG(sScriptName,"It's a full hour, no seconds ..",sDEBUG)
        	sHour = sWeekdayOnTime
	        sMinute = 00
		else
			DEBUG(sScriptName,"It's not a full hour ..",sDEBUG)
			sHour = string.sub(sWeekdayOnTime,1,string.find(sWeekdayOnTime,".",1,true)-1)
			sMinute = (sWeekdayOnTime - sHour) * 60
		end
		sWeekdayOnTime = DisableTime("False",sHour,sMinute)
		DEBUG(sScriptName,"The weekday On time in UTC is " .. sWeekdayOnTime,sDEBUG)
		commandArray['Variable:uvLivingOnTime'] = tostring(sWeekdayOnTime)

	-- Turn off the lights (UTC time)
		local sWeekdayOffTime = uservariables["uvLiving" .. tostring(os.date("%A"))]
		DEBUG(sScriptName,"Day of the week = " .. tostring(os.date("%A")),sDEBUG)
		sHour = string.sub(sWeekdayOffTime,1,string.find(sWeekdayOffTime,":",1,true)-1)
		sMinute = string.sub(sWeekdayOffTime,string.find(sWeekdayOffTime,":",1,true)+1)
		sWeekdayOffTime = DisableTime("False",sHour,sMinute)
		DEBUG(sScriptName,"The weekday Off time in UTC is " .. sWeekdayOffTime,sDEBUG)
		commandArray['Variable:uvLivingOffTime'] = tostring(sWeekdayOffTime)

	-- Dim the lights 15 minutes before end time
		sWeekdayOffTime = DisableTime("False",sHour,sMinute) - (15 * 60)
		DEBUG(sScriptName,"The weekday Off time (-15 minutes) in UTC is " .. sWeekdayOffTime,sDEBUG)
		commandArray ['Variable:uvLivingDimTime']=tostring(sWeekdayOffTime)

		commandArray['Variable:uvLivingRoomRunOnceADay'] = '0'
		DEBUG(sScriptName,"Resetting the uservariable uvLivingRoomRunOnceADay",sDEBUG)
	elseif (CurrentTime >= sSunrise and CurrentTime <= sSunrise + 60) then
		commandArray['Variable:uvLivingRoomRunOnceADay'] = '1'
        DEBUG(sScriptName,"Resetting the uservariable uvLivingRoomRunOnceADay",sDEBUG)
	end

	DEBUG(sScriptName,"Logging Script - LIVINGROOM SETTIME - Ended",sDEBUG)
	return commandArray

