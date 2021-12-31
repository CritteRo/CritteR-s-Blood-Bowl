
outsideScaleform = 0
outsideScaleformData = {
    name = "Blood Bowl",
    description = "Enter Arena",
    playersReady = 6,
    rp = 0, --if set to 0, it will need a restart to work again.
    cash = 0, --if set to 0, it will need a restart to work again.
    belowMessage = "Game in Progress",
}

CreateThread(function()
    local couldSeeMarkerBefore = false
    outsideScaleform = Scaleform.Request('MP_MISSION_NAME_FREEMODE')
    Scaleform.CallFunction(outsideScaleform, false, "SET_MISSION_INFO", outsideScaleformData.description, outsideScaleformData.name, "", '', outsideScaleformData.belowMessage, false, " "..outsideScaleformData.playersReady, outsideScaleformData.rp, outsideScaleformData.cash,"")
    TriggerEvent('bloodBowl.GenerateTextEntries')
    setCheckpoint("outside", 47, arenaCoords['outsideArena'].x, arenaCoords['outsideArena'].y, arenaCoords['outsideArena'].z, 0.0,0.0,0.0, arenaCoords['outsideArena'].range, 255, 255, 190, 230)
    while true do --looking for the outside marker.
        local canSeeTheMarker = false
        local insideThemarker = false
        local ped = PlayerPedId()
        local range = arenaCoords['outsideArena'].range
        
        local dist = #(vector3(arenaCoords['outsideArena'].x,arenaCoords['outsideArena'].y,arenaCoords['outsideArena'].z) - GetEntityCoords(ped))
        if dist <= range-5 then
            insideThemarker = true
            canSeeTheMarker = true
        elseif dist <= range + 100 then
            canSeeTheMarker = true
        else
            Wait(4000)
        end
        if canSeeTheMarker then
            --show checkpoint scaleform here. Also show the Alert that tells you to press a button. AANNNDDDD handle the button press.
            if not IsPauseMenuActive() then
                local camcoord = GetFinalRenderedCamRot(2)
                DrawScaleformMovie_3dSolid(outsideScaleform, arenaCoords['outsideArena'].x, arenaCoords['outsideArena'].y, arenaCoords['outsideArena'].z+3, camcoord, 1.0, 1.0, 6.0, 6.0, 6.0, 100)
                if insideThemarker then
                    alert(GetLabelText('CBB_ALERT_OPEN_OUTSIDE_MENU'))
                    if IsControlJustReleased(0, 23) then
                        ShowMainMenu(arenaData, true)
                    end
                end
            end

            if not couldSeeMarkerBefore then
                Scaleform.CallFunction(outsideScaleform, false, "SET_MISSION_INFO", outsideScaleformData.description, outsideScaleformData.name, "", '', outsideScaleformData.belowMessage, false, " "..outsideScaleformData.playersReady, outsideScaleformData.rp, outsideScaleformData.cash,"")
            end
        else
            couldSeeMarkerBefore = false
        end
        Wait(0)
    end
end)

AddEventHandler('bloodBowl.UpdateOutsidePanel', function(_data)
    if _data.playersReady ~= nil and type(_data.playersReady) == "number" then
        outsideScaleformData.playersReady = _data.playersReady
    end
    if _data.rp ~= nil and type(_data.rp) == "number" then
        outsideScaleformData.rp = _data.rp
    end
    if _data.cash ~= nil and type(_data.cash) == "number" then
        outsideScaleformData.cash = _data.cash
    end
    if _data.belowMessage ~= nil and type(_data.belowMessage) == "string" then
        outsideScaleformData.belowMessage = _data.belowMessage
    end
    if _data.name ~= nil and type(_data.name) == "string" then
        outsideScaleformData.name = _data.name
    end
    if _data.description ~= nil and type(_data.description) == "string" then
        outsideScaleformData.description = _data.description
    end

    outsideScaleform = Scaleform.Request('MP_MISSION_NAME_FREEMODE')
    Scaleform.CallFunction(outsideScaleform, false, "SET_MISSION_INFO", outsideScaleformData.description, outsideScaleformData.name, "", '', outsideScaleformData.belowMessage, false, " "..outsideScaleformData.playersReady, outsideScaleformData.rp, outsideScaleformData.cash,"")
end)
