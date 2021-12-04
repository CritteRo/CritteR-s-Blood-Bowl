serverArena = { 
    status = 0, --0 = Open, waiting for players, 1 = starting, 2 = in game, 3 = ending, 4 = offline
    type = 0, --0 = original, 1 = infected, 2 = capture the flag.
    activePlayers = {}, --players alive during the round.
    spectatingPlayers = {}, --players "dead" during the round, 
    lobbyPlayers = {}, --all players, in the lobby.
    maxPlayers = 16,
    startTimer = 30, --timer, in seconds, from when HOST player presses on Start.
    gameData = {}, --depending on the type of gamemode, this should have some values here.
}

lobbyPlayerData = {id = 0, name = "PlayerName", ready = 0, isHost = "HOST"} --player data used by players in "lobbyPlayers"

originalGameData = {
    status = 0, --0 = Open, waiting for players, 1 = starting, 2 = in game, 3 = ending, 4 = offline
    type = 0, --0 = original, 1 = infected, 2 = capture the flag.
    activePlayers = {}, --players alive during the round.
    spectatingPlayers = {}, --players "dead" during the round, 
    lobbyPlayers = {}, --all players, in the lobby.
    maxPlayers = 16,
    startTimer = 30, --timer, in seconds, from when HOST player presses on Start.
    gameData = {timeLeft = GetGameTimer() + 900000 --[[15 minutes]], gameID = math.random(1,999999999)},
}
originalPlayerData = {id = 0, name = "PlayerName", score = 30, checkpointsUsed = 0, repairsUsed = 0} --player data used by players in the original blood bowl.

serverPlayers = {
    [0] = {
        srcID = 0,
        name = "PlayerName",
        inArena = -1, -- -1 = false, 0 or more = gameID
        canJoinArena = true, --true by default. Might be needed later, idk.
        showFirstTooltip = true, --would show a tooltip that tells you about the /disable_notifications command.
        showNotifications = true --would show you notifications whenever an arena becomes active, is about to start, starts and ends.
    }
}

function CreateNewPlayerData(srcID)
    serverPlayers[srcID] = {
        srcID = srcID,
        name = GetPlayerName(srcID),
        inArena = -1, -- -1 = false, 0 or more = gameID
        canJoinArena = true, --true by default. Might be needed later, idk.
        showFirstTooltip = true, --would show a tooltip that tells you about the /disable_notifications command.
        showNotifications = true --would show you notifications whenever an arena becomes active, is about to start, starts and ends.
    }
end

AddEventHandler('playerJoining', function(oldID) --make sure we count ALL players that join.
    local src = source
    CreateNewPlayerData(src)
end)

AddEventHandler('onResourceStart', function(_name) --make sure we register ALL ONLINE players, in case the resource needs to be restarted while the server runs.
    if _name == GetCurrentResourceName() then
        for _,src in ipairs(GetPlayers()) do
            CreateNewPlayerData(src)
        end
    end
end)

AddEventHandler('playerDropped', function(reason) --cleaning the players table, and making sure that the arena doesn't break, in case he was in one.
    local src = source
    if serverPlayers[src] ~= nil then
        if serverPlayers[src].inArena ~= -1 then --checking if player is in a arena, even if just in lobby.
            if serverArena.gameData.gameID == serverPlayers[src].inArena then
                if serverArena.status == 0 or serverArena.status == 1 then -- if everyone is still in lobby, remove them from the lobby.
                    serverArena.lobbyPlayers[src] = nil
                    serverPlayers[src] = nil
                elseif serverArena.status == 2 or serverArena.status == 3 then-- if people are in-game, remove them from the game.
                    if serverArena.activePlayers[src] ~= nil then
                        serverArena.activePlayers[src] = nil
                    elseif serverArena.spectatingPlayers[src] ~= nil then
                        serverArena.spectatingPlayers[src] = nil
                    end
                    serverPlayers[src] = nil
                end
            else --if not, he/she was desynced anyway, so just remove him.
                serverPlayers[src] = nil
            end
        else --if not, just remove the player entry.
            serverPlayers[src] = nil
        end
    end
end)

function forceRestartArena(isSilent, isExpected, closeArenaAfterRestart, gameType, gameID)
    --gameID would not be used for now. But in case I decide to add multiple arenas..it can.
    --gameType is the gamemode type that will use when the arena restarts.
    for i,k in pairs(serverPlayers) do
        if tonumber(i) > 0 then
            if k.inArena ~= -1 and k.inArena == serverArena.gameData.gameID then
                serverPlayers[i].inArena = -1
                local ped = GetPlayerPed(i)
                SetEntityCoords(ped, arenaCoords['outsideArena'].x, arenaCoords['outsideArena'].y, arenaCoords['outsideArena'].z, false, true, false, false)
                if isSilent == false then
                    if isExpected == true then
                        TriggerClientEvent('BloodBowl.Show_UI_Element', i, "notify", "[~r~Blood Bowl~s~] The arena has ended.")
                    else
                        TriggerClientEvent('BloodBowl.Show_UI_Element', i, "notify", "[~r~Blood Bowl~s~] An unexpected error ended the arena.")
                    end
                end
            end
            if isSilent == false and isExpected == true and k.showNotifications == true then
                TriggerClientEvent('BloodBowl.Show_UI_Element', k.srcID, "notify", "[~r~Blood Bowl~s~] The arena has ended.")
            end
        end
    end

    if gameType == 0 then
        serverArena = originalGameData
    else
        print('WARNING: USED WRONG GAMETYPE IN forceRestartArena. :: sv_arena_handler.lua')
    end
    if closeArenaAfterRestart == true then
        serverArena.status = 4
    end

    TriggerClientEvent('BloodBowl.UpdateArenaData', -1, serverArena)
