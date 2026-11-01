--[[
    CFRP Stats Tracker - Server Side v2.1
    Multi-Framework: QBCore | ESX | QBX (qbx_core) | ox_core

    Receives death events from clients, logs to:
      1. MySQL via oxmysql  (local game DB)
      2. Web API            (live site analytics)
]]

-- ═══════════════════════════════════════════════════════
--  WEB API CONFIG — set as server convars in server.cfg, never commit
--  real values here:
--    set rps_stats_api_url "https://yoursite.example/api/server/stats"
--    set rps_stats_api_key "your-fivem-api-key"   (write scope only)
-- ═══════════════════════════════════════════════════════
local WEB_API_URL = GetConvar('rps_stats_api_url', 'https://yoursite.example/api/server/stats')
local WEB_API_KEY = GetConvar('rps_stats_api_key', '')

local function PostToWebAPI(payload)
    PerformHttpRequest(WEB_API_URL, function(code, text)
        if code == 200 then
            -- success, silent
        else
            print(("[CFRP Stats] Web API POST failed — HTTP %s"):format(tostring(code)))
        end
    end, 'POST', json.encode(payload), {
        ['Content-Type'] = 'application/json',
        ['X-API-Key']    = WEB_API_KEY,
    })
end

-- ═══════════════════════════════════════════════════════
--  FRAMEWORK BRIDGE
-- ═══════════════════════════════════════════════════════

local Framework    = nil
local FrameworkName = nil

local function DetectFramework()
    if Config.Framework ~= 'auto' then
        return Config.Framework
    end
    if GetResourceState('qbx_core')    == 'started' then return 'qbx'    end
    if GetResourceState('qb-core')     == 'started' then return 'qbcore' end
    if GetResourceState('ox_core')     == 'started' then return 'oxcore' end
    if GetResourceState('es_extended') == 'started' then return 'esx'    end
    return nil
end

local function InitFramework()
    FrameworkName = DetectFramework()

    if FrameworkName == 'qbcore' then
        local ok, core = pcall(function() return exports['qb-core']:GetCoreObject() end)
        if ok and core then Framework = core
            print('^2[CFRP Stats]^0 Framework: QBCore')
        else print('^1[CFRP Stats]^0 ERROR: qb-core GetCoreObject() failed') end

    elseif FrameworkName == 'esx' then
        local ok, core = pcall(function() return exports['es_extended']:getSharedObject() end)
        if ok and core then Framework = core
            print('^2[CFRP Stats]^0 Framework: ESX')
        else print('^1[CFRP Stats]^0 ERROR: es_extended getSharedObject() failed') end

    elseif FrameworkName == 'qbx' then
        print('^2[CFRP Stats]^0 Framework: QBX (qbx_core)')

    elseif FrameworkName == 'oxcore' then
        print('^2[CFRP Stats]^0 Framework: ox_core')

    else
        print('^3[CFRP Stats]^0 WARNING: No supported framework — identifiers only')
    end
end

CreateThread(function()
    Wait(500)
    InitFramework()
end)

-- ═══════════════════════════════════════════════════════
--  HELPERS
-- ═══════════════════════════════════════════════════════

