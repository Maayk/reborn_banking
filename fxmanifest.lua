fx_version 'cerulean'
game 'gta5'

ui_page "html/index.html"

client_scripts {
  'config.lua',
  'client/client.lua',
}

server_scripts {
 'config.lua',
 'server/server.lua'
}

exports {
  'IsNearAtm',
  'IsNearAnyBank',
}

files {
 "html/index.html",
 "html/js/script.js",
 "html/css/*.css",
 "html/img/*.png"
}