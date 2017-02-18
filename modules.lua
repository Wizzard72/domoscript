    --[[      Modules/Functions repository
 
    /home/mydomo/domoticz/scripts/lua/modules.lua
	
    -- Autors  ----------------------------------------------------------------
    V1.0 - Wizzard72
			
    ]]--
 
    -- Variables to customize ------------------------------------------------


    -- Below , edit at your own risk ------------------------------------------


	local mymodule = {}

	function DEBUG(fScript, fMessage, fDebug)
		fMessage = fScript .. " - " .. fMessage
		if (string.lower(fDebug) == "true" or fDebug == 1) then
				print(fMessage)
		end
	end

	function Notification(fscriptname, fNotification, fOnOff)
		if (fOnOff == "False") then
			commandArray['SendNotification'] = "" .. fNotification .. ""
		elseif (fOnOff == "True") then
		end
	end

	function timedifference (s)
		year = string.sub(s, 1, 4)
		month = string.sub(s, 6, 7)
		day = string.sub(s, 9, 10)
		hour = string.sub(s, 12, 13)
		minutes = string.sub(s, 15, 16)
		seconds = string.sub(s, 18, 19)
		t1 = os.time()
		t2 = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
		difference = os.difftime (t1, t2)
		return difference
	end

	function DisableTime (fDiff, fHour, fMinute)
		year = os.date("%Y")
		month = os.date("%m")
		if (tonumber(fHour) >= 1 and tonumber(fHour) < 5) then
			day = tonumber(os.date("%d")) + 1
		else
			day = os.date("%d")
		end
		hour = fHour
		minutes = fMinute
		seconds = os.date("%S")
		fTime = os.time()
		fDisableTimer = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
		if (fDiff == "True" ) then
			fDifference = (os.difftime (fDisableTimer, fTime)) / 60
			return fDifference
		elseif (fDiff == "False") then
			return fDisableTimer
		end
	end

	function Time (fDiff, fHour, fMinute)
		year = os.date("%Y")
		month = os.date("%m")
		if (tonumber(fHour) >= 1 and tonumber(fHour) < 5) then
			day = tonumber(os.date("%d")) + 1
		else
			day = os.date("%d")
		end
		hour = fHour
		minutes = fMinute
		seconds = os.date("%S")
		fTime = os.time()
		fDisableTimer = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
		if (fDiff == "True" ) then
			fDifference = (os.difftime (fDisableTimer, fTime)) / 60
			return fDifference
		elseif (fDiff == "False") then
			return fDisableTimer
		end
	end

	function split(pString, pPattern)
		local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
		local fpat = "(.-)" .. pPattern
		local last_end = 1
		local s, e, cap = pString:find(fpat, 1)
		while s do
			if s ~= 1 or cap ~= "" then
				table.insert(Table,cap)
			end
			last_end = e+1
			s, e, cap = pString:find(fpat, last_end)
		end
		if last_end <= #pString then
			cap = pString:sub(last_end)
			table.insert(Table, cap)
		end
		return Table
	end

	function split2(s, delimiter)   
		result = {};
		for match in (s..delimiter):gmatch("(.-)"..delimiter) do
			table.insert(result, match);
		end
		return result;
	end

	function LightsOn(LightsOnDevice, LightsOnDim, LightsOnTime)
		if (LightsOnTime ~= nil) then
			if (LightsOnDim == "On") then
				if (otherdevices[LightsOnDevice] == "Off") then
					commandArray[LightsOnDevice] = 'On' .. ' FOR ' .. LightsOnTime
				end
			elseif (LightsOnDim == "Off") then
				if (otherdevices[LightsOnDevice] == "On") then
					commandArray[LightsOnDevice] = 'Off'
				end
			else
				if (otherdevices_svalues[LightsOnDevice] ~= LightsOnDim) then
					commandArray[LightsOnDevice] = 'Set Level ' .. LightsOnDim .. ' FOR ' .. LightsOnTime
				end
			end
		else
			if (LightsOnDim == "On") then
				if (otherdevices[LightsOnDevice] == "Off") then
					commandArray[LightsOnDevice] = 'On'
				end
			elseif (LightsOnDim == "Off") then
				if (otherdevices[LightsOnDevice] == "On") then
					commandArray[LightsOnDevice] = 'Off'
				end
			else
				if (tonumber(otherdevices_svalues[LightsOnDevice]) ~= tonumber(LightsOnDim)) then
					commandArray[LightsOnDevice] = 'Set Level ' .. LightsOnDim
				end
			end
		end
	end

	function Count_Substring( s1, s2 )
		local magic =  "[%^%$%(%)%%%.%[%]%*%+%-%?]"
		local percent = function(s)return "%"..s end
		return select( 2, s1:gsub( s2:gsub(magic,percent), "" ) )
	end

	function LightsAan(fDevice, fDim)
		if (otherdevices_svalues[fDevice] == fDim or otherdevices_svalues[fDevice] == 255) then
		elseif (tonumber(otherdevices_svalues[fDevice]) ~= tonumber(fDim)) then
	    		commandArray[fDevice] = 'Set Level ' .. fDim
		end
	end

	function LightsOnLiving (fDim, fOffMin)
		local fMaxDeviceCount = 10
		fLivingLights = {}
		for b = 1, fMaxDeviceCount, 1 do
			if (uservariables["uvLivingLights" .. b] ~= nil) then
				fLivingLights[b] = uservariables["uvLivingLights" .. b]
				commandArray[fLivingLights[b]] = 'Set Level ' .. fDim
			end
		end
	end

	function round(num, idp)
		if (num == 0) then
			return 0
		else
			local mult = 10^(idp or 0)
			return math.floor(num * mult + 0.5) / mult
		end
	end

	function updown(fDevice, fDimValue)
		if (otherdevices_svalues[fDevice] < fDimValue) then
			-- 5 < 15 = true
			sValue = otherdevices_svalues[fDevice]
			sDifference = math.ceil((fDimValue - sValue) / 5)
			if (sDifference == 1) then
				fDimValue = fDimValue - sValue
			elseif (sDifference > 1) then
				fDimValue = sValue + 5
			end
		elseif (otherdevices_svalues[fDevice] > fDimValue) then
			-- 60 > 15 = true
			sValue = otherdevices_svalues[sRecord[InstanceTotal]]
			sDifference = math.ceil((sValue - fDimValue) / 5)
			if (sDifference == 1) then
				fDimValue = sValue - fDimValue
			elseif (sDifference > 1) then
				fDimValue = sValue -5
			end
		end
		return fDimValue
	end

	function DeviceOnOffDim(LightsOnDevice, LightsOnDim, LightsOnTime)
	        if (LightsOnTime ~= nil) then
	                if (LightsOnDim == "On") then
        	                if (otherdevices[LightsOnDevice] == "Off") then
                	                commandArray[LightsOnDevice] = 'On' .. ' FOR ' .. LightsOnTime
                        	end
                	elseif (LightsOnDim == "Off") then
                        	if (otherdevices[LightsOnDevice] == "On") then
                                	commandArray[LightsOnDevice] = 'Off'
                        	end
			elseif (LightsOnDim == "All Off") then
				if (otherdevices[LightsOnDevice] == "All On") then
	                                commandArray[LightsOnDevice] = 'All Off'
        	                end
			elseif (LightsOnDim == "All On") then
                        	if (otherdevices[LightsOnDevice] == "All Off") then
                                	commandArray[LightsOnDevice] = 'All On' .. ' FOR ' .. LightsOnTime
                        	end
                	else
	                        if (otherdevices_svalues[LightsOnDevice] ~= LightsOnDim) then
        	                        commandArray[LightsOnDevice] = 'Set Level ' .. LightsOnDim .. ' FOR ' .. LightsOnTime
                	        end
                	end
        	else
	                if (LightsOnDim == "On") then
        	                if (otherdevices[LightsOnDevice] == "Off") then
                	                commandArray[LightsOnDevice] = 'On'
                        	end
                	elseif (LightsOnDim == "Off") then
                        	if (otherdevices[LightsOnDevice] == "On") then
	                                commandArray[LightsOnDevice] = 'Off'
        	                end
			elseif (LightsOnDim == "All Off") then
				if (otherdevices[LightsOnDevice] == "All On") then
	                                commandArray[LightsOnDevice] = 'All Off'
        	                end
			elseif (LightsOnDim == "All On") then
                        	if (otherdevices[LightsOnDevice] == "All Off") then
	                                commandArray[LightsOnDevice] = 'All On'
        	                end
                	else
                        	if (tonumber(otherdevices_svalues[LightsOnDevice]) ~= tonumber(LightsOnDim)) then
	                                commandArray[LightsOnDevice] = 'Set Level ' .. LightsOnDim
        	                end
                	end
        	end
	end

	function NOTIFY(fPrio,fNotify, fDebug)
	        if (string.lower(fDebug) == "false" or fDebug == 0) then
	                commandArray['SendNotification'] = "Subject#" .. fNotify .. "#" .. fPrio
        	end
	end

	function VarMOD(fVarName, fVarValue, fVarDiffLastUpdate)
		local fCurrentTime = os.time()
		local fVarLastUpdate = uservariables_lastupdate[fVarName]
		local year = string.sub(fVarLastUpdate, 1, 4)
		local month = string.sub(fVarLastUpdate, 6, 7)
		local day = string.sub(fVarLastUpdate, 9, 10)
		local hour = string.sub(fVarLastUpdate, 12, 13)
		local minutes = string.sub(fVarLastUpdate, 15, 16)
		local seconds = string.sub(fVarLastUpdate, 18, 19)
		fVarLastUpdate = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
		local fStandbyTime = (os.difftime (fCurrentTime, fVarLastUpdate))
		if (fStandbyTime >= fVarDiffLastUpdate) then
			if (tostring(uservariables[fVarName]) ~= tostring(fVarValue)) then
				commandArray['Variable:' .. fVarName] = tostring(fVarValue)
			end
		end
	end


	function SecurPanel(sValue)
		SecuritySwitch = 636
		if (sValue == "Disarm") then
			sValued = "Disarmed"
		elseif (sValue == "Arm Home") then
			sValued = "Armed Home"
			commandArray['SecurityPanel Armed Home by script']='On'
		elseif (sValue == "Arm Away") then
			sValued = "Armed Away"
		end
		if (globalvariables['Security'] ~= sValued) then
			commandArray['SecPanel'] = sValue
		end
	end

	function leapYear(year)   
		return year%4==0 and (year%100~=0 or year%400==0)
	end

	function IsItGonnaRain( minutesinfuture )        	lat='52.13'
	        lon='4.47'
        	debug=false
	        tempfilename = '/var/tmp/rain.tmp' -- can be anywhere writeable
        	url='http://gpsgadget.buienradar.nl/data/raintext?lat='..lat..'&lon='..lon
	        if debug then print(url) end
        	read = os.execute('curl -s -o '..tempfilename..' "'..url..'"')
	        file = io.open(tempfilename, "r")
        	totalrain=0
	        rainlines=0
        	while true do
	                line = file:read("*line")
        	        if not line then break end
                	if debug then print('Line:'..line) end
	                linetime=string.sub(tostring(line), 5, 9)
        	        if debug then print('Linetime: '..linetime) end
                	linetime2 = os.time{year=os.date('%Y'), month=os.date('%m'), day=os.date('%d'), hour=string.sub(linetime,1,2), min=string.sub(linetime,4,5), sec=os.date('%S')}
	                difference = os.difftime (linetime2,os.time())
        	        if ((difference > 0) and (difference<=minutesinfuture*60)) then
                	        if debug then print('Line in time range found') end
                        	        rain=tonumber(string.sub(tostring(line), 0, 3))
                                	totalrain = totalrain+rain
	                                rainlines=rainlines+1
        	                        if debug then print('Rain in timerange: '..rain) end
                	                if debug then print('Total rain now: '..totalrain) end
                        	end
	                end
       	        file:close()
		if (totalrain > 0) then
			sRainfallIntensity = math.pow(10, (totalrain - 109 / 32))
		else
			sRainfallIntensity = 0
		end
                return(sRainfallIntensity)
	end

	function TEXTSW(fSWName, fSWValue, fSWDiffLastUpdate)
		local fCurrentTime = os.time()
		fSWLastUpdate = otherdevices_lastupdate[fSWName]
		local year = string.sub(fSWLastUpdate, 1, 4)
		local month = string.sub(fSWLastUpdate, 6, 7)
		local day = string.sub(fSWLastUpdate, 9, 10)
		local hour = string.sub(fSWLastUpdate, 12, 13)
		local minutes = string.sub(fSWLastUpdate, 15, 16)
		local seconds = string.sub(fSWLastUpdate, 18, 19)
		fSWLastUpdate = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
		local fStandbyTime = (os.difftime (fCurrentTime, fSWLastUpdate))
		if (fStandbyTime >= fSWDiffLastUpdate) then
			if (otherdevices[fSWName] ~= fSWValue) then
				commandArray[otherdevices_idx[fSWName]] = { ['UpdateDevice'] = otherdevices_idx[fSWName] ..'|0|'..fSWValue }
			end
		end
	end

	function LastUpdateDiff(fSWLUName)
		local fLastUpdateTime = os.time()
		fLastUpdate = otherdevices_lastupdate[fSWLUName]
		local year = string.sub(fLastUpdate, 1, 4)
		local month = string.sub(fLastUpdate, 6, 7)
		local day = string.sub(fLastUpdate, 9, 10)
		local hour = string.sub(fLastUpdate, 12, 13)
		local minutes = string.sub(fLastUpdate, 15, 16)
		local seconds = string.sub(fLastUpdate, 18, 19)
		fLastUpdate = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
		fLastUpdateDiff = (os.difftime (fLastUpdateTime, fLastUpdate))
		return fLastUpdateDiff
	end

	return mymodule
