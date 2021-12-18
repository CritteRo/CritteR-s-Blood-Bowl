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
blip1 = 0
blip2 = 0

function setCheckpoint(_purpose, _type, _x1, _y1, _z1, _x2, _y2, _z2, _radious, _r, _g, _b, _a)
    if _purpose == "outside" then
        DeleteCheckpoint(outsidecheckpoint)
        outsidecheckpoint = CreateCheckpoint(_type, _x1, _y1, _z1, _x2, _y2, _z2, _radious, _r, _g, _b, _a, 0)
        SetCheckpointCylinderHeight(outsidecheckpoint, 3.01, 3.01, 3.01)
    elseif _purpose == "points" then
        DeleteCheckpoint(pointcheckpoint)
        pointcheckpoint = CreateCheckpoint(_type, _x1, _y1, _z1, _x2, _y2, _z2, _radious, _r, _g, _b, _a, 0)
        SetCheckpointCylinderHeight(pointcheckpoint, 3.01, 10.01, 10.01)
        setPointsBlip(_x1, _y1, _z1, "Points")
    elseif _purpose == "repair" then
        DeleteCheckpoint(repaircheckpoint)
        repaircheckpoint = CreateCheckpoint(_type, _x1, _y1, _z1, _x2, _y2, _z2, _radious, _r, _g, _b, _a, 0)
        SetCheckpointCylinderHeight(repaircheckpoint, 3.01, 10.01, 10.01)
        setRepairBlip(_x1, _y1, _z1, "Repair")
    end
end

function setEntityBlip(_entity, _name)
    --RemoveBlip(entityBlip)
    entityBlip = AddBlipForEntity(_entity)
    SetBlipSprite(entityBlip, 662)
    SetBlipDisplay(entityBlip, 4)
    SetBlipColour(entityBlip, 1)
    SetBlipScale(entityBlip, 0.6)
    SetBlipAsShortRange(entityBlip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(_name)
    EndTextCommandSetBlipName(entityBlip)
    SetBlipRoute(entityBlip, false)
    SetBlipRouteColour(entityBlip, 26)
end

function setPointsBlip(_x, _y, _z, _name)
    RemoveBlip(blip1)
    blip1 = AddBlipForCoord(_x, _y, _z)
    SetBlipSprite(blip1, 641)
    SetBlipDisplay(blip1, 4)
    SetBlipScale(blip1, 0.9)
    SetBlipColour(blip1, 5)
    SetBlipAsShortRange(blip1, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(_name)
    EndTextCommandSetBlipName(blip1)
end

function setRepairBlip(_x, _y, _z, _name)
    RemoveBlip(blip2)
    blip2 = AddBlipForCoord(_x, _y, _z)
    SetBlipSprite(blip2, 643)
    SetBlipDisplay(blip2, 4)
    SetBlipScale(blip2, 0.9)
    SetBlipColour(blip2, 3)
    SetBlipAsShortRange(blip2, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(_name)
    EndTextCommandSetBlipName(blip2)
end