local function GetIdentifier(src, idType)
    idType = idType or Config.Identifier
    local prefix = idType .. ':'
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if string.sub(id, 1, #prefix) == prefix then
            return string.sub(id, #prefix + 1)
        end
    end
    return nil
end

local function GetPrimaryId(src)
    return GetIdentifier(src, Config.Identifier)
end

local function GetCharName(src)
    if FrameworkName == 'qbcore' and Framework then
        local ok, p = pcall(function() return Framework.Functions.GetPlayer(src) end)
        if ok and p and p.PlayerData and p.PlayerData.charinfo then
            local ci   = p.PlayerData.charinfo
            local name = ((ci.firstname or '') .. ' ' .. (ci.lastname or '')):match('^%s*(.-)%s*$')
            if name ~= '' then return name end
        end

    elseif FrameworkName == 'esx' and Framework then
        local ok, xp = pcall(function() return Framework.GetPlayerFromId(src) end)
        if ok and xp then
            local ok2, n = pcall(function() return xp.getName() end)
            if ok2 and n and n ~= '' then return n end
        end

    elseif FrameworkName == 'qbx' then
        local ok, p = pcall(function() return exports.qbx_core:GetPlayer(src) end)
        if ok and p and p.PlayerData and p.PlayerData.charinfo then
            local ci   = p.PlayerData.charinfo
            local name = ((ci.firstname or '') .. ' ' .. (ci.lastname or '')):match('^%s*(.-)%s*$')
            if name ~= '' then return name end
        end

    elseif FrameworkName == 'oxcore' then
        local ok, p = pcall(function() return exports.ox_core:GetPlayer(src) end)
        if ok and p then
            local name = ((p.firstName or '') .. ' ' .. (p.lastName or '')):match('^%s*(.-)%s*$')
            if name ~= '' then return name end
        end
    end

    return GetPlayerName(src) or 'Unknown'
end

local function GetCitizenId(src)
    if FrameworkName == 'qbcore' and Framework then
        local ok, p = pcall(function() return Framework.Functions.GetPlayer(src) end)
        if ok and p and p.PlayerData then return p.PlayerData.citizenid end

    elseif FrameworkName == 'esx' and Framework then
        local ok, xp = pcall(function() return Framework.GetPlayerFromId(src) end)
        if ok and xp then return xp.identifier end

    elseif FrameworkName == 'qbx' then
        local ok, p = pcall(function() return exports.qbx_core:GetPlayer(src) end)
        if ok and p and p.PlayerData then return p.PlayerData.citizenid end

    elseif FrameworkName == 'oxcore' then
        local ok, p = pcall(function() return exports.ox_core:GetPlayer(src) end)
        if ok and p then return p.charId or p.userId end
    end

    return GetPrimaryId(src)
end

local function DebugPrint(msg)
    if Config.Debug then
        print('^5[CFRP Stats DEBUG]^0 ' .. msg)
    end
end

-- ═══════════════════════════════════════════════════════
--  DATABASE INSERT
-- ═══════════════════════════════════════════════════════

local function InsertEvent(params)
    exports.oxmysql:execute(
        'INSERT INTO ' .. Config.Table ..
        ' (discord_id, citizenid, event_type, cause, weapon, killer_discord_id, killer_citizenid, killer_name, victim_name, x, y, z)' ..
        ' VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        params
    )
end

-- ═══════════════════════════════════════════════════════
--  DEATH EVENT
-- ═══════════════════════════════════════════════════════

RegisterNetEvent('cfrp_stats:playerDied', function(data)
    local victimSrc       = source
    local victimPrimaryId = GetPrimaryId(victimSrc)
    local victimCitizenId = GetCitizenId(victimSrc)
    local victimName      = GetCharName(victimSrc)

    if not victimPrimaryId then
        print('[CFRP Stats] Skipped — no ' .. Config.Identifier .. ' for: ' .. (GetPlayerName(victimSrc) or 'Unknown'))
        return
    end

    local killerPrimaryId, killerCitizenId, killerName = nil, nil, nil
    local killerSrc = data.killerServerId

    -- ── Player kill ──────────────────────────────────────
    if killerSrc and killerSrc > 0 and killerSrc ~= victimSrc then
        killerPrimaryId = GetPrimaryId(killerSrc)
        killerCitizenId = GetCitizenId(killerSrc)
        killerName      = GetCharName(killerSrc)

        if killerPrimaryId then
            -- MySQL
            InsertEvent({
                killerPrimaryId, killerCitizenId,
                'kill', data.cause or 'Unknown', data.weapon or 'Unknown',
                victimPrimaryId, victimCitizenId, killerName, victimName,
                data.x, data.y, data.z
            })

            -- Web API
            PostToWebAPI({
                discord_id        = killerPrimaryId,
                citizenid         = killerCitizenId,
                event_type        = 'kill',
                cause             = data.cause   or 'Unknown',
                weapon            = data.weapon  or 'Unknown',
                killer_discord_id = victimPrimaryId,
                killer_citizenid  = victimCitizenId,
                killer_name       = killerName,
                victim_name       = victimName,
                x = data.x, y = data.y, z = data.z,
            })

            print(('[CFRP Stats] KILL: %s killed %s with %s'):format(killerName, victimName, data.weapon or 'Unknown'))
        end
    end

    -- ── Death ─────────────────────────────────────────────
    InsertEvent({
        victimPrimaryId, victimCitizenId,
        'death', data.cause or 'Unknown', data.weapon or 'Unknown',
        killerPrimaryId, killerCitizenId, killerName, victimName,
        data.x, data.y, data.z
    })

    PostToWebAPI({
        discord_id        = victimPrimaryId,
        citizenid         = victimCitizenId,
        event_type        = 'death',
        cause             = data.cause   or 'Unknown',
        weapon            = data.weapon  or 'Unknown',
        killer_discord_id = killerPrimaryId,
        killer_citizenid  = killerCitizenId,
        killer_name       = killerName,
        victim_name       = victimName,
        x = data.x, y = data.y, z = data.z,
    })

    print(('[CFRP Stats] DEATH: %s died from %s (%s)'):format(victimName, data.weapon or 'Unknown', data.cause or 'Unknown'))
    DebugPrint('victim_id=' .. tostring(victimPrimaryId) .. ' citizenid=' .. tostring(victimCitizenId))
end)

print('[CFRP Stats] Started — Multi-Framework v2.1 — Web API: ' .. WEB_API_URL)
