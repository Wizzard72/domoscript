    --[[      Set the alarm
	
    /home/domoticz/domoticz/scripts/lua/script_security_alarm_v1.0.lua
	
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
	-- Variables to customize ------------------------------------------------
	local sScriptName = "ALARM SECURITY"
	sAlarmDevice = uservariables['uvAlarmDevice']
	sVacationDevice = uservariables["uvVacationDevice"]

	-- Below , edit at your own risk ------------------------------------------
	package.path = package.path .. ";/home/mydomo/domoticz/scripts/lua/modules.lua"
	mymodule = require "mymodule"
	commandArray = {}

	DEBUG(sScriptName,"Security Alarm: " .. globalvariables['Security'],sDEBUG)

	if (globalvariables['Security'] == "Disarmed") then
		NOTIFY(1,"Alarm Uitgeschakeld!#Alarm Uitgeschakeld",sDEBUG)
		commandArray['Variable:uvAlarmTriggered']="False"
		if (otherdevices[sAlarmDevice] == "All On") then
			DEBUG(sScriptName,"ALARM Uitschakelen",sDEBUG)
			commandArray[sAlarmDevice] = 'Off'
		end
		if (otherdevices[sVacationDevice] == "On") then
			commandArray[sVacationDevice]='Off'
		end
		DeviceOnOffDim("SecurityPanel Armed Home by script","Off")
	elseif (globalvariables['Security'] == "Armed Away") then
		NOTIFY(1,"Alarm Ingeschakeld!#Alarm Type is " .. globalvariables['Security'],sDEBUG)
	elseif (globalvariables['Security'] == "Armed Home") then
		NOTIFY(1,"Alarm Ingeschakeld!#Alarm Type is " .. globalvariables['Security'],sDEBUG)
	end

	DEBUG(sScriptName,"Logging Script - SECURITY ALARM - Ended",sDEBUG)
	return commandArray

