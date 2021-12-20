function notify(string, colID)
    if colID ~= nil then
        ThefeedSetNextPostBackgroundColor(colID)
    end
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(string)
    EndTextCommandThefeedPostTicker(true, true)
end

function caption(text, ms)
    BeginTextCommandPrint("string")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandPrint(ms, 1)
end

function alert(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0,0,1,-1)
end

ScaleformVarious = 0
ScaleformEndScreen = 0

isBannerShowing = false
bannerTimeLeft = 0

function BuildBigBanner(_title, _subtitle, _color)
    local scaleform = Scaleform.Request('MP_BIG_MESSAGE_FREEMODE')

    Scaleform.CallFunction(scaleform, false, "SHOW_SHARD_CENTERED_MP_MESSAGE")
    Scaleform.CallFunction(scaleform, false, "SHARD_SET_TEXT", _title, _subtitle, _color)

    return scaleform
end

function BuildSmallBanner(_title, _subtitle, _bannerColor)
    local scaleform = Scaleform.Request('MIDSIZED_MESSAGE')
    Scaleform.CallFunction(scaleform, false, "SHOW_COND_SHARD_MESSAGE", _title, _subtitle, _bannerColor, true)
    return scaleform
end

function ShowBusySpinner(_text)
    BeginTextCommandBusyspinnerOn("STRING")
    AddTextComponentSubstringPlayerName(_text)
    EndTextCommandBusyspinnerOn(1)
end

function BuildAndShowCreditsBlock(_role, _name, _x, _y)
    Citizen.CreateThread(function()
        function drawCredits(role, name)
            local scaleform = RequestScaleformMovie("OPENING_CREDITS")
            while not HasScaleformMovieLoaded(scaleform) do
                Citizen.Wait(0)
            end
            Scaleform.CallFunction(scaleform, false, "TEST_CREDIT_BLOCK", role, name, 'left', 0.0, 50.0, 1, 5, 10, 10)
            return scaleform
        end
        local scale = drawCredits(_role, _name)
        while showCreditsBanner do
            Citizen.Wait(1)
            DrawScaleformMovie(scale, _x, _y, 0.71, 0.68, 255, 255, 255, 255)
        end
    end)
end

function BuildAndShowEndScreen(ZinitialText, Ztable, Zmoney, Zxp)
    Citizen.CreateThread(function()
        function drawHeist(_initialText, _table, _money, _xp)
            local scaleform = Scaleform.Request('HEIST_CELEBRATION')
            local scaleform_bg = Scaleform.Request('HEIST_CELEBRATION_BG')
            local scaleform_fg = Scaleform.Request('HEIST_CELEBRATION_FG')

            local scaleform_list = {
                scaleform,
                scaleform_bg,
                scaleform_fg
            }

            for key, scaleform_handle in pairs(scaleform_list) do
                Scaleform.CallFunction(scaleform_handle, false, "CREATE_STAT_WALL", 1, "HUD_COLOUR_BLACK", 1)
                Scaleform.CallFunction(scaleform_handle, false, "ADD_BACKGROUND_TO_WALL", 1, 80, 1)
    
                --this should be used as it's own scaleform event.
                --Scaleform.CallFunction(scaleform_handle, false, "ADD_COMPLETE_MESSAGE_TO_WALL", 1, _initialText.missionTextLabel, _initialText.passFailTextLabel, _initialText.messageLabel, true, true, true)
    
                Scaleform.CallFunction(scaleform_handle, false, "ADD_MISSION_RESULT_TO_WALL", 1, _initialText.missionTextLabel, _initialText.passFailTextLabel, _initialText.messageLabel, true, true, true)
    
                if _table[1] ~= nil then
                    Scaleform.CallFunction(scaleform_handle, false, "CREATE_STAT_TABLE", 1, 10)
    
                    for i, k in pairs(_table) do
                        Scaleform.CallFunction(scaleform_handle, false, "ADD_STAT_TO_TABLE", 1, 10, _table[i].stat, _table[i].value, true, true, false, false, 0)
                    end
    
                    Scaleform.CallFunction(scaleform_handle, false, "ADD_STAT_TABLE_TO_WALL", 1, 10)
                end
    
                if _money.startMoney ~= _money.finishMoney then
                    Scaleform.CallFunction(scaleform_handle, false, "CREATE_INCREMENTAL_CASH_ANIMATION", 1, 20)
                    Scaleform.CallFunction(scaleform_handle, false, "ADD_INCREMENTAL_CASH_WON_STEP", 1, 20, _money.startMoney, _money.finishMoney, _money.topText, _money.bottomText, _money.rightHandStat, _money.rightHandStatIcon, 0)
                    Scaleform.CallFunction(scaleform_handle, false, "ADD_INCREMENTAL_CASH_ANIMATION_TO_WALL", 1, 20)
                end
    
                if _xp.xpGained ~= 0 then
                    Scaleform.CallFunction(scaleform_handle, false, "ADD_REP_POINTS_AND_RANK_BAR_TO_WALL", 1, _xp.xpGained, _xp.xpBeforeGain, _xp.minLevelXP, _xp.maxLevelXP, _xp.currentRank, _xp.nextRank, _xp.rankTextSmall, _xp.rankTextBig)
                end
    
                Scaleform.CallFunction(scaleform_handle, false, "SHOW_STAT_WALL", 1)
                Scaleform.CallFunction(scaleform_handle, false, "createSequence", 1, 1, 1)
            end

            return scaleform, scaleform_bg, scaleform_fg
        end
        local scale, scale_bg, scale_fg = drawHeist(ZinitialText, Ztable, Zmoney, Zxp)
        while showHeistBanner do
            Citizen.Wait(1)
            DrawScaleformMovieFullscreenMasked(scale_bg, scale_fg, 255, 255, 255, 50)
            DrawScaleformMovieFullscreen(scale, 255, 255, 255, 255)
        end
        StartScreenEffect("HeistCelebToast")
    end)
