param (
    [string] $romName
)

[object] $Settings = Get-Content (Join-Path $PSScriptRoot "settings.json") -Raw | ConvertFrom-Json

if ($romName -eq "") {
    & (Join-Path $Settings.MugenDirectory $Settings.MugenExe)
    exit
}

function CreateDirLink([string] $link, [string] $dest) {
    if (Test-Path $link) {        
        Rename-Item $link "$(Split-Path $link -Leaf).bak"
    }
    
    Start-Process "cmd" -ArgumentList "/c", "mklink", "/d", "`"$link`"", "`"$dest`"" -Wait -NoNewWindow
}

function RestoreDir([string] $dir) {
    Start-Process "cmd" -ArgumentList "/c", "rd", "`"$dir`"" -Wait -NoNewWindow
    [string] $backup = "$dir.bak"

    if (Test-Path $backup) {
        Rename-Item $backup (Split-Path $dir -Leaf)
    }
}

[string] $romDirectory = Split-Path $romName -Parent

$Settings.DirectoriesToReplace | ForEach-Object { CreateDirLink (Join-Path $Settings.MugenDirectory $_) (Join-Path $romDirectory $_) }
[string] $dataToReplacePath = Join-Path (Join-Path $Settings.MugenDirectory $Settings.DataDir) $Settings.DataDirToReplace
CreateDirLink $dataToReplacePath (Join-Path $romDirectory $Settings.DataDirToReplace)

Push-Location $Settings.MugenDirectory
Start-Process $Settings.MugenExe -Wait
Pop-Location

$Settings.DirectoriesToReplace | ForEach-Object { RestoreDir (Join-Path $Settings.MugenDirectory $_) }
RestoreDir $dataToReplacePath