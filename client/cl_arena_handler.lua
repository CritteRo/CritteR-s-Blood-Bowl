arenaData = { --this should be used only when 
    status = 0, --0 = Open, waiting for players, 1 = starting, 2 = in game, 3 = ending, 4 = offline
    type = 0, --0 = original, 1 = infected, 2 = capture the flag.
    activePlayers = {}, --players alive during the round.
    spectatingPlayers = {}, --players "dead" during the round, 
    lobbyPlayers = {}, --all players, in the lobby.
    maxPlayers = 16,
    startTimer = 30,
    gameData = {}, --depending on the type of gamemode, this should have some values here.
}

local updateCheckpointsThisFrame = false

TriggerServerEvent('BloodBowl.RequestInitialArenaData')

RegisterNetEvent('BloodBowl.UpdateArenaData')
AddEventHandler('BloodBowl.UpdateArenaData', function(_data)
    if _data.gameData.cpSpot ~= nil and _data.gameData.repairSpot ~= nil then
        if _data.gameData.cpSpot ~= arenaData.gameData.cpSpot or _data.gameData.repairSpot ~= arenaData.gameData.repairSpot then
            updateCheckpointsThisFrame = true
        end
    end

    arenaData = _data
    local _panel = {
        name = "Blood Bowl: "..GameTypeToName[arenaData.type],
        description = "Waiting for players",
        playersReady = #arenaData.lobbyPlayers,
        belowMessage = "",
    }
    if arenaData.status == 2 or arenaData.status == 3 then
        _panel.playersReady = #arenaData.activePlayers + #arenaData.spectatingPlayers
        _panel.description = "Game in progress"
    end
    if arenaData.status == 1 then
        _panel.description = string.format(GetLabelText('CBB_MENU_ALERT_START_GAME_COUNTDOWN'), _data.startTimer)
    end
    if arenaData.status == 4 then
        _panel.description = "Arena is offline."
        BusyspinnerOff()
    end
    if arenaData.status == 0 then
        BusyspinnerOff()
    end
    if exports['critLobby']:LobbyMenuGetActiveMenu() == 'BloodBowl.MainMenu.main' then
        Citizen.Wait(200) --a simple wait, because the frontend framework is slow
        ShowMainMenu(arenaData, false)
        TriggerEvent('lobbymenu:ReloadMenu')
    end
    TriggerEvent('bloodBowl.UpdateOutsidePanel', {name = _panel.name, rp = 1, cash = 1, belowMessage = _panel.belowMessage, playersReady = _panel.playersReady, description = _panel.description})
end)

RegisterNetEvent('BloodBowl.GiveEntitiesToPlayers')
RegisterNetEvent('BloodBowl.GiveEntitiesToPlayers', function(gameCars, gamePeds)
    for i,k in pairs(gamePeds) do
        while IsEntityAPed(NetToPed(k)) == false do
            Citizen.Wait(10)
        end
    end

    for i,k in pairs(gameCars) do
        while IsEntityAVehicle(NetToVeh(k)) == false do
            Citizen.Wait(10)
        end
    end
    --print('Entities loaded for blood bowl')

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
    for i,k in pairs(gameCars) do
        carIDS[i] = NetToVeh(k)
        setEntityBlip(carIDS[i], "Enemy")
    end
    local myPlace = math.random(1,16)
    for i,k in pairs(gamePeds) do
        pedIDS[i] = NetToPed(k)
        SetPedInfiniteAmmo(pedIDS[i], true, "weapon_microsmg")
        SetPedCombatAttributes(pedIDS[i], 2, true)
        SetPedCombatAttributes(pedIDS[i], 46, true)
        SetPedCombatAttributes(pedIDS[i], 3, false)
        SetPedCombatRange(pedIDS[i], 2)
        SetPedRelationshipGroupHash(pedIDS[i], groups[i])
    end
end)

RegisterNetEvent('BloodBowl.StartClientGameLoop')
AddEventHandler('BloodBowl.StartClientGameLoop', function()
    local gameID = arenaData.gameData.gameID
    local pointSpot = arenaData.gameData.cpSpot
    local repairSpot = arenaData.gameData.repairSpot
    local rprCoords = originalRepairCoords
    local pointCoords = originalPointsCoords
    local ped = PlayerPedId()

    setCheckpoint("repair", 11, rprCoords[repairSpot].x, rprCoords[repairSpot].y, rprCoords[repairSpot].z, 0.0, 0.0, 0.0, 6.0, 60, 60, 255, 240)
    setCheckpoint("points", 47, pointCoords[pointSpot].x, pointCoords[pointSpot].y, pointCoords[pointSpot].z, 0.0, 0.0, 0.0, 6.0, 255, 60, 60, 240)

    while arenaData.gameData.gameID == gameID and arenaData.status == 2 do
        pointSpot = arenaData.gameData.cpSpot
        repairSpot = arenaData.gameData.repairSpot
        local pointDist = #(vector3(pointCoords[pointSpot].x, pointCoords[pointSpot].y, pointCoords[pointSpot].z) - GetEntityCoords(ped))
        local rprDist = #(vector3(rprCoords[repairSpot].x, rprCoords[repairSpot].y, rprCoords[repairSpot].z) - GetEntityCoords(ped))

        if updateCheckpointsThisFrame == true then
            setCheckpoint("repair", 11, rprCoords[repairSpot].x, rprCoords[repairSpot].y, rprCoords[repairSpot].z+2.0, 0.0, 0.0, 0.0, 6.0, 60, 60, 255, 240)
            setCheckpoint("points", 47, pointCoords[pointSpot].x, pointCoords[pointSpot].y, pointCoords[pointSpot].z-2.0, 0.0, 0.0, 0.0, 6.0, 255, 60, 60, 240)
            updateCheckpointsThisFrame = false
        end
        if pointDist <= 6.0 then
            TriggerServerEvent('BloodBowl.CheckpointReached', 'points')
        end

        if rprDist <= 6.0 then
            TriggerServerEvent('BloodBowl.CheckpointReached', 'repair')
        end
        Citizen.Wait(0)
    end
    RemoveBlip(blip1)
    RemoveBlip(blip2)
end)

RegisterNetEvent('BloodBowl.DisableMyVehicle')
AddEventHandler('BloodBowl.DisableMyVehicle', function()
    if arenaData.status == 2 or arenaData.status == 3 then
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            local _veh = GetVehiclePedIsIn(PlayerPedId(), false)
            BringVehicleToHalt(_veh, 3.0, 100, true)
        end
    end
end)