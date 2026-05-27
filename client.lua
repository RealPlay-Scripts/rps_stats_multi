--[[
    CFRP Stats Tracker - Client Side
    Detects player deaths and sends info to server
]]

local isDead = false

-- Get weapon name from hash using the game's native
local function GetWeaponNameFromHash(hash)
    -- Environmental / non-weapon causes
    local envCauses = {
        [GetHashKey("WEAPON_FALL")] = "Fall",
        [GetHashKey("WEAPON_DROWNING")] = "Drowning",
        [GetHashKey("WEAPON_DROWNING_IN_VEHICLE")] = "Drowning",
        [GetHashKey("WEAPON_FIRE")] = "Fire",
        [GetHashKey("WEAPON_EXPLOSION")] = "Explosion",
        [GetHashKey("WEAPON_BLEEDING")] = "Bleeding",
        [GetHashKey("WEAPON_ELECTRIC_FENCE")] = "Electrocution",
        [GetHashKey("WEAPON_BARBED_WIRE")] = "Barbed Wire",
        [GetHashKey("WEAPON_EXHAUSTION")] = "Exhaustion",
        [GetHashKey("WEAPON_HIT_BY_WATER_CANNON")] = "Water Cannon",
        [GetHashKey("WEAPON_VEHICLE")] = "Vehicle",
        [GetHashKey("WEAPON_RAMMINGCAR")] = "Vehicle",
        [GetHashKey("WEAPON_RUN_OVER_BY_CAR")] = "Run Over",
        [GetHashKey("WEAPON_ANIMAL")] = "Animal Attack",
        [3452007600] = "Vehicle",  -- another vehicle hash
    }
    
    if envCauses[hash] then
        return envCauses[hash], envCauses[hash]
    end

    -- Known weapon names
    local weapons = {
        -- Pistols
        [GetHashKey("WEAPON_PISTOL")] = "Pistol",
        [GetHashKey("WEAPON_PISTOL_MK2")] = "Pistol Mk II",
        [GetHashKey("WEAPON_COMBATPISTOL")] = "Combat Pistol",
        [GetHashKey("WEAPON_PISTOL50")] = "Pistol .50",
        [GetHashKey("WEAPON_HEAVYPISTOL")] = "Heavy Pistol",
        [GetHashKey("WEAPON_VINTAGEPISTOL")] = "Vintage Pistol",
        [GetHashKey("WEAPON_MARKSMANPISTOL")] = "Marksman Pistol",
        [GetHashKey("WEAPON_REVOLVER")] = "Revolver",
        [GetHashKey("WEAPON_REVOLVER_MK2")] = "Revolver Mk II",
        [GetHashKey("WEAPON_APPISTOL")] = "AP Pistol",
        [GetHashKey("WEAPON_SNSPISTOL")] = "SNS Pistol",
        [GetHashKey("WEAPON_SNSPISTOL_MK2")] = "SNS Pistol Mk II",
        [GetHashKey("WEAPON_CERAMICPISTOL")] = "Ceramic Pistol",
        [GetHashKey("WEAPON_NAVYREVOLVER")] = "Navy Revolver",
        [GetHashKey("WEAPON_GADGETPISTOL")] = "Perico Pistol",
        -- SMGs
        [GetHashKey("WEAPON_MICROSMG")] = "Micro SMG",
        [GetHashKey("WEAPON_SMG")] = "SMG",
        [GetHashKey("WEAPON_SMG_MK2")] = "SMG Mk II",
        [GetHashKey("WEAPON_COMBATSMG")] = "Combat SMG",
        [GetHashKey("WEAPON_COMBATSMG_MK2")] = "Combat SMG Mk II",
        [GetHashKey("WEAPON_ASSAULTSMG")] = "Assault SMG",
        [GetHashKey("WEAPON_MACHINEPISTOL")] = "Machine Pistol",
        [GetHashKey("WEAPON_MINISMG")] = "Mini SMG",
        -- Rifles
        [GetHashKey("WEAPON_ASSAULTRIFLE")] = "Assault Rifle",
        [GetHashKey("WEAPON_ASSAULTRIFLE_MK2")] = "Assault Rifle Mk II",
        [GetHashKey("WEAPON_CARBINERIFLE")] = "Carbine Rifle",
        [GetHashKey("WEAPON_CARBINERIFLE_MK2")] = "Carbine Rifle Mk II",
        [GetHashKey("WEAPON_ADVANCEDRIFLE")] = "Advanced Rifle",
        [GetHashKey("WEAPON_SPECIALCARBINE")] = "Special Carbine",
        [GetHashKey("WEAPON_SPECIALCARBINE_MK2")] = "Special Carbine Mk II",
        [GetHashKey("WEAPON_BULLPUPRIFLE")] = "Bullpup Rifle",
        [GetHashKey("WEAPON_BULLPUPRIFLE_MK2")] = "Bullpup Rifle Mk II",
        [GetHashKey("WEAPON_COMPACTRIFLE")] = "Compact Rifle",
        [GetHashKey("WEAPON_MILITARYRIFLE")] = "Military Rifle",
        [GetHashKey("WEAPON_HEAVYRIFLE")] = "Heavy Rifle",
        [GetHashKey("WEAPON_TACTICALRIFLE")] = "Service Carbine",
        -- MGs
        [GetHashKey("WEAPON_MG")] = "MG",
        [GetHashKey("WEAPON_COMBATMG")] = "Combat MG",
        [GetHashKey("WEAPON_COMBATMG_MK2")] = "Combat MG Mk II",
        [GetHashKey("WEAPON_GUSENBERG")] = "Gusenberg Sweeper",
        -- Shotguns
        [GetHashKey("WEAPON_PUMPSHOTGUN")] = "Pump Shotgun",
        [GetHashKey("WEAPON_PUMPSHOTGUN_MK2")] = "Pump Shotgun Mk II",
        [GetHashKey("WEAPON_SAWNOFFSHOTGUN")] = "Sawed-Off Shotgun",
        [GetHashKey("WEAPON_ASSAULTSHOTGUN")] = "Assault Shotgun",
        [GetHashKey("WEAPON_BULLPUPSHOTGUN")] = "Bullpup Shotgun",
        [GetHashKey("WEAPON_DBSHOTGUN")] = "Double Barrel Shotgun",
        [GetHashKey("WEAPON_COMBATSHOTGUN")] = "Combat Shotgun",
        [GetHashKey("WEAPON_HEAVYSHOTGUN")] = "Heavy Shotgun",
        -- Snipers
        [GetHashKey("WEAPON_SNIPERRIFLE")] = "Sniper Rifle",
        [GetHashKey("WEAPON_HEAVYSNIPER")] = "Heavy Sniper",
        [GetHashKey("WEAPON_HEAVYSNIPER_MK2")] = "Heavy Sniper Mk II",
        [GetHashKey("WEAPON_MARKSMANRIFLE")] = "Marksman Rifle",
        [GetHashKey("WEAPON_MARKSMANRIFLE_MK2")] = "Marksman Rifle Mk II",
        [GetHashKey("WEAPON_PRECISIONRIFLE")] = "Precision Rifle",
        -- Heavy
        [GetHashKey("WEAPON_MINIGUN")] = "Minigun",
        [GetHashKey("WEAPON_RPG")] = "RPG",
        [GetHashKey("WEAPON_GRENADELAUNCHER")] = "Grenade Launcher",
        [GetHashKey("WEAPON_FIREWORK")] = "Firework Launcher",
        [GetHashKey("WEAPON_RAILGUN")] = "Railgun",
        [GetHashKey("WEAPON_HOMINGLAUNCHER")] = "Homing Launcher",
        [GetHashKey("WEAPON_COMPACTLAUNCHER")] = "Compact Launcher",
        -- Melee
        [GetHashKey("WEAPON_UNARMED")] = "Fists",
        [GetHashKey("WEAPON_KNIFE")] = "Knife",
        [GetHashKey("WEAPON_BAT")] = "Baseball Bat",
        [GetHashKey("WEAPON_CROWBAR")] = "Crowbar",
        [GetHashKey("WEAPON_HAMMER")] = "Hammer",
        [GetHashKey("WEAPON_HATCHET")] = "Hatchet",
        [GetHashKey("WEAPON_MACHETE")] = "Machete",
        [GetHashKey("WEAPON_SWITCHBLADE")] = "Switchblade",
        [GetHashKey("WEAPON_BOTTLE")] = "Bottle",
        [GetHashKey("WEAPON_DAGGER")] = "Antique Dagger",
        [GetHashKey("WEAPON_KNUCKLE")] = "Brass Knuckles",
        [GetHashKey("WEAPON_GOLFCLUB")] = "Golf Club",
        [GetHashKey("WEAPON_NIGHTSTICK")] = "Nightstick",
        [GetHashKey("WEAPON_WRENCH")] = "Wrench",
        [GetHashKey("WEAPON_POOLCUE")] = "Pool Cue",
        [GetHashKey("WEAPON_STONE_HATCHET")] = "Stone Hatchet",
        [GetHashKey("WEAPON_BATTLEAXE")] = "Battle Axe",
        -- Throwables
        [GetHashKey("WEAPON_GRENADE")] = "Grenade",
        [GetHashKey("WEAPON_MOLOTOV")] = "Molotov",
        [GetHashKey("WEAPON_STICKYBOMB")] = "Sticky Bomb",
        [GetHashKey("WEAPON_PIPEBOMB")] = "Pipe Bomb",
        [GetHashKey("WEAPON_PROXMINE")] = "Proximity Mine",
        [GetHashKey("WEAPON_BZGAS")] = "BZ Gas",
        [GetHashKey("WEAPON_SMOKEGRENADE")] = "Tear Gas",
        -- Misc
        [GetHashKey("WEAPON_STUNGUN")] = "Stun Gun",
        [GetHashKey("WEAPON_FLAREGUN")] = "Flare Gun",
        [GetHashKey("WEAPON_PETROLCAN")] = "Jerry Can",
        [GetHashKey("WEAPON_MUSKET")] = "Musket",
        [GetHashKey("WEAPON_RAYPISTOL")] = "Up-n-Atomizer",
        [GetHashKey("WEAPON_RAYCARBINE")] = "Unholy Hellbringer",
        [GetHashKey("WEAPON_RAYMINIGUN")] = "Widowmaker",
        [GetHashKey("WEAPON_EMPLAUNCHER")] = "EMP Launcher",
    }
    
    if weapons[hash] then
        return weapons[hash], "Weapon"
    end
    
    -- Fallback: try to get name from hash string
    return "Unknown Weapon", "Unknown"
