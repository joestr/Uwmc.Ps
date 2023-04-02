class UwZone {
    [int] $Id
    [UwZoneType] $ZoneType
    [string] $Label
    [bool] $Markup
    [double] $FirstX
    [double] $FirstZ
    [double] $SecondX
    [double] $SecondZ
    [int] $YBottom
    [int] $YTop
    [string] $Color
    [int] $Opacity
    [double] $FillOpacity
    [int] $Weight
    UwZone($Id, $ZoneType, $Label, $Markup, $FirstX, $FirstZ, $SecondX, $SecondZ, $YBottom, $YTop, $Color, $Opacity, $FillOpacity, $Weight) {
        $this.Id = $Id
        $this.ZoneType = $ZoneType
        $this.Label = $Label
        $this.Markup = $Markup
        $this.FirstX = $FirstX
        $this.FirstZ = $FirstZ
        $this.SecondX = $SecondX
        $this.SecondZ = $SecondZ
        $this.YBottom = $YBottom
        $this.YTop = $YTop
        $this.Color = $Color
        $this.Opacity = $Opacity
        $this.FillOpacity = $FillOpacity
        $this.Weight = $Weight
    }
}

enum UwZoneType {
    PlayerZone = 1
    ServerZone = 2
    NewbieZone = 3
}

function Get-Zones {
    [OutputType([UwZone])]
    param(
        [parameter(ParameterSetName = "SetA", Mandatory = $false)][switch] $ForceRefresh = $false
    )

    $result = @()

    $tempFolderPath = Join-Path $env:HOME '.uwmc.ps'

    # Cache the fetched markers to reduce load
    if (!(Test-Path -Path $tempFolderPath)) {
        New-Item -Type Directory -Path $tempFolderPath | Out-Null
    }

    $tempDynMapMarkerFilePath = Join-Path $tempFolderPath 'zones_dynmap.json'

    if (Test-Path -Path $tempDynMapMarkerFilePath) {
        $lastModificationDate = (Get-ChildItem -Path $tempDynMapMarkerFilePath).LastWriteTime
    }

    if ($null -eq $lastModificationDate -or $true -eq $ForceRefresh) {
        Invoke-WebRequest -Uri "$($env:UWMCPS_ZONESURL)" -OutFile $tempDynMapMarkerFilePath | Out-Null
    } else {
        $utcTimestamp = ($lastModificationDate).ToUniversalTime().ToString("o"); # Convert to ISO timestamp
        $rfcUtcTimestamp = [System.DateTimeOffset]::Parse($utcTimestamp).ToString("r"); # Convert to to RFC timestamp
        ($webRequest = Invoke-WebRequest -Uri "$($env:UWMCPS_ZONESURL)" -Headers @{ 'If-Modified-Since' = $rfcUtcTimestamp } -SkipHttpErrorCheck) | Out-Null

        if ($webRequest.StatusCode -eq 304) {
            # No update
        } elseif ($webRequest.StatusCode -eq 200) {
            $webRequest.Content | Out-File -FilePath $tempDynMapMarkerFilePath
        }
    }

    $tempZonesFilePath = Join-Path $tempFolderPath 'zones_parsed.json'

    if ($null -eq $lastModificationDate -or $lastModificationDate -lt (Get-ChildItem -Path $tempDynMapMarkerFilePath).LastWriteTime -or !(Test-Path -Path $tempZonesFilePath) -or $true -eq $ForceRefresh) {
        $zonesJson = Get-Content -Path $tempDynMapMarkerFilePath | ConvertFrom-Json

        $serverZones = $zonesJson | Select-Object -ExpandProperty 'sets' | Select-Object -ExpandProperty 'Serverzonen' | Select-Object -ExpandProperty 'areas'
        $playerZones = $zonesJson | Select-Object -ExpandProperty 'sets' | Select-Object -ExpandProperty 'Spielerzonen' | Select-Object -ExpandProperty 'areas'
        $newbieZones = $zonesJson | Select-Object -ExpandProperty 'sets' | Select-Object -ExpandProperty 'Neulingszonen' | Select-Object -ExpandProperty 'areas'
    
        Get-UwZoneObjectsFromAreasJson -AreasJson $serverZones -ZoneType ServerZone | ForEach-Object {
            $result += $_
        }
    
        Get-UwZoneObjectsFromAreasJson -AreasJson $playerZones -ZoneType PlayerZone | ForEach-Object {
            $result += $_
        }
    
        Get-UwZoneObjectsFromAreasJson -AreasJson $newbieZones -ZoneType NewbieZone | ForEach-Object {
            $result += $_
        }

        $result | ConvertTo-Json | Out-File $tempZonesFilePath
    } else {
        $result = Get-Content -Path $tempZonesFilePath | ConvertFrom-Json
    }

    return $result;
}

function Get-UwZoneObjectsFromAreasJson {
    [OutputType([UwZone])]
    param (
        [object] $AreasJson,
        [UwZoneType] $ZoneType
    )

    $result = @()

    $areaMembers = $AreasJson | Get-Member -MemberType NoteProperty
    $areaMembersCount = $areaMembers | Measure-Object | Select-Object -ExpandProperty Count

    $areasCounter = 0
    while ($areasCounter -lt $areaMembersCount) {
        $zone = $AreasJson | Select-Object -ExpandProperty ($areaMembers[$areasCounter]).Name
        $zoneId = [int]($areaMembers[$areasCounter]).Name.Replace('uwzone_', '')
        $zoneFirstX = $zone.x[0]
        $zoneFirstZ = $zone.z[0]
        $zoneSecondX = $zone.x[1]
        $zoneSecondZ = $zone.z[1]
        $result += [UwZone]::new($zoneId, $ZoneType, $zone.label, $zone.markup, $zoneFirstX, $zoneFirstZ, $zoneSecondX, $zoneSecondZ, $zone.ybottom, $zone.ytop, $zone.color, $zone.opacity, $zone.fillopacity, $zone.weight);
        $areasCounter++
    }

    return $result;
}
