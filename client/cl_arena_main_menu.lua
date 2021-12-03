function ShowMainMenu()
    TriggerEvent('lobbymenu:CreateMenu', 'BloodBowl.MainMenu.main', "Blood Bowl", "Main Menu.", "MENU", "PLAYERS", "DETAILS")
    TriggerEvent('lobbymenu:SetHeaderDetails', 'BloodBowl.MainMenu.main', true, true, 2, 6, 0)
    TriggerEvent('lobbymenu:SetDetailsTitle', 'BloodBowl.MainMenu.main', "Details Title", 'textureDirectory', 'textureName')
    TriggerEvent('lobbymenu:SetTextBoxToColumn', 'BloodBowl.MainMenu.main', 2, "Blood Bowl", "This should work as a description of the game mode, or maybe the user might want to add stats here, idk.", "")

    TriggerEvent('lobbymenu:SetHeaderAlert', 'BloodBowl.MainMenu.main', 0, GetLabelText('CBB_MENU_ALERT_YOU_NOT_READY'))
    TriggerEvent('lobbymenu:SetHeaderAlert', 'BloodBowl.MainMenu.main', 1, string.format(GetLabelText('CBB_MENU_ALERT_OTHERS_READY'), 1,5))

    TriggerEvent('lobbymenu:AddButton', 'BloodBowl.MainMenu.main', {}, "Exit", "", false, 0, "event")

    TriggerEvent('lobbymenu:OpenMenu', 'BloodBowl.MainMenu.main', true)
end