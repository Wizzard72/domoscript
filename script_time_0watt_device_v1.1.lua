   --[[      Put a device off when it doesn't use energy
	
    /home/domoticz/domoticz/scripts/lua/script_device_0watt_device_v1.0.lua
	
    -- Autors  ----------------------------------------------------------------
    V1.1 - Wizzard72
	
	
    -- Uservariables ----------------------------------------------------------
		uv0wattTotal                   = Integer
		uv0wattDeviceInstances<number> = String
		uv0wattDevice<number>          = String
		
	-- Examples ----------------------------------------------------------
		uv0wattTotal            = 2
		uv0wattDeviceInstances1 = 1,8
		uv0wattDevice1          = Device,Power Meter Device,Standby Time,MaxWatt,Notify Yes/No
		uv0wattDeviceInstances2 = 2,6
		uv0wattDevice2          = Device,Power Meter Device,Standby Time,MaxWatt,Notify Yes/No
		
    ]]--
 
    -- Variables to customize ------------------------------------------------
	local sDEBUG = 0             -- 0 , 1 for domoticz log
	local time = os.date("*t")
	local CurrentTime = os.time()
	local sScriptName = "0watt-time"
	local s0wattTotal = uservariables["uv0wattTotal"]
	local sZWavePoll = 240
	local s0wattRounds = 5
	sRecordAdd = nil
	sRecordAddDebug = ""

    -- Below , edit at your own risk ------------------------------------------
	package.path = package.path .. ";/home/mydomo/domoticz/scripts/lua/modules.lua"
	mymodule = require "mymodule"
	commandArray = {}
	for InstanceTotal = 1, s0wattTotal, 1 do
		s0wattInstances = split(uservariables["uv0wattDeviceInstances" .. InstanceTotal], ",")
		local sInstanceNumber       = s0wattInstances[1]
		local sInstanceTotalDevices = s0wattInstances[2]
		sRecord = split(uservariables["uv0wattDevice" .. sInstanceNumber], ",")
		s0wattDevice  = sRecord[1]
		s0wattDeviceWatt = sRecord[2]
		s0WattDeviceLua = sRecord[3]
		--s0WattDeviceLua = otherdevices_idx['Wasmachine (lua)']
		sStandbyTime = tonumber(sRecord[4])
		s0wattMaxWatt = tonumber(sRecord[5])
		s0wattNofity = sRecord[6]
		for deviceName,deviceValue in pairs(otherdevices) do
			if (deviceName == s0wattDeviceWatt and (otherdevices[s0wattDevice] == "On" or string.sub(otherdevices[s0wattDevice], 1, 9) == "Set Level")) then
				DEBUG(sScriptName,"Device " .. deviceName .. " is using " .. deviceValue .. " Watt.",sDEBUG)
				if (LastUpdateDiff(s0wattDevice) >= sStandbyTime) then
					s0wattDeviceStandbyTime = LastUpdateDiff(s0wattDevice)
					s0wattDeviceWattStandbyTime = LastUpdateDiff(s0wattDeviceWatt)
					s0wattDeviceLuaStandbyTime = LastUpdateDiff(s0WattDeviceLua)
					s0wattDevicelua = tostring(s0wattDevice .. " (lua)")
					if (otherdevices[s0wattDevicelua] == "Hello World") then
						DEBUG(sScriptName,"Reset the Text Device to Start",sDEBUG)
						TEXTSW(sRecord[3], 'Start', 60)
					elseif (otherdevices[s0wattDevicelua] == "Start") then
						DEBUG(sScriptName,"The Text Switch has the right conditions to Start (Step = START).",sDEBUG)
							if (tonumber(deviceValue) <= tonumber(s0wattMaxWatt)) then
								DEBUG(sScriptName,"The energy used by switch " .. s0wattDevice .. " is " .. deviceValue .. " Watt.",sDEBUG)
								if  (s0wattDeviceLuaStandbyTime >= 60)  then
									TEXTSW(sRecord[3], s0wattMaxWatt .. ' Watt (1)', 60)
								end
							end
					elseif (string.sub(otherdevices[s0wattDevicelua], 1, 5 + string.len(s0wattMaxWatt)) == s0wattMaxWatt .. " Watt") then
						if (tonumber(deviceValue) <= tonumber(s0wattMaxWatt)) then
							if (otherdevices_svalues[s0wattDevicelua] == s0wattMaxWatt .. " Watt (" .. s0wattRounds .. ")") then
								DEBUG(sScriptName,"The last is reached (" .. s0wattMaxWatt .. " Watt (" .. s0wattRounds .. ")).",sDEBUG)
								DEBUG(sScriptName,"The switch " .. s0WattDeviceLua .. " is entering the Stop State (Step = STOP).",sDEBUG)
								TEXTSW(sRecord[3], 'Stop', 60)
							else
								if  (s0wattDeviceLuaStandbyTime >= 60)  then
									count = tonumber(string.sub(otherdevices_svalues[s0wattDevicelua], 8 + string.len(s0wattMaxWatt), 8 + string.len(s0wattMaxWatt)))
									count = count + 1
									DEBUG(sScriptName,"Amount of " .. s0wattMaxWatt .. " Watt count = " .. count,sDEBUG)
									DEBUG(sScriptName,"The switch " .. s0WattDeviceLua .. " is in fase " .. s0wattMaxWatt .. " Watt (" .. count .. ") (Step = " .. count .. "/" .. s0wattRounds .. ").",sDEBUG)
									TEXTSW(sRecord[3], s0wattMaxWatt .. " Watt (" .. count .. ")", 60)
								end
							end
						else
							DEBUG(sScriptName,"The switch is still using Energy/ Reset the Text Device to Start",sDEBUG)
							TEXTSW(sRecord[3], 'Start', 60)
						end
					elseif (otherdevices[s0wattDevicelua] == "Stop") then
						if (otherdevices[s0wattDevice] == "On") then
							DEBUG(sScriptName,"The " .. s0wattDevice .. " switch don't use any power the last " .. s0wattRounds .. " minutes, turning the switch off.",sDEBUG)
							DeviceOnOffDim(s0wattDevice,"Off")
						elseif (string.sub(otherdevices[s0wattDevice], 1, 9) == "Set Level") then
							DEBUG(sScriptName,"The " .. s0wattDevice .. " dimmer don't use any power the last " .. s0wattRounds .. " minutes, turning the dimmer off",sDEBUG)
							DeviceOnOffDim(s0wattDevice,0)
						end
						TEXTSW(sRecord[3], 'Start', 0)
						break
					end
		
				else
	                                DEBUG(sScriptName,"Script starts after " .. LastUpdateDiff(s0wattDevice) .. "/" .. sStandbyTime .. " seconds after activating the switch",sDEBUG)
				end
			elseif (otherdevices[s0wattDevice] == "Off" and string.sub(otherdevices[s0WattDeviceLua], 1, 5 + string.len(s0wattMaxWatt)) == s0wattMaxWatt .. " Watt") then
				DEBUG(sScriptName,"The " .. s0wattDevice .. " is off and the " .. s0WattDeviceLua .. " has the wrong state. Reparing this...",sDEBUG)
 				TEXTSW(sRecord[3], 'Start', 60)
			end
		end
	end
	return commandArray
