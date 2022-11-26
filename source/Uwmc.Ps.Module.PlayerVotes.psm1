class UwPlayerVote {
    [string] $PlayerName
    [string] $PlayerUid
    [int] $ServerlistMinecraftServerEu
    [int] $ServerlistMinecraftServerListNet

    UwPlayerVote($PlayerName, $PlayerUid, $ServerlistMinecraftServerEu, $ServerlistMinecraftServerListNet) {
        $this.PlayerName = $PlayerName
        $this.PlayerUid = $PlayerUid
        $this.ServerlistMinecraftServerEu = $ServerlistMinecraftServerEu
        $this.ServerlistMinecraftServerListNet = $ServerlistMinecraftServerListNet
    }
}


function Get-PlayerVotes {
    [OutputType([UwPlayerVote])]
    param(
        [parameter(ParameterSetName = "seta", Mandatory = $false)][switch] $IncludePlayerUid = $false
    )

    $result = @()

    $playerVotes = Invoke-WebRequest -Uri "$($env:UWMCPS_APIURL)?req=player_votes" `
    | Select-Object -ExpandProperty Content `
    | ConvertFrom-Json `
    | Select-Object -ExpandProperty data

    foreach ($playerVote in $playerVotes) {
        $playerUuid = $null
        if ($IncludePlayerUid -eq $true) {
            $playerUuid = Invoke-WebRequest -Uri "$($env:UWMCPS_MOJANGAPIURL)/users/profiles/minecraft/$($playerVote.user)" | ConvertFrom-Json | Select-Object -ExpandProperty id
        }

        $result += [UwPlayerVote]::new($playerVote.user, $playerUuid, $playerVote.s1, $playerVote.s2)
    }

    return $result;
}