end

RegisterNetEvent('BloodBowl.FinaleUI')
AddEventHandler("BloodBowl.FinaleUI", function(_initialText, _table, _money, _xp, _waitTime, _playSound)
    showHeistBanner = true
    if _playSound ~= nil and _playSound == true then
        PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 1)
    end
    BuildAndShowEndScreen(_initialText, _table, _money, _xp)
    TriggerScreenblurFadeIn(1000)
    BeginTextCommandBusyspinnerOn("STRING")
    AddTextComponentSubstringPlayerName(GetLabelText('LABEL_EXIT_ARENA'))
    EndTextCommandBusyspinnerOn(1)
    Citizen.CreateThread(function()
        Citizen.Wait(tonumber(_waitTime) * 1000)
        showHeistBanner = false
        TriggerScreenblurFadeOut(1000)
    end)
end)

RegisterNetEvent('BloodBowl.Show_UI_Element')
AddEventHandler('BloodBowl.Show_UI_Element', function(type, ...)
    local args = {...}
    if type == "notify" then
        notify(args[1], args[2])
    elseif type == "alert" then
        alert(args[1])
    elseif type == 'caption' then
        caption(args[1], args[2])
    elseif type == "banner" then --6,9
        if args[1] == 'small' then
            TriggerEvent('BloodBowl.SmallBanner', args[2], args[3], args[4], args[5], args[6])
        elseif args[1] == 'big' then
            TriggerEvent('BloodBowl.BigBanner', args[2], args[3], args[4], args[5], args[6])
        end
    end
end)

AddEventHandler("BloodBowl.BigBanner", function(_title, _subtitle, _color, _waitTime, _playSound)
    if _playSound ~= nil and _playSound == true then
        PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 1)
    end
    ScaleformVarious = BuildBigBanner(_title, _subtitle, _color)
    bannerTimeLeft = _waitTime * 100
    if isBannerShowing == false then
        isBannerShowing = true
        Citizen.CreateThread(function()
            while isBannerShowing == true do
                if bannerTimeLeft == 20 then
                    Scaleform.CallFunction(ScaleformVarious, false, "SHARD_ANIM_OUT", 2, 0.4, 0)
                end
                Citizen.Wait(1)
                bannerTimeLeft = bannerTimeLeft - 1
                if bannerTimeLeft <= 0 then
                    isBannerShowing = false
                end
                DrawScaleformMovieFullscreen(ScaleformVarious, 255, 255, 255, 255)
            end
        end)
    end
end)

AddEventHandler("BloodBowl.SmallBanner", function(_title, _subtitle, _color, _waitTime, _playSound)
    if _playSound ~= nil and _playSound == true then
        PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 1)
    end
    ScaleformVarious = BuildSmallBanner(_title, _subtitle, _color)
    bannerTimeLeft = _waitTime * 100
    if isBannerShowing == false then
        isBannerShowing = true
        Citizen.CreateThread(function()
            while isBannerShowing == true do
                if bannerTimeLeft == 20 then
                    Scaleform.CallFunction(ScaleformVarious, false, "SHARD_ANIM_OUT", 2, 0.4, 0)
                end
                Citizen.Wait(1)
                bannerTimeLeft = bannerTimeLeft - 1
                if bannerTimeLeft <= 0 then
                    isBannerShowing = false
                end
                DrawScaleformMovieFullscreen(ScaleformVarious, 255, 255, 255, 255)
            end
        end)
    end
end)

RegisterNetEvent('BloodBowl.YouAreAboutToLose')
AddEventHandler('BloodBowl.YouAreAboutToLose', function(_points)
    if _points <= 7 and _points > 3 then
        PlaySoundFrontend(-1, "5_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET", 1)
    elseif _points <= 3 then
        PlaySoundFrontend(-1, "LOOSE_MATCH", "HUD_MINI_GAME_SOUNDSET", 1)
    end
end)