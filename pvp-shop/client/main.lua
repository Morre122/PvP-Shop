local cart = {
    items = {},
    totalPrice = 0,
    totalAmount = 0
}

local weaponNames = {
    weapon_combatpistol = "Combat Pistol",
    weapon_pistol = "Pistol",
    weapon_specialcarbine = "Special Carbine",
    weapon_carbinerifle = "Carbine Rifle",
    weapon_pistol50 = "Pistol50",
    weapon_machinepistol = "Machine Pistol",
    weapon_smg = "Smg",
    ammo_9 = "Ammo 9mm",
    medikit = "Vaistinėlė"
}

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

local function addWeaponToCart(weaponName)
    local weaponLabel = weaponNames[weaponName]
    local weaponPrice = kainos[weaponName]

    local input = lib.inputDialog('Kiekis', {
        {type = 'number', label = 'Įveskite kiekį', default = 1, min = 1, max = 5000},
    })
    
    if not input then return end

    local quantity = tonumber(input[1])
    if quantity <= 0 then
        lib.notify({
            title = 'Klaida',
            description = 'Kiekis turi būti teigiamas skaičius!',
            type = 'error',
            position = 'top'
        })
        return
    end

    local found = false
    for _, item in ipairs(cart.items) do
        if item.weaponName == weaponName then
            item.quantity = item.quantity + quantity
            found = true
            break
        end
    end

    if not found then
        table.insert(cart.items, {
            weaponName = weaponName,
            weaponLabel = weaponLabel,
            price = weaponPrice,
            quantity = quantity
        })
    end

    cart.totalPrice = cart.totalPrice + (weaponPrice * quantity)
    cart.totalAmount = cart.totalAmount + quantity

    lib.notify({
        title = 'Parduotuvė',
        description = weaponLabel .. ' pridėtas į tavo krepšelį ' .. quantity .. ' vnt',
        type = 'inform',
        position = 'top'
    })

    lib.showContext('shopas')
end

local function showStorageSelectionDialog(paymentMethod)
    lib.registerContext({
        id = 'storageSelectionMenu',
        title = 'Kur siųsti daiktus?',
        menu = 'paymentMethodMenu',
        options = {
            {
                title = 'Į inventorių',
                description = 'Siųsti gautus daiktus į žaidėjo inventorių',
                onSelect = function()
                    TriggerServerEvent('myshop:buyItems', paymentMethod, cart, 'inventory')
                end
            },
            {
                title = 'Į sandėlį',
                description = 'Siųsti gautus daiktus į sandėlį',
                onSelect = function()
                    TriggerServerEvent('myshop:buyItems', paymentMethod, cart, 'storage')
                end
            }
        }
    })
    lib.showContext('storageSelectionMenu')
end

local function showPaymentMethodDialog()
    lib.registerContext({
        id = 'paymentMethodMenu',
        title = 'Mokėjimo metodas',
        menu = 'cartMenu',
        options = {
            {
                title = 'Grynaisiais',
                description = 'Sumokėkite grynaisiais',
                onSelect = function()
                    showStorageSelectionDialog('cash')
                end
            },
            {
                title = 'Bankai',
                description = 'Sumokėkite banko sąskaita',
                onSelect = function()
                    showStorageSelectionDialog('bank')
                end
            }
        }
    })
    lib.showContext('paymentMethodMenu')
end

local function showCart()
    local options = {}

    if #cart.items == 0 then
        table.insert(options, {
            title = 'Krepšelis tuščias',
            description = 'Nėra prekių krepšelyje'
        })
    else

        for _, item in ipairs(cart.items) do
            table.insert(options, {
                title = item.weaponLabel .. ' (' .. item.quantity .. ' vnt.)',
                description = 'Kaina už vienetą: $' .. item.price
            })
        end

        table.insert(options, {
            title = 'Pirkti',
            description = 'Bendra suma: $' .. cart.totalPrice,
            onSelect = function()
                showPaymentMethodDialog()
            end
        })

        table.insert(options, {
            title = 'Išvalyti krepšelį',
            onSelect = function()
                cart.items = {} 
                cart.totalPrice = 0 
                showCart()
            end
        })
    end

    lib.registerContext({
        id = 'cartMenu',
        menu = 'shopas',
        title = 'Jūsų krepšelis',
        options = options
    })

    lib.showContext('cartMenu')
