local ESX = nil
local isInGarage = false
local currentBoat = nil
local currentParking = nil
local isInImpound = false

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Afficher un menu pour interagir avec les bateaux
function OpenBoatGarageMenu(parking)
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'boat_garage',
    {
        title    = 'Garage de Bateaux',
        align    = 'top-left',
        elements = {
            {label = 'Récupérer un bateau', value = 'retrieve_boat'},
            {label = 'Stocker un bateau', value = 'store_boat'},
            {label = 'Impound', value = 'impound_boats'}
        }
    }, function(data, menu)
        if data.current.value == 'retrieve_boat' then
            RetrieveBoatFromGarage(parking)
        elseif data.current.value == 'store_boat' then
            StoreBoatInGarage()
        elseif data.current.value == 'impound_boats' then
            GetImpoundedBoats()
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- Récupérer un bateau du garage
function RetrieveBoatFromGarage(parking)
    ESX.TriggerServerCallback('esx_garage_boat:getBoatsInParking', function(boats)
        local elements = {}

        for _, boat in ipairs(boats) do
            table.insert(elements, {
                label = boat.vehicle.model .. ' (' .. boat.plate .. ')',
                value = boat.plate
            })
        end

        if #elements > 0 then
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'retrieve_boat_menu', {
                title    = 'Sélectionnez un bateau',
                align    = 'top-left',
                elements = elements
            }, function(data, menu)
                TriggerServerEvent('esx_garage_boat:updateOwnedBoat', 0, parking, nil, data.current.value, vector3(0, 0, 0))
                menu.close()
            end, function(data, menu)
                menu.close()
            end)
        else
            ESX.ShowNotification('Aucun bateau trouvé dans ce garage.')
        end
    end, parking)
end

-- Stocker un bateau dans le garage
function StoreBoatInGarage()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if IsPedInAnyVehicle(playerPed, false) and vehicle ~= 0 then
        local boatProps = ESX.Game.GetVehicleProperties(vehicle)
        TriggerServerEvent('esx_garage_boat:updateOwnedBoat', 1, currentParking, nil, boatProps, vector3(0, 0, 0))
        ESX.ShowNotification('Votre bateau a été stocké.')
    else
        ESX.ShowNotification('Vous devez être dans un bateau pour le stocker.')
    end
end

-- Gérer l'impound des bateaux
function GetImpoundedBoats()
    ESX.TriggerServerCallback('esx_garage_boat:getBoatsImpounded', function(boats)
        local elements = {}

        for _, boat in ipairs(boats) do
            table.insert(elements, {
                label = boat.vehicle.model .. ' (' .. boat.plate .. ')',
                value = boat.plate
            })
        end

        if #elements > 0 then
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'impound_menu', {
                title    = 'Boats Saisie',
                align    = 'top-left',
                elements = elements
            }, function(data, menu)
                ESX.TriggerServerCallback('esx_garage_boat:checkMoney', function(hasMoney)
                    if hasMoney then
                        TriggerServerEvent('esx_garage_boat:payPound', 1000)
                        TriggerServerEvent('esx_garage_boat:updateOwnedBoat', 0, currentParking, nil, data.current.value, vector3(0, 0, 0))
                        menu.close()
                    else
                        ESX.ShowNotification('Vous n\'avez pas assez d\'argent pour récupérer ce bateau.')
                    end
                end, 1000)
            end, function(data, menu)
                menu.close()
            end)
        else
            ESX.ShowNotification('Aucun bateau saisi dans l\'Impound.')
        end
    end)
end

-- Interaction avec le garage de bateaux
Citizen.CreateThread(function()
    local parkingLocation = vector3(1695.34, 3586.58, 35.32) -- À ajuster en fonction de l'endroit où vous voulez le garage
    local blip = AddBlipForCoord(parkingLocation)
    SetBlipSprite(blip, 427)  -- Blip pour un garage marin
    SetBlipColour(blip, 3)
    SetBlipScale(blip, 0.9)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Garage de Bateaux")
    EndTextCommandSetBlipName(blip)

    -- Détection de la proximité avec le garage
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        local dist = GetDistanceBetweenCoords(playerPos, parkingLocation, true)

        if dist < 10.0 then
            ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour accéder au garage de bateaux.")

            if IsControlJustPressed(0, 38) then
                OpenBoatGarageMenu(currentParking)
            end
        end
    end
end)
