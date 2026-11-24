# Installs 飙榜双语版 (Biaobang Bilingual) locally and adds a Desktop shortcut.
# Usage: right-click > Run with PowerShell, or:  powershell -ExecutionPolicy Bypass -File install.ps1
$ErrorActionPreference = 'Stop'

$src = $PSScriptRoot
$dest = Join-Path $env:LOCALAPPDATA 'Programs\Biaobang'
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Copy-Item -Force (Join-Path $src 'index.html') $dest
Copy-Item -Force (Join-Path $src 'assets\app.ico') $dest

$page = 'file:///' + ((Join-Path $dest 'index.html') -replace '\\', '/')

# Prefer Edge (ships with Windows), then Chrome; open in app-window mode.
$candidates = @(
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
)
$browser = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1

$desktop = [Environment]::GetFolderPath('Desktop')
$name = ([char]0x98D9) + ([char]0x699C) + ([char]0x53CC) + ([char]0x8BED) + ([char]0x7248)  # 飙榜双语版
$lnkPath = Join-Path $desktop ($name + '.lnk')
# WScript.Shell cannot save non-ANSI file names, so save under an ASCII name and rename.
$tmpLnk = Join-Path $desktop 'Biaobang-install-tmp.lnk'

$shell = New-Object -ComObject WScript.Shell
$lnk = $shell.CreateShortcut($tmpLnk)
if ($browser) {
    $lnk.TargetPath = $browser
    $lnk.Arguments = "--app=`"$page`""
} else {
    $lnk.TargetPath = Join-Path $dest 'index.html'
}
$lnk.WorkingDirectory = $dest
$lnk.IconLocation = (Join-Path $dest 'app.ico') + ',0'
$lnk.Description = 'Biaobang Bilingual - tier list maker'
$lnk.Save()
if (Test-Path -LiteralPath $lnkPath) { Remove-Item -LiteralPath $lnkPath -Force }
Move-Item -LiteralPath $tmpLnk -Destination $lnkPath

Write-Host "Installed to $dest"
Write-Host "Shortcut: $lnkPath"
