ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Événement : Mettre à jour un bateau
RegisterServerEvent('esx_garage_boat:updateOwnedBoat')
AddEventHandler('esx_garage_boat:updateOwnedBoat', function(stored, parking, impound, data, spawn)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not data or not data.vehicleProps or not data.vehicleProps.plate then
        print("[ERROR] Invalid boat data received in esx_garage_boat:updateOwnedBoat")
        return
    end

    MySQL.update(
        'UPDATE owned_boats SET `stored` = @stored, `parking` = @parking, `pound` = @impound, `vehicle` = @vehicle WHERE `plate` = @plate AND `owner` = @identifier',
        {
            ['@identifier'] = xPlayer.identifier,
            ['@vehicle'] = json.encode(data.vehicleProps),
            ['@plate'] = data.vehicleProps.plate,
            ['@stored'] = stored,
            ['@parking'] = parking,
            ['@impound'] = impound
        }
    )

    if stored then
        xPlayer.showNotification("Votre bateau a été stocké avec succès.")
    else
        ESX.OneSync.SpawnVehicle(data.vehicleProps.model, spawn, data.spawnPoint.heading, data.vehicleProps, function(vehicle)
            local vehicle = NetworkGetEntityFromNetworkId(vehicle)
            Wait(300)
            TaskWarpPedIntoVehicle(GetPlayerPed(source), vehicle, -1)
        end)
    end
end)

-- Événement : Définir un bateau comme saisi
RegisterServerEvent('esx_garage_boat:setImpound')
AddEventHandler('esx_garage_boat:setImpound', function(impound, vehicleProps)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not vehicleProps or not vehicleProps.plate then
        print("[ERROR] Invalid boat data received in esx_garage_boat:setImpound")
        return
    end

    MySQL.update(
        'UPDATE owned_boats SET `stored` = @stored, `pound` = @impound, `vehicle` = @vehicle WHERE `plate` = @plate AND `owner` = @identifier',
        {
            ['@identifier'] = xPlayer.identifier,
            ['@vehicle'] = json.encode(vehicleProps),
            ['@plate'] = vehicleProps.plate,
            ['@stored'] = 0,
            ['@impound'] = impound
        }
    )

    xPlayer.showNotification("Votre bateau a été saisi et envoyé à l'Impound.")
end)

-- Callback : Récupérer les bateaux stockés dans un parking spécifique
ESX.RegisterServerCallback('esx_garage_boat:getBoatsInParking', function(source, cb, parking)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.query(
        'SELECT * FROM `owned_boats` WHERE `owner` = @identifier AND `parking` = @parking AND `stored` = 1',
        {
            ['@identifier'] = xPlayer.identifier,
            ['@parking'] = parking
        },
        function(result)
            local boats = {}

            for i = 1, #result, 1 do
                table.insert(boats, {
                    vehicle = json.decode(result[i].vehicle),
                    plate = result[i].plate
                })
            end

            cb(boats)
        end
    )
end)

-- Callback : Récupérer les bateaux saisis
ESX.RegisterServerCallback('esx_garage_boat:getBoatsImpounded', function(source, cb, impound)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.query(
        'SELECT * FROM `owned_boats` WHERE `owner` = @identifier AND `pound` = @impound AND `stored` = 0',
        {
            ['@identifier'] = xPlayer.identifier,
            ['@impound'] = impound
        },
        function(result)
            local boats = {}

            for i = 1, #result, 1 do
                table.insert(boats, {
                    vehicle = json.decode(result[i].vehicle),
                    plate = result[i].plate
                })
            end

            cb(boats)
        end
    )
end)

-- Callback : Vérifier si le joueur possède un bateau
ESX.RegisterServerCallback('esx_garage_boat:checkBoatOwner', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.query(
        'SELECT COUNT(*) as count FROM `owned_boats` WHERE `owner` = @identifier AND `plate` = @plate',
        {
            ['@identifier'] = xPlayer.identifier,
            ['@plate'] = plate
        },
        function(result)
            cb(result[1].count > 0)
        end
    )
end)

-- Paiement des frais d'Impound
RegisterServerEvent("esx_garage_boat:payPound")
AddEventHandler("esx_garage_boat:payPound", function(amount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount, "Frais d'Impound")
        xPlayer.showNotification("Vous avez payé les frais d'Impound : ~g~$" .. amount)
    else
        xPlayer.showNotification("~r~Vous n'avez pas assez d'argent pour payer les frais.")
    end
end)
