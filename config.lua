Config = {}

-- Coordonnées du garage de bateaux
Config.GarageLocation = vector3(1695.34, 3586.58, 35.32)

-- Frais d'impound pour récupérer un bateau
Config.ImpoundFee = 1000

-- Liste des parkings de bateaux disponibles
Config.ParkingLocations = {
    {x = 1695.34, y = 3586.58, z = 35.32},
    -- Ajoutez ici d'autres points de parking si nécessaire
}

-- Texte des notifications
Config.NotificationText = {
    veh_stored = "Votre bateau a été stocké dans le garage.",
    veh_impounded = "Votre bateau a été saisi par les autorités.",
    pay_Impound_bill = "Vous avez payé ~r~${amount}~s~ pour récupérer votre bateau saisi.",
    missing_money = "Vous n'avez pas assez d'argent pour récupérer ce bateau."
}

-- Définir le nombre d'essais pour tenter de récupérer un bateau du garage
Config.RetrieveAttempts = 3