end

local function showPistoletaiMenu()
    lib.registerContext({
        id = 'pistoletaiMenu',
        title = 'Pistoletai',
        menu = 'shopas',
        options = {
            {
                title = 'Combat Pistol',
                description = 'Kaina: 2500 EUR',
                onSelect = function()
                    addWeaponToCart('weapon_combatpistol')
                end
            },
            {
                title = 'Pistol',
                description = 'Kaina: 2000 EUR',
                onSelect = function()
                    addWeaponToCart('weapon_pistol')
                end
            },
            {
                title = 'Pistol50',
                description = 'Kaina: 3500 EUR',
                onSelect = function()
                    addWeaponToCart('weapon_pistol50')
                end
            },
            {
                title = 'Machine Pistol',
                description = 'Kaina: 6000 EUR',
                onSelect = function()
                    addWeaponToCart('weapon_machinepistol')
                end
            },
        }
    })
    lib.showContext('pistoletaiMenu')
end

local function showAmunicijaMenu()
    lib.registerContext({
        id = 'amunicijamenu',
        title = 'Įvairūs daiktai',
        menu = 'shopas',
        options = {
            {
                title = 'Ammo 9mm',
                description = 'Kaina: 10 EUR',
                onSelect = function()
                    addWeaponToCart('ammo_9')
                end
            },
            {
                title = 'Vaistinėlė',
                description = 'Kaina: 1500 EUR',
                onSelect = function()
                    addWeaponToCart('medikit')
                end
            },
        }
    })
    lib.showContext('amunicijamenu')
end

local function showStambusGinklaiMenu()
    lib.registerContext({
        id = 'stambusGinklaiMenu',
        title = 'Stambūs ginklai',
        menu = 'shopas',
        options = {
            {
                title = 'Special Carbine',
                description = 'Kaina: 6500 EUR',
                onSelect = function()
                    addWeaponToCart('weapon_specialcarbine')
                end
            },
            {
                title = 'Carbine Rifle',
                description = 'Kaina: 6000 EUR',
                onSelect = function()
                    addWeaponToCart('weapon_carbinerifle')
                end
            },
            {
                title = 'Smg',
                description = 'Kaina: 6000 EUR',
                onSelect = function()
                    addWeaponToCart('weapon_smg')
                end
            },
        }
    })
    lib.showContext('stambusGinklaiMenu')
end

local function showShopMenu()
    lib.registerContext({
        id = 'shopas',
        menu = 'some_menu',
        title = 'Parduotuvė',
        options = {
            {
                title = 'Pistoletai',
                description = 'Peržiūrėkite pistoletų pasirinkimą',
                onSelect = function()
                    showPistoletaiMenu()
                end
            },
            {
                title = 'Stambūs ginklai',
                description = 'Peržiūrėkite stambių ginklų pasirinkimą',
                onSelect = function()
                    showStambusGinklaiMenu()
                end
            },
            {
                title = 'Įvairūs daiktai',
                description = 'Peržiūrėkite įvairių daiktų pasirinkimą',
                onSelect = function()
                    showAmunicijaMenu()
                end
            },
            {
                title = 'Krepšelis',
                description = 'Peržiūrėkite savo krepšelį',
                onSelect = function()
                    showCart()
                end
            }
        }
    })
    lib.showContext('shopas')
end

TriggerEvent('chat:addSuggestion', '/bbc', 'Pirk įviariausius daiktus už geriausias kainas!', {})

RegisterCommand('bbc', function()
    showShopMenu()
end, false)