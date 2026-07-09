param(
    [string]$InstallDir = $null
)

if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess) {
    $PowerShell64 = "$env:WINDIR\SysNative\WindowsPowerShell\v1.0\powershell.exe"
    & $PowerShell64 -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath @args
    exit $LASTEXITCODE
}

$ScriptPath = $PSScriptRoot
if (-not $ScriptPath) { $ScriptPath = $PWD.Path }

$ProgramFilesRoot = ${env:ProgramW6432}
if (-not $ProgramFilesRoot) { $ProgramFilesRoot = ${env:ProgramFiles} }
if (-not $ProgramFilesRoot) { $ProgramFilesRoot = ${env:ProgramFiles(x86)} }

if (-not $InstallDir) {
    $InstallDir = Join-Path -Path $ProgramFilesRoot -ChildPath "ANSYS Inc"
}

if (!(Test-Path -Path "C:\ITD\Logs")) {
    New-Item -Path "C:\ITD\Logs" -ItemType Directory -Force | Out-Null
}

$AppName = "Ansys Fluids"
$AppVersion = "2026 R1"
$AppFullName = $AppName + "_2026_R1"
$InstallLog = "C:\ITD\Logs\" + $AppFullName + "_script_install.log"

$BuildRoot = Join-Path -Path $ScriptPath -ChildPath "build"
$Installer = $null
foreach ($Candidate in @("setup.exe", "AnsysInstaller.exe")) {
    $CandidatePath = Get-ChildItem -Path $BuildRoot -Recurse -File -Filter $Candidate -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($CandidatePath) {
        $Installer = $CandidatePath.FullName
        break
    }
}

Start-Transcript -Path $InstallLog -Append -NoClobber
Write-Host "$(Get-Date) * Starting install of $AppFullName *"
Write-Host "$(Get-Date) * Application version: $AppVersion *"
Write-Host "$(Get-Date) * Script path: $ScriptPath *"
Write-Host "$(Get-Date) * Host process: $([Environment]::Is64BitProcess) / OS: $([Environment]::Is64BitOperatingSystem) *"
Write-Host "$(Get-Date) * Program Files root: $ProgramFilesRoot *"
Write-Host "$(Get-Date) * Build root: $BuildRoot *"
Write-Host "$(Get-Date) * Install directory: $InstallDir *"
Write-Host "$(Get-Date) * Searching for installer under build: setup.exe, AnsysInstaller.exe *"

if (!(Test-Path -Path $Installer -PathType Leaf)) {
    Write-Host "$(Get-Date) Installer not found: $Installer"
    Stop-Transcript
    $Host.SetShouldExit(2)
    EXIT 2
}

Write-Host "$(Get-Date) * Installer found: $Installer *"
Write-Host "$(Get-Date) * Ensuring install directory exists *"
New-Item -Path $InstallDir -ItemType Directory -Force | Out-Null
Write-Host "$(Get-Date) * Install directory ready: $InstallDir *"

$Arguments = @(
    "-silent"
    "-install_dir"
    "`"$InstallDir`""
)

Write-Host "$(Get-Date) * Launching installer *"
Write-Host "$(Get-Date) * Arguments: $($Arguments -join ' ') *"

$Install = Start-Process -FilePath $Installer -Wait -ArgumentList $Arguments -PassThru
$SuccessExitCodes = @(0, 3010)

if ($SuccessExitCodes -notcontains $Install.ExitCode) {
    Write-Host "$(Get-Date) $AppFullName install failed. Exit Code: $($Install.ExitCode)"
} else {
    Write-Host "$(Get-Date) $AppFullName install succeeded. Exit Code: $($Install.ExitCode)"
}

Write-Host "$(Get-Date) * Ending install transcript *"
Stop-Transcript
$Host.SetShouldExit($Install.ExitCode)
EXIT $Install.ExitCode
