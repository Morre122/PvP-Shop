local playerCart = {}

local kainos = {
    weapon_combatpistol = 2500,
    weapon_pistol = 2000,
    weapon_specialcarbine = 6500,
    weapon_carbinerifle = 6000,
    weapon_pistol50 = 3500,
    weapon_machinepistol = 4000,
    weapon_smg = 6000,
    ammo_9 = 10,
    medikit = 1500,
}

RegisterNetEvent('myshop:addToCart')
AddEventHandler('myshop:addToCart', function(itemName)
    local playerId = source
    if not playerCart[playerId] then
        playerCart[playerId] = {}
    end

    if not playerCart[playerId][itemName] then
        playerCart[playerId][itemName] = 1
    else
        playerCart[playerId][itemName] = playerCart[playerId][itemName] + 1
    end

end)

RegisterNetEvent('myshop:requestCart')
AddEventHandler('myshop:requestCart', function()
    local playerId = source

    if playerCart[playerId] then
        TriggerClientEvent('myshop:receiveCart', playerId, playerCart[playerId])
    else
        TriggerClientEvent('myshop:receiveCart', playerId, {})
    end
end)

RegisterNetEvent('myshop:buyItems')
AddEventHandler('myshop:buyItems', function(paymentMethod, cart, destination)
    local playerId = source
    local player = ESX.GetPlayerFromId(playerId)

    if cart and #cart.items > 0 then
        local totalPrice = 0
        local itemsToBuy = {}

        for _, item in ipairs(cart.items) do
            local price = kainos[item.weaponName]
            if price then
                totalPrice = totalPrice + (price * item.quantity)
                table.insert(itemsToBuy, { itemName = item.weaponName, count = item.quantity })
            else
            end
        end

        if totalPrice == 0 then
            TriggerClientEvent('ox_lib:notify', playerId, {
                title = 'Parduotuvė',
                description = 'Tavo krepšelis yra tuščias!',
                type = 'error',
                position = 'top'
            })
            return
        end

        if paymentMethod == "cash" then
            if player.getMoney() >= totalPrice then
                player.removeMoney(totalPrice)
                for _, item in ipairs(itemsToBuy) do
                    if destination == 'inventory' then
                        exports.ox_inventory:AddItem(playerId, item.itemName, item.count)
                    elseif destination == 'storage' then
                        local canCarry = exports.ox_inventory:CanCarryItem({id = "sandelys1", owner = player.getIdentifier()}, item.itemName, item.count)
                        if canCarry then
                            exports.ox_inventory:AddItem({id = "sandelys1", owner = player.getIdentifier()}, item.itemName, item.count)
                        else
                            TriggerClientEvent('ox_lib:notify', playerId, {
                                title = 'Sandėlis',
                                description = 'Nėra pakankamai vietos sandėlyje!',
                                type = 'error',
                                position = 'top'
                            })
                        end
                    end
                end

                TriggerClientEvent('ox_lib:notify', playerId, {
                    title = 'Parduotuvė',
                    description = 'Pirkimas sėkmingas! Atimta ' .. totalPrice .. ' EUR',
                    type = 'success',
                    position = 'top'
                })
            else
                TriggerClientEvent('ox_lib:notify', playerId, {
                    title = 'Parduotuvė',
                    description = 'Neturi pakankamai pinigų už visus prekes!',
                    type = 'error',
                    position = 'top'
                })
            end
        elseif paymentMethod == "bank" then
            local bankBalance = player.getAccount('bank').money

            if bankBalance >= totalPrice then
                player.removeAccountMoney('bank', totalPrice)
                for _, item in ipairs(itemsToBuy) do
                    if destination == 'inventory' then
                        exports.ox_inventory:AddItem(playerId, item.itemName, item.count)
                    elseif destination == 'storage' then
                        local canCarry = exports.ox_inventory:CanCarryItem({id = "sandelys1", owner = player.getIdentifier()}, item.itemName, item.count)
                        if canCarry then
                            exports.ox_inventory:AddItem({id = "sandelys1", owner = player.getIdentifier()}, item.itemName, item.count)
                        else
                            TriggerClientEvent('ox_lib:notify', playerId, {
                                title = 'Sandėlis',
                                description = 'Nėra pakankamai vietos sandėlyje!',
                                type = 'error',
                                position = 'top'
                            })
                        end
                    end
                end

                TriggerClientEvent('ox_lib:notify', playerId, {
                    title = 'Parduotuvė',
                    description = 'Pirkimas sėkmingas! Atimta ' .. totalPrice .. ' EUR',
                    type = 'success',
                    position = 'top'
                })
            else
                TriggerClientEvent('ox_lib:notify', playerId, {
                    title = 'Parduotuvė',
                    description = 'Neturi pakankamai pinigų banke už visus prekes!',
                    type = 'error',
                    position = 'top'
                })
            end
        end
    else
        TriggerClientEvent('ox_lib:notify', playerId, {
            title = 'Parduotuvė',
            description = 'Tavo krepšelis yra tuščias!',
            type = 'error',
            position = 'top'
        })
    end
end)




