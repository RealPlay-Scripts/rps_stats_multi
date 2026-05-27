fx_version 'cerulean'
game 'gta5'

author 'CFRP'
description 'Kill/Death tracking for CFRP web portal - Multi Framework'
version '2.0.0'

server_scripts {
    'config.lua',
    'server.lua',
}

client_scripts {
    'client.lua',
}

-- oxmysql is required regardless of framework
dependencies {
    'oxmysql',
}

-- Optional framework dependencies (resource will auto-detect)
-- 'qb-core', 'es_extended', 'qbx_core', 'ox_core'
