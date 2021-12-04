local carID = 0
local pedID = 0

RegisterNetEvent('test.SendPedAndCarToClient')
AddEventHandler('test.SendPedAndCarToClient', function(netVeh, netPed)
    print('waiting for entity load')
    while IsEntityAPed(NetToPed(netPed)) == false or IsEntityAVehicle(NetToVeh(netVeh)) == false do
        Citizen.Wait(0)
    end
    print('entities loaded')
    carID = NetToVeh(netVeh)
    pedID = NetToPed(netPed)
    SetPedInfiniteAmmo(pedID, true, "weapon_microsmg")
    SetPedCombatAttributes(pedID, 2, true)
    SetPedCombatAttributes(pedID, 46, true)
    SetPedCombatAttributes(pedID, 3, false)
    SetPedCombatRange(pedID, 2)

    --TaskEnterVehicle(pedID, carID, 5000, 0, 2.0, 1, 0)
    SetPedRelationshipGroupHash(pedID, GetHashKey('AMBIENT_GANG_BALLAS'))
    SetRelationshipBetweenGroups(5--[[hate]], GetHashKey("COP"), GetHashKey('AMBIENT_GANG_BALLAS'))
    SetRelationshipBetweenGroups(5--[[hate]], GetHashKey("AMBIENT_GANG_BALLAS"), GetHashKey('COP'))
end)

RegisterCommand('taskattack', function()
    SetPedRelationshipGroupHash(pedID, GetHashKey('AMBIENT_GANG_BALLAS'))
    SetRelationshipBetweenGroups(5--[[hate]], GetHashKey("COP"), GetHashKey('AMBIENT_GANG_BALLAS'))
    SetRelationshipBetweenGroups(5--[[hate]], GetHashKey("AMBIENT_GANG_BALLAS"), GetHashKey('COP'))
    RegisterHatedTargetsAroundPed(pedID, 300.0)
    TaskCombatHatedTargetsAroundPed(pedID, 100.0, 0)
    local crds = GetEntityCoords(pedID)
    local retval, outped = GetClosestPed(crds.x, crds.y, crds.z, 50.0, 1,0,0,0,5)
    local crds2 = GetEntityCoords(outped)
    --TaskCombatPed(pedID, outped, 0,16)
    --TaskDriveBy(pedID, outped, carID, crds2.x,crds2.y,crds2.z,50.0,100,false, GetHashKey("firing_pattern_burst_fire_driveby"))
end)

RegisterCommand('day', function()
    NetworkOverrideClockTime(12,1,1)
end)

RegisterCommand('test11', function()
    print(carID)
    print(pedID)
end)