local carID, pedID = 0, 0

--We actually use 'BloodBowl.CreateGroups', to create the relationship groups needed for the copilot behavior.

AddEventHandler('BloodBowl.CreateGroups', function()
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
        SetRelationshipBetweenGroups(1, GetHashKey('GROUP_BLOODBOWL_TEST_'..i), `PLAYER`)
        SetRelationshipBetweenGroups(1, `PLAYER`, GetHashKey('GROUP_BLOODBOWL_TEST_'..i))
        for k=1,16 do
            if i ~= k then
                SetRelationshipBetweenGroups(5, GetHashKey('GROUP_BLOODBOWL_TEST_'..i), GetHashKey('GROUP_BLOODBOWL_TEST_'..k))
            end
        end
    end
end)

TriggerEvent('BloodBowl.CreateGroups')

--[[
RegisterNetEvent('test.SendPedAndCarToClient2')
AddEventHandler('test.SendPedAndCarToClient2', function(cars, peds)
    for i,k in pairs(peds) do
        while not (IsEntityAPed(NetToPed(k.driver)) or IsEntityAPed(NetToPed(k.shotgun))) do
            Wait(10)
        end
    end

    for i,k in pairs(cars) do
        while not IsEntityAVehicle(NetToVeh(k)) do
            Wait(10)
        end
    end
    print('Entities loaded for blood bowl')

    local groups = {
        [1] = `GROUP_BLOODBOWL_TEST_1`,
        [2] = `GROUP_BLOODBOWL_TEST_2`,
        [3] = `GROUP_BLOODBOWL_TEST_3`,
        [4] = `GROUP_BLOODBOWL_TEST_4`,
        [5] = `GROUP_BLOODBOWL_TEST_5`,
        [6] = `GROUP_BLOODBOWL_TEST_6`,
        [7] = `GROUP_BLOODBOWL_TEST_7`,
        [8] = `GROUP_BLOODBOWL_TEST_8`,
        [9] = `GROUP_BLOODBOWL_TEST_9`,
        [10] = `GROUP_BLOODBOWL_TEST_10`,
        [11] = `GROUP_BLOODBOWL_TEST_11`,
        [12] = `GROUP_BLOODBOWL_TEST_12`,
        [13] = `GROUP_BLOODBOWL_TEST_13`,
        [14] = `GROUP_BLOODBOWL_TEST_14`,
        [15] = `GROUP_BLOODBOWL_TEST_15`,
        [16] = `GROUP_BLOODBOWL_TEST_16`,
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
        SetPedInfiniteAmmo(pedIDS[i].shotgun, true, 'weapon_microsmg')
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

more test code here, don't worry about it.


]]
