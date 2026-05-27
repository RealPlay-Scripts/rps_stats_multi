--[[
    CFRP Stats Tracker - Config
    Supports: qbcore | esx | qbx | oxcore | auto
]]

Config = {}

-- ┌─────────────────────────────────────────────────────┐
-- │  FRAMEWORK                                          │
-- │  'auto'    → auto-detect (recommended)              │
-- │  'qbcore'  → QBCore (qb-core)                      │
-- │  'esx'     → ESX (es_extended)                     │
-- │  'qbx'     → QBox Core (qbx_core)                  │
-- │  'oxcore'  → Overextended Core (ox_core)            │
-- └─────────────────────────────────────────────────────┘
Config.Framework = 'auto'

-- ┌─────────────────────────────────────────────────────┐
-- │  IDENTIFIER                                         │
-- │  Primary player identifier stored in DB             │
-- │  'discord' → Discord ID (default, works everywhere) │
-- │  'license' → Rockstar License                       │
-- │  'steam'   → Steam ID                               │
-- └─────────────────────────────────────────────────────┘
Config.Identifier = 'discord'

-- ┌─────────────────────────────────────────────────────┐
-- │  DATABASE TABLE                                     │
-- └─────────────────────────────────────────────────────┘
Config.Table = 'cfrp_player_stats'

-- ┌─────────────────────────────────────────────────────┐
-- │  LOGGING                                            │
-- └─────────────────────────────────────────────────────┘
Config.Debug = false  -- Set true to print extra info to console
