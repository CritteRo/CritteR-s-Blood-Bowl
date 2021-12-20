
function spawnVehicle(_model, _x, _y, _z, _h, _col1, _col2, _alarm, _isAmbient)
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

function spawnPed(coords)
    local ped = 0
    ped = CreatePed(1, 'u_m_m_streetart_01', coords.x, coords.y, coords.z, math.random(0,200)+0.0, true, false)
    SetPedRandomComponentVariation(ped, 1)
    GiveWeaponToPed(ped, "weapon_microsmg", 9999, false, true)
    SetPedArmour(ped, 100)
    SetPedConfigFlag(ped, 185, true) --prevent auto shufle to driver seat
    --MarkServerEntityAsNoLongerNeeded(ped)
    return ped
end