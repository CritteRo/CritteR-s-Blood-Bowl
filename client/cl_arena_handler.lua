arenaData = { --this should be used only when 
    status = 0, --0 = Open, waiting for players, 1 = starting, 2 = in game, 3 = ending, 4 = offline
    type = 0, --0 = original, 1 = infected, 2 = capture the flag.
    activePlayers = {}, --players alive during the round.
    spectatingPlayers = {}, --players "dead" during the round, 
    lobbyPlayers = {}, --all players, in the lobby.
    maxPlayers = 16,
    gameData = {}, --depending on the type of gamemode, this should have some values here.
}

RegisterNetEvent('BloodBowl.UpdateArenaData')
AddEventHandler('BloodBowl.UpdateArenaData', function(_data)
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
        _panel.description = "Game starting.."
    end
    if arenaData.status == 4 then
        _panel.description = "Arena is offline."
    end
    if exports['critLobby']:LobbyMenuGetActiveMenu() == 'BloodBowl.MainMenu.main' then
        TriggerEvent('lobbymenu:ReloadMenu')
    end
    TriggerEvent('bloodBowl.UpdateOutsidePanel', {name = _panel.name, rp = 1, cash = 1, belowMessage = _panel.belowMessage, playersReady = _panel.playersReady, description = _panel.description})
end)