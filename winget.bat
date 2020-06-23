@echo off
REM -- GENERAL APPS
winget install AgileBits.1Password
winget install --id Discord.Discord --exact
winget install ExpressVPN.ExpressVPN
winget install --id Mozilla.Firefox --exact
winget install --id Google.Chrome --exact
REM Manual: Google Backup and Sync
REM Manual: Logitech Options (MX Master 2S)
winget install Notion.Notion
REM Manual: Raindrop.io
winget install Signal.Signal
winget install SlackTechnologies.Slack
winget install Spotify.Spotify
REM Manual: Synology Assistant
winget install VideoLAN.VLC

REM -- GENERAL DEVELOPER APPS
winget install --id Docker.DockerDesktop --exact
winget install Microsoft.VisualStudioCode
REM winget install Microsoft.WindowsTerminal
winget install Microsoft.PowerToys
REM Manual: Git client? Sublime Merge? Atlassian Sourcetree?
REM Manual: FTP client?
REM -- WEB DEVELOPER APPS
winget install Mozilla.FirefoxDeveloperEdition
winget install MongoDB.Compass.Community
REM Manual: Charles Proxy
REM Insomnia had issues as currently installed v7, not Core 2020
REM winget install --id Insomnia.Insomnia --exact
REM Manual: TablePlus

REM -- GAMING APPS
winget install GOG.Galaxy
winget install Valve.Steam
REM winget install Libretro.RetroArch

