camCoords = {
    [0] = {
        [1] = {x1 = 2965.11, y1 = -3713.66, z1 = 208.82, rx1 = 0.0, ry1 = 0.0, h1 = 129.203, x2 = 2965.11, y2 = -3713.66, z2 = 193.45, rx2 = 0.0, ry2 = 0.0, h2 = 129.203, time = 8000},
        [2] = {x1 = 2811.518, y1 = -3720.068, z1 = 140.478,rx1 = 0.0, ry1 = 0.0, h1 = 326.296, x2 = 2811.518, y2 = -3720.068, z2 = 140.478, rx2 = 0.0, ry2 = 0.0, h2 = 42.24, time = 8000},
        [3] = {x1 = 2837.79, y1 = -3818.19, z1 = 114.71,rx1 = 0.0, ry1 = 0.0, h1 = 54.63, x2 = 2812.47, y2 = -3800.22, z2 = 114.71, rx2 = 0.0, ry2 = 0.0, h2 = 54.63, time = 10000},
        [4] = {x1 = 2698.91, y1 = -3870.83, z1 = 177.7009,rx1 = -90.0, ry1 = 0.0, h1 = 306.76, x2 = 2840.48, y2 = -3755.11, z2 = 177.7009, rx2 = -90.0, ry2 = 0.0, h2 = 309.25, time = 10000},
        [5] = {x1 = 2811.518, y1 = -3720.068, z1 = 140.478,rx1 = 0.0, ry1 = 0.0, h1 = 326.296, x2 = 2811.518, y2 = -3720.068, z2 = 140.478, rx2 = 0.0, ry2 = 0.0, h2 = 42.24, time = 8000},
        [6] = {x1 = 2837.79, y1 = -3818.19, z1 = 114.71,rx1 = 0.0, ry1 = 0.0, h1 = 54.63, x2 = 2812.47, y2 = -3800.22, z2 = 114.71, rx2 = 0.0, ry2 = 0.0, h2 = 54.63, time = 10000},
        [7] = {x1 = 2965.11, y1 = -3713.66, z1 = 208.82, rx1 = 0.0, ry1 = 0.0, h1 = 129.203, x2 = 2965.11, y2 = -3713.66, z2 = 193.45, rx2 = 0.0, ry2 = 0.0, h2 = 129.203, time = 8000},
    }
}

function showArenaIntro(_aID, _messages)
    local cams = {}
    local row = 1
    messageRow = 1
    for i,k in pairs(camCoords[_aID]) do
        if true then
            cams[row] = {
                handle = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", k.x1, k.y1, k.z1, k.rx1, k.ry1, k.h1, 70 * 1.0),
                pos = {k.x1, k.y1, k.z1},
                time = k.time,
            }
            row = row + 1
            cams[row] = {
                handle = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", k.x2, k.y2, k.z2, k.rx2, k.ry2, k.h2, 70 * 1.0),
                pos = {k.x2, k.y2, k.z2},
                time = k.time,
            }
            row = row + 1
        end
    end

    ClearFocus()
    local ped = PlayerPedId()
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)

    SetCamActive(cams[1].handle, true)
    RenderScriptCams(true, false, 0, true, false)

    for i,k in pairs(cams) do
        local _,int = math.modf(i/2)
        if int > 0 then
            SetFocusPosAndVel(cams[i].pos[1], cams[i].pos[2], cams[i].pos[3], 0.0, 0.0, 0.0)
            SetCamActiveWithInterp(cams[i+1].handle, cams[i].handle, cams[i].time, 1, 1)
            if i == 1 then
                TriggerEvent('cS.banner', '~y~Welcome to Blood Bowl!~s~', "Original gamemode.", cams[i].time/1000, true)
            else
                caption(tostring(_messages[messageRow]), cams[i].time)
                messageRow = messageRow + 1
            end
            Citizen.Wait(cams[i].time)
        end
    end
    FreezeEntityPosition(ped, false)
    SetEntityInvincible(ped, false)
    ClearFocus()
    RenderScriptCams(false, false, 0, true, false)
    for i,k in pairs(cams) do
        DestroyCam(k.handle, false)
    end
end
local testMessages = {
    [1] = "Your overall score starts at ~r~30~s~ and counts down.",
    [2] = "Drive through the ~r~red checkpoints~s~ to increase your overall score.",
    [3] = 'The ~b~blue checkpoints~s~ will repair your vehicle.',
    [4] = "The current Target Score to win the Blood Ring is 100.",
    [5] = "Get your overall score above the Target Score to win!",
    [6] = "You will lose if your overall score reaches zero.",
}

RegisterCommand('showIntro', function()
    showArenaIntro(0, testMessages)
end)