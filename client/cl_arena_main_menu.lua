function ShowMainMenu(_data, _actuallyOpen)
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
    local myLobbyId = -1
    for i,k in pairs(_data.lobbyPlayers) do
        if k.id == PlayerId() then --if it's me!
            myLobbyId = i
        end
        TriggerEvent('lobbymenu:AddPlayer', 'BloodBowl.MainMenu.main', k.name, k.isHost, statusIdToUI[k.ready][1], 0, 0, true, statusIdToUI[k.ready][2], statusIdToUI[k.ready][2], true)
    end

    if myLobbyId ~= -1 then
        if _data.lobbyPlayers[myLobbyId].isHost == true then
        end
    else
    end

    TriggerEvent('lobbymenu:AddButton', 'BloodBowl.MainMenu.main', {buttonID = "exit"}, "Exit", "", false, 0, "BloodBowl.Main.Menu.Button.Used")

    if _actuallyOpen == true then
        TriggerEvent('lobbymenu:OpenMenu', 'BloodBowl.MainMenu.main', true)
    end
end