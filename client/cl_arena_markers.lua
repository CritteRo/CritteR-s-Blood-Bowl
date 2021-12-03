local markerCoords = {
    ['outsideArena'] = {x = -265.402, y = -1912.376, z = 25.755, range = 10.05},
}

outsideScaleform = 0
outsideScaleformData = {
    name = "Blood Bowl",
    description = "Enter Arena",
    playersReady = 6,
    rp = 1, --if set to 0, it will need a restart to work again.
    cash = 1, --if set to 0, it will need a restart to work again.
    belowMessage = "Game in Progress",
}

Citizen.CreateThread(function()
    outsideScaleform = Scaleform.Request('MP_MISSION_NAME_FREEMODE')
    Scaleform.CallFunction(outsideScaleform, false, "SET_MISSION_INFO", outsideScaleformData.description, outsideScaleformData.name, "", '', outsideScaleformData.belowMessage, false, " "..outsideScaleformData.playersReady, outsideScaleformData.rp, outsideScaleformData.cash,"")
    TriggerEvent('bloodBowl.GenerateTextEntries')
    setOutsideCheckpoint(47, markerCoords['outsideArena'].x, markerCoords['outsideArena'].y, markerCoords['outsideArena'].z, 0.0,0.0,0.0, markerCoords['outsideArena'].range, 255, 255, 190, 230)
    while true do --looking for the outside marker.
        local canSeeTheMarker = false
        local insideThemarker = false
        local ped = PlayerPedId()
        local range = markerCoords['outsideArena'].range
        
        local dist = #(vector3(markerCoords['outsideArena'].x,markerCoords['outsideArena'].y,markerCoords['outsideArena'].z) - GetEntityCoords(ped))
        if dist <= range then
            insideThemarker = true
            canSeeTheMarker = true
        elseif dist <= range + 100 then
            canSeeTheMarker = true
            --Citizen.Wait(1000)
        else
            Citizen.Wait(4000)
        end
        if canSeeTheMarker == true then
            --show checkpoint scaleform here. Also show the Alert that tells you to press a button. AANNNDDDD handle the button press.
            local camcoord = GetFinalRenderedCamRot(2)
            DrawScaleformMovie_3dSolid(outsideScaleform, markerCoords['outsideArena'].x, markerCoords['outsideArena'].y, markerCoords['outsideArena'].z+3, camcoord, 1.0, 1.0, 6.0, 6.0, 6.0, 100)
            if insideThemarker == true then
                alert(GetLabelText('CBB_ALERT_OPEN_OUTSIDE_MENU'))
            end
        end
        Citizen.Wait(0)
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

RegisterCommand('panel', function()
    TriggerEvent('bloodBowl.UpdateOutsidePanel', {name = "Blood Bowl", rp = 5, cash = 5, belowMessage = "~r~Game in progress~s~", playersReady = 12})
end)