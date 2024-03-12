local IneractionMenu = exports['interactionMenu']
local buying = false

local function loadAnimDict(animDict)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end
end

local function moveToPosition(ped, position, heading)
    if not IsEntityAtCoord(ped, position.x, position.y, position.z, 0.1, 0.1, 0.1, false, true, 0) then
        TaskGoStraightToCoord(ped, position.x, position.y, position.z, 1.0, 20000, heading, 0.1)
        while not IsEntityAtCoord(ped, position.x, position.y, position.z, 0.1, 0.1, 0.1, false, true, 0) do
            Citizen.Wait(1000)
        end
    end
end

local function playAnimation(ped, animDict, animName)
    loadAnimDict(animDict)
    TaskPlayAnim(ped, animDict, animName, 8.0, 5.0, -1, 1, 1, false, false, false)
    Citizen.Wait(4500)
    ClearPedTasks(ped)
    RemoveAnimDict(animDict)
end

local function playAmbientAudio()
    RequestAmbientAudioBank("VENDING_MACHINE", false)
    HintAmbientAudioBank("VENDING_MACHINE", 0)
end

local function vendingAnimation(entity)
    local ped = PlayerPedId()
    local position = GetOffsetFromEntityInWorldCoords(entity, 0.0, -0.97, 0.05)
    local heading = GetEntityHeading(entity)
    buying = true

    TaskTurnPedToFaceEntity(ped, entity, -1)
    moveToPosition(ped, position, heading)
    TaskTurnPedToFaceEntity(ped, entity, -1)
    Citizen.Wait(1000)

    playAmbientAudio()
    playAnimation(ped, Config.animations.dispense[1], Config.animations.dispense[2])

    ReleaseAmbientAudioBank()
    buying = false
end

local function replacePrice(inputString, price)
    return inputString:gsub("%%price%%", tostring(price))
end

local function ox_target()
    for vendingMachineName, data in pairs(Config.machines) do
        local options = {}

        for index, value in pairs(data.items) do
            local i = #options + 1
            options[i] = {
                label = replacePrice(value.label, value.price),
                icon = value.icon or 'fa-solid fa-bottle-water',
            }

            if value.price and value.name then
                options[i].onSelect = function(d)
                    if buying then return end
                    vendingAnimation(d.entity)
                    TriggerServerEvent('keep-vendingMachines:server:buy', vendingMachineName, value.name)
                end
            end
        end

        exports.ox_target:addModel(joaat(data.model), options)
    end
end

local function qb_target()
    for vendingMachineName, data in pairs(Config.machines) do
        local options = {}

        for index, value in pairs(data.items) do
            local i = #options + 1
            options[i] = {
                label = replacePrice(value.label, value.price),
                icon = value.icon or 'fa-solid fa-bottle-water',
            }

            if value.price and value.name then
                options[i].action = function(entity)
                    if buying then return end
                    vendingAnimation(entity)
                    TriggerServerEvent('keep-vendingMachines:server:buy', vendingMachineName, value.name)
                end
            end
        end

        exports['qb-target']:AddTargetModel(joaat(data.model), {
            options = options,
            distance = 2.5,
        })
    end
end

local function interactionMenu()
    for vendingMachineName, data in pairs(Config.machines) do
        local options = {}

        options[1] = {
            label = 'Buy',
        }

        for index, value in pairs(data.items) do
            local i = #options + 1
            options[i] = {
                label = replacePrice(value.label, value.price),
                icon = value.icon or 'fa-solid fa-bottle-water',
            }

            if value.price and value.name then
                options[i].action = {
                    type = 'sync',
                    func = function(entity)
                        if buying then return end
                        vendingAnimation(entity)
                        TriggerServerEvent('keep-vendingMachines:server:buy', vendingMachineName, value.name)
                    end
                }
            end
        end

        IneractionMenu:Create {
            model = joaat(data.model),
            offset = data.offset or vec3(0, 0, 0),
            maxDistance = 1.3,
            indicator = {
                prompt   = 'E',
                keyPress = {
                    padIndex = 0,
                    control = 38
                },
            },
            options = options
        }
    end
end

CreateThread(function()
    Wait(100)

    if Config.target == 'ox_target' then
        ox_target()
    elseif Config.target == 'qb-target' then
        qb_target()
    elseif Config.target == 'interactionMenu' then
        interactionMenu()
    end
end)
