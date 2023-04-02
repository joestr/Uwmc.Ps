# Uwmc.Ps

A PowerShell module to interact with services provided by UWMC (Unlimitedworld).

## Installation

1. First, get a copy of this repository. Preferably via `git clone https://github.com/joestr/Uwmc.Ps.git`.
2. Navigate to the cloned repository with `cd Uwmc.Ps`
3. Import the module within PowerShell: `Import-Module ./source/Uwmc.Ps.psd1`

## Usage

### Get online players

Commandlet: `Get-UwOnlinePlayers`  
Arguments: `-IncludePlayerUid` → tries to resolve player names to their UUID; represented in the `PlayerUid` field or else `$null`  
Returns: An array of online players.  

*Example*: `Get-UwOnlinePlayers | Where-Object -Property -LE 30`
![Searching for players where the sorting priority is less or equal to 30.](https://i.paste.pics/8c821eff9589f665063ec44bfd84d384.png)

### Get player votes

Commandlet: `Get-UwPlayerVotes`  
Arguments: `-IncludePlayerUid` → tries to resolve player names to their UUID; represented in the `PlayerUid` field or else `$null`  
Returns: An array of player votes.  

*Example*: `Get-UwPlayerVotes | Where-Object -Property PlayerName -In @("joestr")`
![Searching for votes from player joestr.](https://i.paste.pics/c5ccfe39cefd09feafe97a4495396fe3.png)

### Get zones

Commandlet: `Get-UwZones`  
Arguments `ForceRefresh` → Forcibly renew cached content  
Returns: An array of zones.

*Example*: `Get-UwZones | Where-Object Id -EQ 101695`
![Searching for zone with id 101695.](https://i2.paste.pics/6316a456acc60f1fa425560b92a57353.png)

*Example*: `Get-UwZones | Where-Object ZoneType -EQ 1 | Where-Object Label -Like '*TMD#1*'`
![Searching for player zones where its label contains a wildcard match againts string 'TMD#1'.](https://i2.paste.pics/89bbe85b819702d7c60866818248b4b9.png)
