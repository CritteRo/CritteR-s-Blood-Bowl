-----------SCALEFORM UTILS----------------------------------------------
Scaleform = {}
function Scaleform.Request(scaleform)
    local scaleform_handle = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform_handle) do
        Citizen.Wait(0)
    end
    return scaleform_handle
end
function Scaleform.CallFunction(scaleform, returndata, the_function, ...)
    BeginScaleformMovieMethod(scaleform, the_function)
    local args = {...}

    if args ~= nil then
        for i = 1,#args do
            local arg_type = type(args[i])

            if arg_type == "boolean" then
                ScaleformMovieMethodAddParamBool(args[i])
            elseif arg_type == "number" then
                if not string.find(args[i], '%.') then
                    ScaleformMovieMethodAddParamInt(args[i])
                else
                    ScaleformMovieMethodAddParamFloat(args[i])
                end
            elseif arg_type == "string" then
                ScaleformMovieMethodAddParamTextureNameString(args[i])
            end
        end

        if not returndata then
            EndScaleformMovieMethod()
        else
            return EndScaleformMovieMethodReturnValue()
        end
    end
end

--------------
outsidecheckpoint = 0
repaircheckpoint = 0
pointcheckpoint = 0

function setCheckpoint(_purpose, _type, _x1, _y1, _z1, _x2, _y2, _z2, _radious, _r, _g, _b, _a)
    if _purpose == "outside" then
        DeleteCheckpoint(outsidecheckpoint)
        outsidecheckpoint = CreateCheckpoint(_type, _x1, _y1, _z1, _x2, _y2, _z2, _radious, _r, _g, _b, _a, 0)
        SetCheckpointCylinderHeight(outsidecheckpoint, 3.01, 3.01, 3.01)
    elseif _purpose == "points" then
        DeleteCheckpoint(pointcheckpoint)
        pointcheckpoint = CreateCheckpoint(_type, _x1, _y1, _z1, _x2, _y2, _z2, _radious, _r, _g, _b, _a, 0)
        SetCheckpointCylinderHeight(pointcheckpoint, 3.01, 10.01, 10.01)
    elseif _purpose == "repair" then
        DeleteCheckpoint(repaircheckpoint)
        repaircheckpoint = CreateCheckpoint(_type, _x1, _y1, _z1, _x2, _y2, _z2, _radious, _r, _g, _b, _a, 0)
        SetCheckpointCylinderHeight(repaircheckpoint, 3.01, 10.01, 10.01)
    end
end

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