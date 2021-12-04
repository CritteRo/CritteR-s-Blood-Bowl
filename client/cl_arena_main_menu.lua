function ShowMainMenu(_data)
    TriggerEvent('lobbymenu:CreateMenu', 'BloodBowl.MainMenu.main', "Blood Bowl", "Main Lobby.", "MENU", "PLAYERS", "DETAILS")
    TriggerEvent('lobbymenu:SetHeaderDetails', 'BloodBowl.MainMenu.main', true, true, 2, 6, 0)

    if _data.type == 0 then
        TriggerEvent('lobbymenu:SetDetailsTitle', 'BloodBowl.MainMenu.main', "Blood Bowl: Original", 'textureDirectory', 'textureName')
        TriggerEvent('lobbymenu:AddDetailsRow', 'BloodBowl.MainMenu.main', "Starting Points", 30)
        TriggerEvent('lobbymenu:AddDetailsRow', 'BloodBowl.MainMenu.main', "Target Points", 100)
        TriggerEvent('lobbymenu:AddDetailsRow', 'BloodBowl.MainMenu.main', "Lose:", "0 Points")
        TriggerEvent('lobbymenu:AddDetailsRow', 'BloodBowl.MainMenu.main', "1 point is removed every second.", "")
        TriggerEvent('lobbymenu:AddDetailsRow', 'BloodBowl.MainMenu.main', "~r~Red Markers~s~ gives 10 points", "")
        TriggerEvent('lobbymenu:AddDetailsRow', 'BloodBowl.MainMenu.main', "~b~Blue Markers~s~ repairs your vehicle.", "")
    elseif _data.type == 1 then
        TriggerEvent('lobbymenu:SetDetailsTitle', 'BloodBowl.MainMenu.main', "Blood Bowl: ~g~Infected~s~", 'textureDirectory', 'textureName')
        TriggerEvent('lobbymenu:AddDetailsRow', 'BloodBowl.MainMenu.main', "Two teams: ~g~Infected~s~ and ~b~Survivors~s~", "")
        TriggerEvent('lobbymenu:AddDetailsRow', 'BloodBowl.MainMenu.main', "One person is ~g~infected at the start.", "")
        TriggerEvent('lobbymenu:AddDetailsRow', 'BloodBowl.MainMenu.main', "Game ends when everyone is infected.", "")
        TriggerEvent('lobbymenu:AddDetailsRow', 'BloodBowl.MainMenu.main', "You infect other by tapping them.", "")
        TriggerEvent('lobbymenu:AddDetailsRow', 'BloodBowl.MainMenu.main', "Longest lasting survivor wins.", "")
    end
    --TriggerEvent('lobbymenu:SetTextBoxToColumn', 'BloodBowl.MainMenu.main', 2, "Blood Bowl", "This should work as a description of the game mode, or maybe the user might want to add stats here, idk.", "")

    TriggerEvent('lobbymenu:SetHeaderAlert', 'BloodBowl.MainMenu.main', 1, string.format(GetLabelText('CBB_MENU_ALERT_PLAYERS'), #_data.lobbyPlayers,_data.maxPlayers))

    TriggerEvent('lobbymenu:AddButton', 'BloodBowl.MainMenu.main', {}, "Exit", "", false, 0, "event")

    TriggerEvent('lobbymenu:OpenMenu', 'BloodBowl.MainMenu.main', true)
end