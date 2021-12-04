serverArena = { 
    status = 0, --0 = Open, waiting for players, 1 = starting, 2 = in game, 3 = ending, 4 = offline
    type = 0, --0 = original, 1 = infected, 2 = capture the flag.
    activePlayers = {}, --players alive during the round.
    spectatingPlayers = {}, --players "dead" during the round, 
    lobbyPlayers = {}, --all players, in the lobby.
    maxPlayers = 16,
    gameData = {}, --depending on the type of gamemode, this should have some values here.
}

lobbyPlayerData = {id = 0, name = "PlayerName", ready = 0, isHost = "HOST"} --player data used by players in "lobbyPlayers"

originalGameData = {
    status = 0, --0 = Open, waiting for players, 1 = starting, 2 = in game, 3 = ending, 4 = offline
    type = 1, --0 = original, 1 = infected, 2 = capture the flag.
    activePlayers = {}, --players alive during the round.
    spectatingPlayers = {}, --players "dead" during the round, 
    lobbyPlayers = {}, --all players, in the lobby.
    maxPlayers = 16,
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