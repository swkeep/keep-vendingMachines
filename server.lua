local fws = Config.framework -- framework string

local function framework()
    if fws == 'qb' then
        return exports['qb-core']:GetCoreObject()
    elseif fws == 'esx' then
        return exports['es_extended']:getSharedObject()
    end
end

local fw = framework()

local function getPlayerObject(src)
    if fws == 'qb' then
        return fw.Functions.GetPlayer(src)
    elseif fws == 'esx' then
        return fw.GetPlayerFromId(src)
    end
end

local function TakeMoney(playerObject, method, amount)
    amount = tonumber(amount)

    if fws == 'qb' then
        return playerObject.Functions.RemoveMoney(method, amount)
    elseif fws == 'esx' then
        if method == 'cash' then
            return playerObject.removeMoney(amount)
        elseif method == 'bank' then
            return playerObject.removeAccountMoney('bank', amount)
        end
    end
end

local function giveItem(src, playerObject, item, amount)
    if fws == 'qb' then
        return playerObject.Functions.AddItem(item.name, 1, false)
    elseif fws == 'esx' then
        return exports.ox_inventory:AddItem(source, item.name, amount)
    end
end

-- Helper function to find an item in a vending machine
local function findItemInMachine(vendingMachine, itemName)
    for _, item in ipairs(vendingMachine.items) do
        if item.name == itemName then return item end
    end
    return nil
end

-- handle the purchase
local function handlePurchase(src, player, item, machineName)
    local success = false

    if TakeMoney(player, 'cash', item.price) then
        success = true
    elseif TakeMoney(player, 'bank', item.price) then
        success = true
    end

    if success then
        giveItem(src, player, item, 1)
    end
end

RegisterNetEvent('keep-vendingMachines:server:buy', function(machineName, itemName)
    local src = source
    local player = getPlayerObject(src)
    local vendingMachine = Config.machines[machineName]

    if not vendingMachine then return end

    local item = findItemInMachine(vendingMachine, itemName)

    if item then
        handlePurchase(src, player, item, machineName)
    end
end)
