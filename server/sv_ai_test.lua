RegisterCommand('bloodbowl', function(source, args)
    local src = source
    local cars = {}
    local peds = {}
    for i,k in pairs(spawnCoords) do
        cars[i] = spawnVehicle('deviant', k.x, k.y, k.z, k.h, 0.0,0.0,false, true)
        peds[i] ={
            driver = spawnPed(k),
            shotgun = spawnPed(k),
        }
        SetPedIntoVehicle(peds[i].driver, cars[i], -1)
        SetPedIntoVehicle(peds[i].shotgun, cars[i], 0)
        cars[i] =  NetworkGetNetworkIdFromEntity(cars[i])
        peds[i].driver = NetworkGetNetworkIdFromEntity(peds[i].driver)
        peds[i].shotgun = NetworkGetNetworkIdFromEntity(peds[i].shotgun)
    end
    TriggerClientEvent('test.SendPedAndCarToClient2', src, cars, peds)
end)


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
    ped = CreatePed(1, 'g_m_importexport_01', coords.x, coords.y, coords.z, math.random(0,200)+0.0, true, false)
    SetPedRandomComponentVariation(ped, 1)
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
			DeleteEntity(_entity) --if no, just delete it.
		end
	end
end

function runVehicleCleanup()
    for i,k in pairs(vehicleDump) do --check the dumpster
        if NetworkGetEntityOwner(k) == -1 then --can anyone see the entity?
            DeleteEntity(k) --if no, delete it.
            vehicleDump[i] = nil --clean it.
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(refreshTime * 1000) --arbitrary number of ms...
        runVehicleCleanup()
    end
end)