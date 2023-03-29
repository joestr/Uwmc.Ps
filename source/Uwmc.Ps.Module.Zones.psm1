class UwZone {
    [int] $Id
    [string] $Label
    [bool] $Markup
    [int] $FirstX
    [int] $FirstY
    [int] $SecondX
    [int] $SecondY
    [int] $YBottom
    [int] $YTop
    [string] $Color
    [int] $Opacity
    [double] $FillOpacity
    [int] $Weight
    UwZone($Id, $Label, $Markup, $FirstX, $FirstY, $SecondX, $SecondY, $YBottom, $YTop, $Color, $Opacity, $FillOpacity, $Weight) {
        $this.Id = $Id
        $this.Label = $Label
        $this.Markup = $Markup
        $this.FirstX = $FirstX
        $this.FirstY = $FirstY
        $this.SecondX = $SecondX
        $this.SecondY = $SecondY
        $this.YBottom = $YBottom
        $this.YTop = $YTop
        $this.Color = $Color
        $this.Opacity = $Opacity
        $this.FillOpacity = $FillOpacity
        $this.Weight = $Weight
    }
}


function Get-Zones {
    [OutputType([UwZone])]
    param(
    )

    $result = @()

    $tempZonesFile = $null

    # Cache the fetched markers to reduce load

    $tempFolderPath = Join-Path $Env:Temp 'uwmc.ps'
    if (!(Test-Path -Path $tempFolderPath)) {
        New-Item -Type Directory -Path $tempFolderPath | Out-Null
    }

    $tempFilePath = Join-Path $tempFolderPath 'zones.json'
    if (Test-Path -Path $tempFilePath) {
        $tempZonesFile = Get-ChildItem -Path $tempFilePath
        $lastModificationDate = $tempZonesFile.LastWriteTime
    }

    if ($null -eq $lastModificationDate) {
        Invoke-WebRequest -Uri "$($env:UWMCPS_ZONESURL)" -OutFile $tempFilePath
    } else {
        $utcTimestamp = ($lastModificationDate).ToUniversalTime().ToString("o"); # Convert to ISO timestamp
        $rfcUtcTimestamp = [System.DateTimeOffset]::Parse($utcTimestamp).ToString("r"); # Convert to to RFC timestamp
        $webRequest = Invoke-WebRequest -Uri "$($env:UWMCPS_ZONESURL)" -Headers @{ 'If-Modified-Since' = $rfcUtcTimestamp } | Out-Null

        if ($webRequest.StatusCode -eq 304) {
            # No update
        } elseif ($webRequest.StatusCode -eq 200) {
            $webRequest.Content | Out-File -FilePath $tempFilePath
        }
    }

    $zonesJson = Get-Content -Path $tempFilePath | ConvertFrom-Json

    $serverZones = $zonesJson | Select-Object -ExpandProperty 'sets' | Select-Object -ExpandProperty 'Serverzonen' | Select-Object -ExpandProperty 'areas'
    $playerZones = $zonesJson | Select-Object -ExpandProperty 'sets' | Select-Object -ExpandProperty 'Spielerzonen' | Select-Object -ExpandProperty 'areas'
    $newbieZones = $zonesJson | Select-Object -ExpandProperty 'sets' | Select-Object -ExpandProperty 'Neulingszonen' | Select-Object -ExpandProperty 'areas'

    $var = 1
    foreach ($serverZone in $serverZones) {
        $result += [UwZone]::new($var++, $serverZone.label, $serverZone.markup, $serverZone.x.0, $serverZone.y.0, $serverZone.x.1, $serverZone.y.1, $serverZone.ybottom, $serverZone.ytop, $serverZone.color, $serverZone.opacity, $serverZone.fillopacity, $serverZone.weight);
    }

    return $result;
}