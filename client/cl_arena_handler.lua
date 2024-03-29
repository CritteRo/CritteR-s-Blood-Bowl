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
        Wait(200)
        ShowMainMenu(arenaData, false)
        TriggerEvent('lobbymenu:ReloadMenu')
    end
    TriggerEvent('bloodBowl.UpdateOutsidePanel', {name = _panel.name, rp = 0, cash = 0, belowMessage = _panel.belowMessage, playersReady = _panel.playersReady, description = _panel.description})
end)

RegisterNetEvent('BloodBowl.GiveEntitiesToPlayers')
RegisterNetEvent('BloodBowl.GiveEntitiesToPlayers', function(gameCars, gamePeds, gamePeds2)
    local retries = 0
    for i,k in pairs(gamePeds) do
        while not IsEntityAPed(NetToPed(k)) or retries < 20 do
            Wait(10)
            retries = retries + 1
        end
        retries = 0
    end

    for i,k in pairs(gameCars) do
        while not IsEntityAVehicle(NetToVeh(k)) do
            Wait(10)
        end
    end

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
    for i,k in pairs(gameCars) do
        carIDS[i] = NetToVeh(k)
        setEntityBlip(carIDS[i], "Enemy")
    end
    local myPlace = math.random(1,16)
    for i,k in pairs(gamePeds) do
        pedIDS[i] = NetToPed(k)
        SetEntityMaxHealth(pedIDS[i], 9999)
        SetEntityHealth(pedIDS[i], 9999)
        SetPedInfiniteAmmo(pedIDS[i], true, "weapon_microsmg")
        SetPedCombatAttributes(pedIDS[i], 2, true)
        SetPedCombatAttributes(pedIDS[i], 46, true)
        SetPedCombatAttributes(pedIDS[i], 3, false)
        SetPedCombatRange(pedIDS[i], 2)
        SetPedRelationshipGroupHash(pedIDS[i], groups[i])
    end

    for i,k in pairs(gamePeds2) do

        SetEntityMaxHealth(k, 9999)
        SetEntityHealth(k, 9999)
        SetPedInfiniteAmmo(k, true, "weapon_microsmg")
        SetPedCombatAttributes(k, 2, true)
        SetPedCombatAttributes(k, 46, true)
        SetPedCombatAttributes(k, 3, false)
        SetPedCombatRange(k, 2)
        SetPedRelationshipGroupHash(k, groups[i])
        TaskVehicleDriveWander(k, carIDS[i], math.random(25,35)+0.01, 1074528293)
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
        local pedPos = GetEntityCoords(ped)
        local pointDist = #(vector3(pointCoords[pointSpot].x, pointCoords[pointSpot].y, pointCoords[pointSpot].z) - pedPos)
        local rprDist = #(vector3(rprCoords[repairSpot].x, rprCoords[repairSpot].y, rprCoords[repairSpot].z) - pedPos)

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
        Wait(0)
    end
    RemoveBlip(blip1)
    RemoveBlip(blip2)
end)

RegisterNetEvent('BloodBowl.DisableMyVehicle')
AddEventHandler('BloodBowl.DisableMyVehicle', function()
    if arenaData.status == 2 or arenaData.status == 3 then
        local plyPed = PlayerPedId()
        if IsPedInAnyVehicle(plyPed, false) then
            local _veh = GetVehiclePedIsIn(plyPed, false)
            BringVehicleToHalt(_veh, 3.0, 100, true)
        end
    end
end)
