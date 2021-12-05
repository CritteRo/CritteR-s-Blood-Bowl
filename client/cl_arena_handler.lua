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
    end
    if exports['critLobby']:LobbyMenuGetActiveMenu() == 'BloodBowl.MainMenu.main' then
        Citizen.Wait(200) --a simple wait, because the frontend framework is slow
        ShowMainMenu(arenaData, false)
        TriggerEvent('lobbymenu:ReloadMenu')
    end
    TriggerEvent('bloodBowl.UpdateOutsidePanel', {name = _panel.name, rp = 1, cash = 1, belowMessage = _panel.belowMessage, playersReady = _panel.playersReady, description = _panel.description})
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
            setCheckpoint("repair", 11, rprCoords[repairSpot].x, rprCoords[repairSpot].y, rprCoords[repairSpot].z, 0.0, 0.0, 0.0, 6.0, 60, 60, 255, 240)
            setCheckpoint("points", 47, pointCoords[pointSpot].x, pointCoords[pointSpot].y, pointCoords[pointSpot].z, 0.0, 0.0, 0.0, 6.0, 255, 60, 60, 240)
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
end)