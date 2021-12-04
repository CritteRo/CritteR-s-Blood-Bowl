local carID = 0
local pedID = 0

AddEventHandler('test.CreateGroups', function()
    AddRelationshipGroup('GROUP_BLOODBOWL_TEST_1')
    AddRelationshipGroup('GROUP_BLOODBOWL_TEST_2')
    AddRelationshipGroup('GROUP_BLOODBOWL_TEST_3')
    AddRelationshipGroup('GROUP_BLOODBOWL_TEST_4')
    AddRelationshipGroup('GROUP_BLOODBOWL_TEST_5')
    AddRelationshipGroup('GROUP_BLOODBOWL_TEST_6')
    AddRelationshipGroup('GROUP_BLOODBOWL_TEST_7')
    AddRelationshipGroup('GROUP_BLOODBOWL_TEST_8')
    AddRelationshipGroup('GROUP_BLOODBOWL_TEST_9')
    AddRelationshipGroup('GROUP_BLOODBOWL_TEST_10')
    AddRelationshipGroup('GROUP_BLOODBOWL_TEST_11')
    AddRelationshipGroup('GROUP_BLOODBOWL_TEST_12')
    AddRelationshipGroup('GROUP_BLOODBOWL_TEST_13')
    AddRelationshipGroup('GROUP_BLOODBOWL_TEST_14')
    AddRelationshipGroup('GROUP_BLOODBOWL_TEST_15')
    AddRelationshipGroup('GROUP_BLOODBOWL_TEST_16')

    for i=1,16 do
        for k=1,16 do
            if i ~= k then
                SetRelationshipBetweenGroups(5--[[hate]], GetHashKey("GROUP_BLOODBOWL_TEST_"..i), GetHashKey("GROUP_BLOODBOWL_TEST_"..k))
            end
        end
    end
end)

TriggerEvent('test.CreateGroups')


RegisterCommand('day', function()
    NetworkOverrideClockTime(12,1,1)
end)

RegisterNetEvent('test.SendPedAndCarToClient2')
AddEventHandler('test.SendPedAndCarToClient2', function(cars, peds)
    for i,k in pairs(peds) do
        while IsEntityAPed(NetToPed(k.driver)) == false or IsEntityAPed(NetToPed(k.shotgun)) == false do
            Citizen.Wait(10)
        end
    end

    for i,k in pairs(cars) do
        while IsEntityAVehicle(NetToVeh(k)) == false do
            Citizen.Wait(10)
        end
    end
    print('Entities loaded for blood bowl')

    local groups = {
        [1] = GetHashKey('GROUP_BLOODBOWL_TEST_1'),
        [2] = GetHashKey('GROUP_BLOODBOWL_TEST_2'),
        [3] = GetHashKey('GROUP_BLOODBOWL_TEST_3'),
        [4] = GetHashKey('GROUP_BLOODBOWL_TEST_4'),
        [5] = GetHashKey('GROUP_BLOODBOWL_TEST_5'),
        [6] = GetHashKey('GROUP_BLOODBOWL_TEST_6'),
        [7] = GetHashKey('GROUP_BLOODBOWL_TEST_7'),
        [8] = GetHashKey('GROUP_BLOODBOWL_TEST_8'),
        [9] = GetHashKey('GROUP_BLOODBOWL_TEST_9'),
        [10] = GetHashKey('GROUP_BLOODBOWL_TEST_10'),
        [11] = GetHashKey('GROUP_BLOODBOWL_TEST_11'),
        [12] = GetHashKey('GROUP_BLOODBOWL_TEST_12'),
        [13] = GetHashKey('GROUP_BLOODBOWL_TEST_13'),
        [14] = GetHashKey('GROUP_BLOODBOWL_TEST_14'),
        [15] = GetHashKey('GROUP_BLOODBOWL_TEST_15'),
        [16] = GetHashKey('GROUP_BLOODBOWL_TEST_16'),
    }

    local carIDS = {}
    local pedIDS = {}
    for i,k in pairs(cars) do
        carIDS[i] = NetToVeh(k)
    end
    local myPlace = math.random(1,16)
    for i,k in pairs(peds) do
        pedIDS[i] = {
            driver = NetToPed(k.driver),
            shotgun = NetToPed(k.shotgun),
        }
        SetPedInfiniteAmmo(pedIDS[i].shotgun, true, "weapon_microsmg")
        SetPedCombatAttributes(pedIDS[i].shotgun, 2, true)
        SetPedCombatAttributes(pedIDS[i].shotgun, 46, true)
        SetPedCombatAttributes(pedIDS[i].shotgun, 3, false)
        SetPedCombatRange(pedIDS[i].shotgun, 2)

        --TaskEnterVehicle(pedID, carID, 5000, 0, 2.0, 1, 0)
        SetPedRelationshipGroupHash(pedIDS[i].shotgun, groups[i])
        if i ~= myPlace then
            SetPedCombatAttributes(pedIDS[i].driver, 3, false)
            SetPedCombatAttributes(pedIDS[i].driver, 52, true)
            local math = math.random(1,2)
            if true then
                SetTaskVehicleChaseBehaviorFlag(pedIDS[i].driver, 1, true)
                TaskVehicleChase(pedIDS[i].driver, PlayerPedId())
                SetTaskVehicleChaseBehaviorFlag(pedIDS[i].driver, 1, true)
            else
                TaskVehicleDriveWander(pedIDS[i].driver, carIDS[i], 40.0, 572)
            end
        else
            SetEntityCoords(pedIDS[i].driver, 0.0,0.0,0.0, false, false, false, false)
            SetPedIntoVehicle(PlayerPedId(), carIDS[i], -1)
        end
    end
end)