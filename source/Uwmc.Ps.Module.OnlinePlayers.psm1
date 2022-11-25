class UwPlayerListEntry {
    [string] $HtmlDisplayName
    [string] $HexColor
    [string] $PlayerName
    [string] $PlayerUid
    [int] $Priority
    [int] $ForumUserId

    UwPlayerListEntry($HtmlDisplayName, $HexColor, $PlayerName, $PlayerUid, $Priority, $ForumUserId) {
        $this.HtmlDisplayName = $HtmlDisplayName
        $this.HexColor = $HexColor
        $this.PlayerName = $PlayerName
        $this.PlayerUid = $PlayerUid
        $this.Priority = $Priority
        $this.ForumUserId = $ForumUserId
    }
}


function Get-OnlinePlayers {
    [OutputType([UwPlayerListEntry])]
    param(
        [parameter(ParameterSetName = "seta", Mandatory = $false)][switch] $SkipPlayerUid = $false
    )

    $result = @()

    $playerList = Invoke-WebRequest -Uri "$($env:UWMCPS_APIURL)?req=player_list" `
    | Select-Object -ExpandProperty Content `
    | ConvertFrom-Json `
    | Select-Object -ExpandProperty data


    foreach ($playerListEntry in $playerList) {
        $playerUuid = $null
        if ($SkipPlayerUid -eq $false) {
            $playerUuid = Invoke-WebRequest -Uri "https://api.mojang.com/users/profiles/minecraft/$($playerListEntry.playerName)" | ConvertFrom-Json | Select-Object -ExpandProperty id
        }

        $result += [UwPlayerListEntry]::new($playerListEntry.displayName, $playerListEntry.color, $playerListEntry.playerName, $playerUuid, $playerListEntry.priority, $playerListEntry.boardId)
    }

    return $result;
}