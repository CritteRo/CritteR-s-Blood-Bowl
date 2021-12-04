serverArena = { 
    status = 0, --0 = Open, waiting for players, 1 = starting, 2 = in game, 3 = ending, 4 = offline
    type = 0, --0 = original, 1 = infected, 2 = capture the flag.
    activePlayers = {}, --players alive during the round.
    spectatingPlayers = {}, --players "dead" during the round, 
    lobbyPlayers = {}, --all players, in the lobby.
    maxPlayers = 16,
    gameData = {}, --depending on the type of gamemode, this should have some values here.
}

originalGameData = {timeLeft = GetGameTimer() + 900000 --[[15 minutes]], gameID = math.random(1,999999999)}

lobbyPlayerData = {id = 0, name = "PlayerName", ready = false}
originalPlayerData = {id = 0, name = "PlayerName", score = 30}


serverPlayers = {
    [0] = {
        srcID = 0,
        name = "PlayerName",
        inArena = -1, -- -1 = false, 0 or more = gameID
        showFirstTooltip = true, --would show a tooltip that tells you about the /disable_notifications command.
        showNotifications = true --would show you notifications whenever an arena becomes active, is about to start, starts and ends.
    }
}

AddEventHandler()