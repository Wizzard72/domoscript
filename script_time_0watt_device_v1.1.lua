		    --[[      Put a device off when it doesn't use energy
	
    /home/domoticz/domoticz/scripts/lua/script_device_0watt_device_v1.0.lua
	
    -- Autors  ----------------------------------------------------------------
    V1.1 - Paul Slats
	
	
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
			if (deviceName == s0wattDeviceWatt and otherdevices[s0wattDevice] == "On") then
				print("Verschil" .. LastUpdateDiff(s0wattDevice))
				if (LastUpdateDiff(s0wattDevice) >= sStandbyTime) then
					--DEBUG(sScriptName,"Device " .. deviceName .. " is using " .. deviceValue .. " Watt.",sDEBUG)
					s0wattDeviceStandbyTime = LastUpdateDiff(s0wattDevice)
					s0wattDeviceWattStandbyTime = LastUpdateDiff(s0wattDeviceWatt)
					s0wattDeviceLuaStandbyTime = LastUpdateDiff(s0WattDeviceLua)
                                        --DEBUG(sScriptName,"s0wattDeviceLuaStandbyTime = " .. s0wattDeviceLuaStandbyTime,sDEBUG)
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
					elseif (string.sub(otherdevices[s0wattDevicelua], 1, 6) == s0wattMaxWatt .. " Watt") then
						if (tonumber(deviceValue) <= tonumber(s0wattMaxWatt)) then
							if (otherdevices_svalues[s0wattDevicelua] == s0wattMaxWatt .. " Watt (" .. s0wattRounds .. ")") then
								DEBUG(sScriptName,"The last is reached (" .. s0wattMaxWatt .. " Watt (" .. s0wattRounds .. ")).",sDEBUG)
								DEBUG(sScriptName,"The switch " .. s0WattDeviceLua .. " is entering the Stop State (Step = STOP).",sDEBUG)
								TEXTSW(sRecord[3], 'Stop', 60)
							else
								if  (s0wattDeviceLuaStandbyTime >= 60)  then
									count = tonumber(string.sub(otherdevices_svalues[s0wattDevicelua], 9, 9))
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
						DeviceOnOffDim(s0wattDevice,"Off")
						TEXTSW(sRecord[3], 'Start', 0)
						break
					end
		
				else
	                                DEBUG(sScriptName,"Script starts after " .. LastUpdateDiff(s0wattDevice) .. "/" .. sStandbyTime .. " seconds after activating the switch",sDEBUG)
				end
			end
		end
	end
	return commandArray
