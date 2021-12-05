-------------------------------------------------------------------------------------------------------------------------------------
--                                  THIS FILE CONTAINS BOTH VEHICLE AND COPILOT BEHAVIOR                                           --
-------------------------------------------------------------------------------------------------------------------------------------

pedModels = {
    "u_m_m_streetart_01",
    "u_m_y_pogo_01",
    "u_m_y_rsranger_01",
    "u_m_y_juggernaut_01",
    "u_m_y_zombie_01",
    "u_m_y_imporage",
    "u_m_m_jesus_01",
    "ig_orleans",
    "s_m_y_mime",
    "s_m_m_movalien_01",
    "s_m_m_movspace_01",
}

function CreateArenaVehicle(_model, _x, _y, _z, _h, _col1, _col2, _alarm, _isAmbient)
    local carId = CreateVehicle(_model, _x, _y, _z, _h, true, false)
    SetVehicleAlarm(carId, _alarm)
    SetVehicleColours(carId, _col1, _col2)
    while not DoesEntityExist(carId) do
        Citizen.Wait(0)
    end
    if _isAmbient == true then
        MarkServerEntityAsNoLongerNeeded(carId)
    end
    return carId
end

function CreateCopilot(coords)
    local ped = 0
    local model = pedModels[math.random(1, #pedModels)]
    ped = CreatePed(1, model, coords.x, coords.y, coords.z, math.random(0,200)+0.0, true, false)
    SetPedRandomComponentVariation(ped, 1)
    SetPedRandomProps(ped)
    GiveWeaponToPed(ped, "weapon_microsmg", 9999, false, true)
    SetPedArmour(ped, 100)
    SetPedConfigFlag(ped, 185, true) --prevent auto shufle to driver seat
    MarkServerEntityAsNoLongerNeeded(ped)
    return ped
end

vehicleDump = {} --entity dumpster

refreshTime = 60--in seconds

function MarkServerEntityAsNoLongerNeeded(_entity) --the function
	if DoesEntityExist(_entity) then --check if entity exists
		if NetworkGetEntityOwner(_entity) ~= -1 then --can anyone see the entity?
			table.insert(vehicleDump, _entity) --if yes, store for later.
		else
			--DeleteEntity(_entity) --if no, just delete it.
		end
	end
end

function RunEntityCleanup(isForced)
    for i,k in pairs(vehicleDump) do --check the dumpster
        if NetworkGetEntityOwner(k) == -1 or isForced == true then --can anyone see the entity?
            DeleteEntity(k) --if no, delete it.
            vehicleDump[i] = nil --clean it.
        end
    end
end