end

RegisterCommand('newarena', function(source, args)
    forceRestartArena(false, true, false, 0, 0)
end)

RegisterNetEvent('BloodBowl.SetReady')
AddEventHandler('BloodBowl.SetReady', function(_bool)
    local src = source
    local myPlace = nil
    if serverArena.status == 0 or serverArena.status == 1 then
        --check for my place
        for i,k in pairs(serverArena.lobbyPlayers) do
            if k.id == src then
                myPlace = i
                break
            end
        end
        if serverArena.lobbyPlayers[myPlace].ready == 0 then
            serverArena.lobbyPlayers[myPlace].ready = 1
            if serverArena.status == 1 then
                serverArena.status = 0
                serverArena.startTimer = 30
            end
        elseif serverArena.lobbyPlayers[myPlace].ready == 1 then
            serverArena.lobbyPlayers[myPlace].ready = 0
            if serverArena.status == 1 then
                serverArena.status = 0
                serverArena.startTimer = 30
            end
        end
        TriggerClientEvent('BloodBowl.UpdateArenaData', -1, serverArena)
    end
end)

RegisterNetEvent('BloodBowl.StartGameCountdown')
AddEventHandler('BloodBowl.StartGameCountdown', function()
    local src = source
    local srcIsHost = false
    local allReady = true
    if serverArena.status == 0 and #serverArena.lobbyPlayers >= 1 then
        for i,k in pairs(serverArena.lobbyPlayers) do
            if k.id == src and k.isHost == "HOST" then
                srcIsHost = true
            end
            if k.ready == 0 then
                allReady = false
            end
        end
    end

    if srcIsHost == true and allReady == true then
        --start countdown.
        serverArena.status = 1
        while serverArena.status == 1 do
            if serverArena.startTimer > 0 then
                serverArena.startTimer = serverArena.startTimer - 1
            else
                TriggerEvent('BloodBowl.StartGame')
            end
            TriggerClientEvent('BloodBowl.UpdateArenaData', -1, serverArena)
            Citizen.Wait(1000)
        end
    end
end)

RegisterNetEvent('BloodBowl.PlayerOpenedMainMenu')
AddEventHandler('BloodBowl.PlayerOpenedMainMenu', function()
    local src = source
    if serverArena.status == 1 or serverArena.status == 0 then
        if #serverArena.lobbyPlayers < serverArena.maxPlayers then
            local _data = {id = src, name = GetPlayerName(src), ready = 0, isHost = ""}
            if #serverArena.lobbyPlayers == 0 then
                _data.isHost = "HOST"
                _data.ready = 1
            end
            table.insert(serverArena.lobbyPlayers, _data)
            if serverArena.status == 1 then
                serverArena.status = 0
                serverArena.startTimer = 30
            end
            Citizen.Wait(200)
            TriggerClientEvent('BloodBowl.UpdateArenaData', -1, serverArena)
        end
    end
end)

RegisterNetEvent('BloodBowl.PlayerClosedMainMenu')
AddEventHandler('BloodBowl.PlayerClosedMainMenu', function()
    local src = source
    if serverArena.status == 1 or serverArena.status == 0 then
        --look for the player in lobby.
        local myPlace = nil
        for i,k in pairs(serverArena.lobbyPlayers) do
            if k.id == src then
                myPlace = i
                break
            end
        end
        if myPlace ~= nil then
            if serverArena.lobbyPlayers[myPlace].isHost == "HOST" then
                for i,k in pairs(serverArena.lobbyPlayers) do
                    if i ~= myPlace then
                        serverArena.lobbyPlayers[i].isHost = "HOST"
                        serverArena.lobbyPlayers[i].ready = 1
                        break
                    end
                end
            end
            if serverArena.status == 1 then
                serverArena.status = 0
                serverArena.startTimer = 30
            end
            serverArena.lobbyPlayers[myPlace] = nil
            TriggerClientEvent('BloodBowl.UpdateArenaData', -1, serverArena)
        end
    end
end)

RegisterCommand('forceUpdate', function(source, args)
    TriggerClientEvent('BloodBowl.UpdateArenaData', -1, serverArena)
end)