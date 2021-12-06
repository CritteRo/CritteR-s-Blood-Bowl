TextEntries = {
    --{Entry_ID, Entry_Text},
    {"CBB_ALERT_OPEN_OUTSIDE_MENU", "Press ~INPUT_ENTER~ to open the ~y~Blood Bowl~s~ menu."},
    {"CBB_MENU_ALERT_YOU_NOT_READY", "You are not ready!"},
    {"CBB_MENU_ALERT_YOU_READY", "You are ready!"},
    {"CBB_MENU_ALERT_PLAYERS", "%i / %i Players"},
    {"CBB_MENU_ALERT_START_GAME_LOCKED_1", "Waiting for other to become ready..."},
    {"CBB_MENU_ALERT_START_GAME_LOCKED_2", "Not enough players to start..."},
    {"CBB_MENU_ALERT_START_GAME_UNLOCKED", "Everyone's ready. Start the game!"},
    {"CBB_MENU_ALERT_START_GAME_COUNTDOWN", "Game starts in %i seconds..."},
    {'CBB_INTRO_SKIPPING', "Skipping intro..."},
}

AddEventHandler('bloodBowl.GenerateTextEntries', function(_customEntries)
    local tbl = TextEntries
    if type(_customEntries) == "table" then
        tbl = _customEntries
    end
    for i,k in pairs(tbl) do
        AddTextEntry(k[1], k[2])
    end
end)