local QBCore = exports['qb-core']:GetCoreObject()

-- Helper function to find an item in a vending machine
local function findItemInMachine(vendingMachine, itemName)
    for _, item in ipairs(vendingMachine.items) do
        if item.name == itemName then return item end
    end
    return nil
end

-- handle the purchase
local function handlePurchase(player, item, machineName)
    local success = false

    if player.Functions.RemoveMoney('cash', item.price, item.label .. '-vending-machine') then
        success = true
    elseif player.Functions.RemoveMoney('bank', item.price, item.label .. '-vending-machine') then
        success = true
    end

    if success then
        player.Functions.AddItem(item.name, 1, false)
    end
end

RegisterNetEvent('keep-vendingMachines:server:buy', function(machineName, itemName)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local vendingMachine = Config.machines[machineName]

    if not vendingMachine then return end

    local item = findItemInMachine(vendingMachine, itemName)

    if item then
        handlePurchase(player, item, machineName)
    end
end)
