fx_version 'cerulean'
game 'gta5'

author 'CritteR / CritteRo'
description 'GTA San Andreas Blood Bowl minigame working in FiveM.'

client_scripts {
    'client/cl_arena_interior.lua',
    'client/cl_arena_utils.lua',
    'client/cl_arena_textEntries.lua',
    'client/cl_arena_handler.lua',
    'client/cl_arena_main_menu.lua',
    'client/cl_arena_markers.lua',
    'client/cl_arena_intro.lua',
    'client/cl_arena_ui.lua',
    'client/cl_ai_test.lua',
}

server_scripts {
    'server/sv_arena_handler.lua',
    'server/sv_arena_vehicles.lua',
    'server/sv_ai_test.lua',
}

shared_scripts {
    'shared/sh_arena_utils.lua',
}