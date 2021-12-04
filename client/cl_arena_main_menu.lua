isMenuShowing = false

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
    local allReady = true
    for i,k in pairs(_data.lobbyPlayers) do
        print(k.id.." / "..GetPlayerServerId(PlayerId()))
        if k.id == GetPlayerServerId(PlayerId()) then --if it's me!
            myLobbyId = i
        end
        if k.ready == 0 then
            allReady = false
        end
        TriggerEvent('lobbymenu:AddPlayer', 'BloodBowl.MainMenu.main', k.name, k.isHost, statusIdToUI[k.ready][1], 0, 0, true, statusIdToUI[k.ready][2], statusIdToUI[k.ready][2], true)
    end

    if myLobbyId ~= -1 then
        if _data.lobbyPlayers[myLobbyId].isHost == "HOST" then
            TriggerEvent('lobbymenu:AddButton', 'BloodBowl.MainMenu.main', {button = "startGame", isHost = _data.lobbyPlayers[myLobbyId].isHost}, "Start Arena!", "", false, 0, "BloodBowl.Main.Menu.Button.Used")
            if allReady == true and #_data.lobbyPlayers >= 3 then
                TriggerEvent('lobbymenu:SetTooltipMessage', 'BloodBowl.MainMenu.main', GetLabelText('CBB_MENU_ALERT_START_GAME_UNLOCKED'))
            elseif allReady == true and #_data.lobbyPlayers < 3 then
                TriggerEvent('lobbymenu:SetTooltipMessage', 'BloodBowl.MainMenu.main', GetLabelText('CBB_MENU_ALERT_START_GAME_LOCKED_2'))
            else
                TriggerEvent('lobbymenu:SetTooltipMessage', 'BloodBowl.MainMenu.main', GetLabelText('CBB_MENU_ALERT_START_GAME_LOCKED_1'))
            end
        else
            if _data.lobbyPlayers[myLobbyId].ready == 0 then
                TriggerEvent('lobbymenu:AddButton', 'BloodBowl.MainMenu.main', {button = "ready", isHost = _data.lobbyPlayers[myLobbyId].isHost}, "I am ready!", "", false, 0, "BloodBowl.Main.Menu.Button.Used")
                TriggerEvent('lobbymenu:SetTooltipMessage', 'BloodBowl.MainMenu.main', GetLabelText('CBB_MENU_ALERT_YOU_NOT_READY'))
            else
                TriggerEvent('lobbymenu:AddButton', 'BloodBowl.MainMenu.main', {button = "notReady", isHost = _data.lobbyPlayers[myLobbyId].isHost}, "I am NOT ready!", "", false, 0, "BloodBowl.Main.Menu.Button.Used")
                TriggerEvent('lobbymenu:SetTooltipMessage', 'BloodBowl.MainMenu.main', GetLabelText('CBB_MENU_ALERT_YOU_READY'))
            end
        end
    else
        print('else')
    end

    if _data.status == 1 then
        TriggerEvent('lobbymenu:SetTooltipMessage', 'BloodBowl.MainMenu.main', string.format(GetLabelText('CBB_MENU_ALERT_START_GAME_COUNTDOWN'), _data.startTimer))
    end

    TriggerEvent('lobbymenu:AddButton', 'BloodBowl.MainMenu.main', {button = "exit", isHost = 'na'}, "Exit", "", false, 0, "BloodBowl.Main.Menu.Button.Used")

    if _actuallyOpen == true then
        TriggerEvent('lobbymenu:OpenMenu', 'BloodBowl.MainMenu.main', true)
    end
end

AddEventHandler('lobbymenu:OpenMenu', function(_id, _unused)
    if _id == 'BloodBowl.MainMenu.main' then
        if isMenuShowing == false then
            isMenuShowing = true
            print('meme')
            Citizen.Wait(200)
            TriggerServerEvent('BloodBowl.PlayerOpenedMainMenu')
        end
    end
end)

AddEventHandler('lobbymenu:CloseMenu', function()
    if exports['critLobby']:LobbyMenuGetActiveMenu() == 'BloodBowl.MainMenu.main' then
        print('closed1')
        if isMenuShowing == true then
            isMenuShowing = false
            TriggerServerEvent('BloodBowl.PlayerClosedMainMenu')
        end
    end
end)

AddEventHandler("BloodBowl.Main.Menu.Button.Used", function(_data)
    local _buttonID = _data.button
    local _isHost = _data.isHost
    if _buttonID == 'ready' then
        TriggerServerEvent('BloodBowl.SetReady')
    elseif _buttonID == 'notReady' then
        TriggerServerEvent('BloodBowl.SetReady')
    elseif _buttonID == 'startGame' then
        if _isHost == "HOST" and #arenaData.lobbyPlayers >= 1 then
            TriggerServerEvent('BloodBowl.StartGameCountdown')
        end
    elseif _buttonID == 'exit' then
        TriggerEvent('lobbymenu:CloseMenu')
    end
end)