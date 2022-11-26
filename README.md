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

![Image showing command usage.](https://i.paste.pics/8c821eff9589f665063ec44bfd84d384.png)

### Get player votes

Commandlet: `Get-UwPlayerVotes`
Arguments: `-IncludePlayerUid` → tries to resolve player names to their UUID; represented in the `PlayerUid` field or else `$null`
Returns: An array of player votes.

![Image showing command usage.](https://i.paste.pics/c5ccfe39cefd09feafe97a4495396fe3.png)