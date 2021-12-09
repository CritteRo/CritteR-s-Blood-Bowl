--SetRoutingBucketEntityLockdownMode(0, "strict") --only for testing.

gameCars = {} --table to keep all game cars
gameCopilots = {} --table to keep all game copilots

serverArena = { 
    status = 0, --0 = Open, waiting for players, 1 = starting, 2 = in game, 3 = ending, 4 = offline
    type = 0, --0 = original, 1 = infected, 2 = capture the flag.
    activePlayers = {}, --players alive during the round.
    spectatingPlayers = {}, --players "dead" during the round, 
    lobbyPlayers = {}, --all players, in the lobby.
    maxPlayers = 16,
    startTimer = 10, --timer, in seconds, from when HOST player presses on Start.
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
    startTimer = 10, --timer, in seconds, from when HOST player presses on Start.
    gameData = {timeLeft = GetGameTimer() + 900000 --[[15 minutes]], gameID = math.random(1,999999999), isEveryoneReady = false, maxPoints = 100, repairSpot = 1, cpSpot = 1},
}
originalPlayerData = {id = 0, name = "PlayerName", score = 30, checkpointsUsed = 0, repairsUsed = 0, finishedIntro = false} --player data used by players in the original blood bowl.

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
    RunEntityCleanup(true)
    for i,k in pairs(serverPlayers) do
        if tonumber(i) > 0 then
            if k.inArena ~= -1 and k.inArena == serverArena.gameData.gameID then
                serverPlayers[i].inArena = -1
                local ped = GetPlayerPed(i)
                SetEntityCoords(ped, arenaCoords['outsideArena'].x , arenaCoords['outsideArena'].y, arenaCoords['outsideArena'].z, false, true, false, false)
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
        --serverArena = originalGameData
        serverArena = {
            status = 0, --0 = Open, waiting for players, 1 = starting, 2 = in game, 3 = ending, 4 = offline
            type = 0, --0 = original, 1 = infected, 2 = capture the flag.
            activePlayers = {}, --players alive during the round.
            spectatingPlayers = {}, --players "dead" during the round, 
            lobbyPlayers = {}, --all players, in the lobby.
            maxPlayers = originalGameData.maxPlayers,
            startTimer = originalGameData.startTimer, --timer, in seconds, from when HOST player presses on Start.
            gameData = {timeLeft = GetGameTimer() + 900000 --[[15 minutes]], gameID = math.random(1,999999999), isEveryoneReady = false, maxPoints = originalGameData.gameData.maxPoints, repairSpot = 1, cpSpot = 1},
        }
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
AddEventHandler('BloodBowl.SetReady', function(_bool, _isBot)
    local src = source
    if _isBot ~= nil and _isBot ~= false then
        src = tonumber(_isBot)
        _name = "Bot "..src..""
    end
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
                serverArena.startTimer = originalGameData.startTimer
            end
        elseif serverArena.lobbyPlayers[myPlace].ready == 1 then
            serverArena.lobbyPlayers[myPlace].ready = 0
            if serverArena.status == 1 then
                serverArena.status = 0
                serverArena.startTimer = originalGameData.startTimer
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
            print(serverArena.startTimer)
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
AddEventHandler('BloodBowl.PlayerOpenedMainMenu', function(_isBot)
    local src = source
    local _name = GetPlayerName(src)
    if _isBot ~= nil and _isBot ~= false then
        src = tonumber(_isBot)
        _name = "Bot "..src..""
    end
    if serverArena.status == 1 or serverArena.status == 0 then
        if #serverArena.lobbyPlayers < serverArena.maxPlayers then
            local _data = {id = src, name = _name, ready = 0, isHost = ""}
            if #serverArena.lobbyPlayers == 0 then
                _data.isHost = "HOST"
                _data.ready = 1
            end
            table.insert(serverArena.lobbyPlayers, _data)
            if serverArena.status == 1 then
                serverArena.status = 0
                serverArena.startTimer = originalGameData.startTimer
            end
            Citizen.Wait(200)
            TriggerClientEvent('BloodBowl.UpdateArenaData', -1, serverArena)
        end
    end
end)

RegisterNetEvent('BloodBowl.PlayerClosedMainMenu')
AddEventHandler('BloodBowl.PlayerClosedMainMenu', function(_isBot)
    local src = source
    local _name = GetPlayerName(src)
    if _isBot ~= nil and _isBot ~= false then
        src = tonumber(_isBot)
        _name = "Bot "..src..""
    end
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
                serverArena.startTimer = originalGameData.startTimer
            end
            --serverArena.lobbyPlayers[myPlace] = nil
            table.remove(serverArena.lobbyPlayers, myPlace)
            TriggerClientEvent('BloodBowl.UpdateArenaData', -1, serverArena)
        end
    end
end)

AddEventHandler('BloodBowl.StartGame', function()
    if serverArena.status == 1 and serverArena.startTimer <= 0 then
        serverArena.status = 2
        local _pData = {id = 0, name = "PlayerName", score = 30, checkpointsUsed = 0, repairsUsed = 0, finishedIntro = false}
        for i,k in pairs(serverArena.lobbyPlayers) do
            serverArena.activePlayers[i] = {id = 0, name = "PlayerName", score = 30, checkpointsUsed = 0, repairsUsed = 0, finishedIntro = false}
            serverArena.activePlayers[i].name = k.name
            serverArena.activePlayers[i].id = tonumber(k.id)
            print(serverArena.activePlayers[i].id)
        end
        serverArena.lobbyPlayers = {}
        local rows = 1
        for i,k in pairs(serverArena.activePlayers) do
            local ped = GetPlayerPed(tonumber(k.id))
            FreezeEntityPosition(ped, true)
            SetEntityCoords(ped, arenaCoords['insideArena'].x, arenaCoords['insideArena'].y, arenaCoords['insideArena'].z, false, false, false, false)
            setPlayerInArena(k.id)
            gameCars[rows] = CreateArenaVehicle("dominator6", spawnCoords[rows].x, spawnCoords[rows].y, spawnCoords[rows].z, spawnCoords[rows].h, math.random(1,128), math.random(1,128), false, true)
            FreezeEntityPosition(gameCars[rows], true)
            serverArena.activePlayers[i].carID = gameCars[rows]
            while not DoesEntityExist(gameCars[rows]) do
                Citizen.Wait(10)
            end
            gameCopilots[rows] = CreateCopilot(gameCars[rows], spawnCoords[rows], 0)
            --SetPedIntoVehicle(ped, gameCars[rows], -1)
            --FreezeEntityPosition(gameCars[rows], true)
            rows = rows + 1
            TriggerClientEvent('BloodBowl.StartIntro', tonumber(k.id), serverArena.type)
            TriggerClientEvent('BloodBowl.StartClientGameLoop', tonumber(k.id))
        end
        --[[if rows < 9 then --bots
            for i=0, 9-rows do
                gameCars[rows] = CreateArenaVehicle("deviant", spawnCoords[rows].x, spawnCoords[rows].y, spawnCoords[rows].z, spawnCoords[rows].h, math.random(1,128), math.random(1,128), false, true)
                gameCopilots[rows] = CreateCopilot(spawnCoords[rows])
                SetPedIntoVehicle(gameCopilots[rows], gameCars[rows], 0)
                FreezeEntityPosition(gameCars[rows], true)
                rows = rows + 1
            end
        end]]
        local gameID = serverArena.gameData.gameID
        while serverArena.status == 2 and gameID == serverArena.gameData.gameID do --wait for everyone to watch the intro..
            local allReady = true
            for i,k in pairs(serverArena.activePlayers) do
                if k.finishedIntro == false then
                    allReady = false
                end
            end
            if allReady == true then
                serverArena.gameData.isEveryoneReady = true
                TriggerClientEvent('BloodBowl.UpdateArenaData', -1, serverArena)
                break
            end
            Citizen.Wait(200) --we are running a loop here, so checking it every frame might not be that good of an ideea.
        end

        local carsForClient = {}
        local copilotsForClient = {}
        for i,k in pairs(gameCars) do
            carsForClient[i] = NetworkGetNetworkIdFromEntity(k)
        end
        for i,k in pairs(gameCopilots) do
            copilotsForClient[i] = NetworkGetNetworkIdFromEntity(k)
        end
        local rows = 1
        for i,k in pairs(serverArena.activePlayers) do
            local ped = GetPlayerPed(tonumber(k.id))
            FreezeEntityPosition(ped, false)
            SetPedIntoVehicle(ped, gameCars[rows], -1)
            rows = rows +1
            TriggerClientEvent("cS.Countdown", tonumber(k.id), 0, 150, 200, 5, true)
            TriggerClientEvent('BloodBowl.GiveEntitiesToPlayers',tonumber(k.id), carsForClient, copilotsForClient)
        end

        Citizen.Wait(5000)

        for i,k in pairs(gameCars) do
            FreezeEntityPosition(k, false)
        end

        while serverArena.status == 2 and gameID == serverArena.gameData.gameID do --main game loop. Removes one point every second.
            if serverArena.type == 0 then
                --todo
                local _stilActive = 0
                for i,k in pairs(serverArena.activePlayers) do
                    if k.score > 0 then
                        if k.score >= 100 then
                            serverArena.status = 3 --finish the game
                            break
                        else
                            TriggerClientEvent('BloodBowl.Show_UI_Element',tonumber(k.id), "caption", "Your score: ~r~"..(k.score - 1).."~s~ / "..serverArena.gameData.maxPoints..".", 1005)
                            serverArena.activePlayers[i].score = serverArena.activePlayers[i].score - 1
                        end
                        _stilActive = _stilActive + 1
                    else
                        --fail state here. Remove player from active group to spectating
                        TriggerClientEvent('BloodBowl.DisableMyVehicle', tonumber(k.id))
                        serverArena.spectatingPlayers[i] = serverArena.activePlayers[i]
                        serverArena.activePlayers[i] = nil
                    end
                end
                if _stilActive == 0 then
                    serverArena.status = 3 --finish the game
                    break
                end
            end
            Citizen.Wait(1000)
        end

        local _activeTable = { --second slide. You can add as many "stats" as you want. They will appear from botton to top, so keep that in mind.
            --{stat = "CritteR", value = "~y~1st Place~s~"},
            --{stat = "NTT", value = "~w~2nd Place~s~"},
        }
        local row_ = 1
        for k,v in spairs(serverArena.activePlayers, function(t,a,b) return t[b].checkpointsUsed < t[a].checkpointsUsed end) do
            --print(k,v.checkpointsUsed)
            if row_ == 1 then
                _activeTable[row_] = {stat = v.name, value = "~y~"..row_..". "..v.score.." Remaining score~s~"}
            elseif row_ == 2 then
                _activeTable[row_] = {stat = v.name, value = "~w~"..row_..". "..v.score.." Remaining score~s~"}
            elseif row_ == 3 then
                _activeTable[row_] = {stat = v.name, value = "~r~"..row_..". "..v.score.." Remaining score~s~"}
            else
                _activeTable[row_] = {stat = v.name, value = row_..". "..v.score.." Remaining score~s~"}
            end
            row_ = row_ + 1
        end

        for i,k in pairs(serverArena.activePlayers) do
            local _initialText = { --first slide. Consists of 3 text lines.
                missionTextLabel = "BLOOD BOWL: ORIGINAL", 
                passFailTextLabel = "WINNER!",
                messageLabel = "",
            }

            if k.score < 100 then
                _initialText.passFailTextLabel = "LOSER!"
            end
            TriggerClientEvent("BloodBowl.FinaleUI", tonumber(k.id), _initialText, _activeTable, {startMoney = 0, finishMoney = 0}, {xpGained = 0}, (1 + #_activeTable * 1.5 + 2), true)
        end
        for i,k in pairs(serverArena.spectatingPlayers) do
            local _initialText = { --first slide. Consists of 3 text lines.
                missionTextLabel = "BLOOD BOWL: ORIGINAL", 
                passFailTextLabel = "GAME OVER!",
                messageLabel = "",
            }
            TriggerClientEvent("BloodBowl.FinaleUI", tonumber(k.id), _initialText, _activeTable, {startMoney = 0, finishMoney = 0}, {xpGained = 0}, (1 + #_activeTable * 1.5 + 2), true)
        end

        Citizen.Wait(10000) --wait 10 seconds, then restart arena.
        forceRestartArena(false, true, false, 0, 0)
    end
end)

RegisterNetEvent('BloodBowl.FinishedIntro')
AddEventHandler('BloodBowl.FinishedIntro', function()
    local src = source
    if serverArena.status == 2 and GetPlayerInArenaValue(src) == serverArena.gameData.gameID then
        if serverArena.gameData.isEveryoneReady == false then
            for i,k in pairs(serverArena.activePlayers) do
                if tonumber(k.id) == src then
                    serverArena.activePlayers[i].finishedIntro = true
                    print('updated intro')
                    TriggerClientEvent('BloodBowl.UpdateArenaData', -1, serverArena)
                end
            end
        end
    end
end)

RegisterNetEvent('BloodBowl.CheckpointReached')
AddEventHandler('BloodBowl.CheckpointReached', function(_type)
    local src = source
    if serverArena.status == 2 then
        if GetPlayerInArenaValue(src) == serverArena.gameData.gameID then
            for i,k in pairs(serverArena.activePlayers) do
                if k.id == src then
                    local pedCoords = GetEntityCoords(GetPlayerPed(src))
                    if _type == "points" then
                        local dist = #(vector3(originalPointsCoords[serverArena.gameData.cpSpot].x, originalPointsCoords[serverArena.gameData.cpSpot].y, originalPointsCoords[serverArena.gameData.cpSpot].z) - pedCoords)
                        if dist <= 7.0 then
                            serverArena.activePlayers[i].score = serverArena.activePlayers[i].score + 30
                            local lastSpot = serverArena.gameData.cpSpot
                            serverArena.gameData.cpSpot = math.random(1, #originalPointsCoords)
                            while lastSpot == serverArena.gameData.cpSpot do --making sure we don't spawn the same cp again
                                serverArena.gameData.cpSpot = math.random(1, #originalPointsCoords)
                            end
                            TriggerClientEvent('BloodBowl.Show_UI_Element', src, "banner", "small", "+30 POINTS", "", 6, 5, true)
                            TriggerClientEvent('BloodBowl.UpdateArenaData', -1, serverArena)
                        end
                    elseif _type == "repair" then
                        local dist = #(vector3(originalRepairCoords[serverArena.gameData.repairSpot].x, originalRepairCoords[serverArena.gameData.repairSpot].y, originalRepairCoords[serverArena.gameData.repairSpot].z) - pedCoords)
                        if dist <= 7.0 then
                            local lastSpot = serverArena.gameData.repairSpot
                            serverArena.gameData.repairSpot = math.random(1, #originalRepairCoords)
                            while lastSpot == serverArena.gameData.repairSpot do --making sure we don't spawn the same cp again
                                serverArena.gameData.repairSpot = math.random(1, #originalRepairCoords)
                            end
                            SetVehicleBodyHealth(serverArena.activePlayers[src].carID, 1000.0)
                            TriggerClientEvent('BloodBowl.Show_UI_Element', src, "banner", "small", "VEHICLE REPAIRED", "", 11, 5, true)
                            TriggerClientEvent('BloodBowl.UpdateArenaData', -1, serverArena)
                        end
                    end
                    break
                end
            end
        end
    end
end)


RegisterNetEvent('BloodBowl.RequestInitialArenaData')
AddEventHandler('BloodBowl.RequestInitialArenaData', function()
    local src = source
    TriggerClientEvent('BloodBowl.UpdateArenaData', src, serverArena)
end)

function setPlayerInArena(_pID)
    for i,k in pairs(serverPlayers) do -- WHY DOESN'T THIS PIECE OF SHIT TABLE WORK OTHERWISE?????!?!?!?!?!
        if k.name == GetPlayerName(tonumber(_pID)) then
            serverPlayers[i].inArena = serverArena.gameData.gameID
        end
    end
    --serverPlayers[tonumber(_pID)].inArena = serverArena.gameData.gameID
end

function GetPlayerInArenaValue(_pID)
    local data = -2
    for i,k in pairs(serverPlayers) do -- WHY DOESN'T THIS PIECE OF SHIT TABLE WORK OTHERWISE?????!?!?!?!?!
        if k.name == GetPlayerName(tonumber(_pID)) then
            data = k.inArena 
            break
        end
    end
    return data
end

RegisterCommand('forceUpdate', function(source, args)
    TriggerClientEvent('BloodBowl.UpdateArenaData', -1, serverArena)
end)

RegisterCommand('joinbot', function(source, args)
    local _botID = nil
    if args[1] ~= nil and tonumber(args[1]) ~= nil then
        _botID = tonumber(args[1])
        TriggerEvent('BloodBowl.PlayerOpenedMainMenu', _botID)
        print('bot '.._botID..' joined the arena')
    else
        print('invalid bot id')
    end
end)

RegisterCommand('leavebot', function(source, args)
    local _botID = nil
    if args[1] ~= nil and tonumber(args[1]) ~= nil then
        _botID = tonumber(args[1])
        TriggerEvent('BloodBowl.PlayerClosedMainMenu', _botID)
        print('bot '.._botID..' left the arena')
    else
        print('invalid bot id')
    end
end)

RegisterCommand('readybot', function(source, args)
    local _botID = nil
    if args[1] ~= nil and tonumber(args[1]) ~= nil then
        _botID = tonumber(args[1])
        TriggerEvent('BloodBowl.SetReady', true, _botID)
        print('bot '.._botID..' toggled ready')
    else
        print('invalid bot id')
    end
end)