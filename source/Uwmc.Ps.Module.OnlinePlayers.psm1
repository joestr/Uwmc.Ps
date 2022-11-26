class UwOnlinePlayer {
    [string] $HtmlDisplayName
    [string] $HexColor
    [string] $PlayerName
    [string] $PlayerUid
    [int] $Priority
    [int] $ForumUserId

    UwOnlinePlayer($HtmlDisplayName, $HexColor, $PlayerName, $PlayerUid, $Priority, $ForumUserId) {
        $this.HtmlDisplayName = $HtmlDisplayName
        $this.HexColor = $HexColor
        $this.PlayerName = $PlayerName
        $this.PlayerUid = $PlayerUid
        $this.Priority = $Priority
        $this.ForumUserId = $ForumUserId
    }
}


function Get-OnlinePlayers {
    [OutputType([UwOnlinePlayer])]
    param(
        [parameter(ParameterSetName = "seta", Mandatory = $false)][switch] $IncludePlayerUid = $false
    )

    $result = @()

    $onlinePlayers = Invoke-WebRequest -Uri "$($env:UWMCPS_APIURL)?req=player_list" `
    | Select-Object -ExpandProperty Content `
    | ConvertFrom-Json `
    | Select-Object -ExpandProperty data

    foreach ($onlinePlayer in $onlinePlayers) {
        $playerUuid = $null
        if ($IncludePlayerUid -eq $true) {
            $playerUuid = Invoke-WebRequest -Uri "$($env:UWMCPS_MOJANGAPIURL)/users/profiles/minecraft/$($onlinePlayer.playerName)" | ConvertFrom-Json | Select-Object -ExpandProperty id
        }

        $result += [UwOnlinePlayer]::new($onlinePlayer.displayName, $onlinePlayer.color, $onlinePlayer.playerName, $playerUuid, $onlinePlayer.priority, $onlinePlayer.boardId)
    }

    return $result;
}