end

-- Get cause category
local function GetDeathCategory(hash)
    local _, cause = GetWeaponNameFromHash(hash)
    return cause
end

-- Main death detection loop
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        
        local ped = PlayerPedId()
        local playerDead = IsEntityDead(ped)
        
        if playerDead and not isDead then
            isDead = true
            
            local killerEntity = GetPedSourceOfDeath(ped)
            local weaponHash = GetPedCauseOfDeath(ped)
            local weaponName, deathCategory = GetWeaponNameFromHash(weaponHash)
            local killerServerId = 0
            
            -- Check if killer is a player
            if killerEntity and killerEntity ~= 0 and killerEntity ~= ped then
                if IsEntityAPed(killerEntity) and IsPedAPlayer(killerEntity) then
                    killerServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(killerEntity))
                elseif IsEntityAVehicle(killerEntity) then
                    local driver = GetPedInVehicleSeat(killerEntity, -1)
                    if driver and driver ~= 0 and IsPedAPlayer(driver) then
                        killerServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(driver))
                        if deathCategory ~= "Run Over" then
                            deathCategory = "Vehicle"
                        end
                    end
                end
            end
            
            local coords = GetEntityCoords(ped)
            
            TriggerServerEvent('cfrp_stats:playerDied', {
                killerServerId = killerServerId,
                weapon = weaponName,
                cause = deathCategory,
                x = coords.x,
                y = coords.y,
                z = coords.z
            })
            
        elseif not playerDead and isDead then
            isDead = false
        end
    end
end)
