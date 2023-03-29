$env:UWMCPS_APIURL = $null -ne $env:UWMCPS_APIURL ? $env:UWMCPS_APIURL : 'https://www.unlimitedworld.de/server_api/ajax.php'
$env:UWMCPS_ZONESURL = $null -ne $env:UWMCPS_ZONESURL ? $env:UWMCPS_ZONESURL : 'https://map.unlimitedworld.de/tiles/_markers_/marker_main.json'
$env:UWMCPS_MOJANGAPIURL = $null -ne $env:UWMCPS_MOJANGAPIURL ? $env:UWMCPS_MOJANGAPIURL : 'https://api.mojang.com'