param(
    [string]$InstallRoot = $null,
    [string]$VersionRoot = $null
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

$EnvironmentKeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
$AwpRootName = "AWP_ROOT261"
$AnsysDirName = "ANSYS261_DIR"

if (Test-Path -Path $EnvironmentKeyPath) {
    $EnvironmentValues = Get-ItemProperty -Path $EnvironmentKeyPath -ErrorAction SilentlyContinue
} else {
    $EnvironmentValues = $null
}

if (-not $VersionRoot) {
    $VersionRoot = $EnvironmentValues.$AwpRootName
}
if (-not $VersionRoot) {
    $VersionRoot = Join-Path -Path $ProgramFilesRoot -ChildPath "ANSYS Inc\v261"
}

if (-not $InstallRoot) {
    $InstallRoot = $VersionRoot
}
if (-not $InstallRoot) {
    $InstallRoot = Join-Path -Path $ProgramFilesRoot -ChildPath "ANSYS Inc\v261"
}

if (!(Test-Path -Path "C:\ITD\Logs")) {
    New-Item -Path "C:\ITD\Logs" -ItemType Directory -Force | Out-Null
}

$AppName = "Ansys Fluids"
$AppVersion = "2026 R1"
$AppFullName = $AppName + "_2026_R1"
$UninstallLog = "C:\ITD\Logs\" + $AppFullName + "_script_uninstall.log"
$FluentExe = Join-Path -Path $VersionRoot -ChildPath "fluent\ntbin\win64\fluent.exe"
$ProcessNames = @("fluent", "cfdpost", "cfx5pre", "cfx5solver", "icemcfd", "runwb2", "ansysedt")
$ShortcutRoots = @(
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Ansys 2026 R1",
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Fluid Dynamics"
)

$CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal($CurrentIdentity)
$IsAdmin = $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

function Stop-AnsysProcesses {
    param([string]$Stage)
    foreach ($ProcessName in $ProcessNames) {
        Get-Process -Name $ProcessName -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "$(Get-Date) Stopping process $($_.ProcessName) (PID $($_.Id)) during $Stage."
            Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
        }
    }
}

function Remove-EnvironmentValues {
    param(
        [string]$RegistryPath,
        [string[]]$PrefixPaths
    )

    if (!(Test-Path -Path $RegistryPath)) {
        return
    }

    $RegistryItem = Get-Item -Path $RegistryPath -ErrorAction SilentlyContinue
    if (-not $RegistryItem) {
        return
    }

    foreach ($PropertyName in $RegistryItem.GetValueNames()) {
        $Value = $RegistryItem.GetValue($PropertyName, $null, "DoNotExpandEnvironmentNames")
        if ($Value -isnot [string]) {
            continue
        }

        foreach ($PrefixPath in $PrefixPaths) {
            if ($PrefixPath -and $Value.StartsWith($PrefixPath, [System.StringComparison]::OrdinalIgnoreCase)) {
                Write-Host "$(Get-Date) Removing machine environment value $PropertyName -> $Value"
                try {
                    Remove-ItemProperty -Path $RegistryPath -Name $PropertyName -ErrorAction Stop
                } catch {
                    Write-Host "$(Get-Date) Failed to remove machine environment value $PropertyName : $($_.Exception.Message)"
                }
                break
            }
        }
    }
}

Start-Transcript -Path $UninstallLog -Append -NoClobber
Write-Host "$(Get-Date) * Starting uninstall of $AppFullName *"
Write-Host "$(Get-Date) * Application version: $AppVersion *"
Write-Host "$(Get-Date) * Script path: $ScriptPath *"
Write-Host "$(Get-Date) * Host process: $([Environment]::Is64BitProcess) / OS: $([Environment]::Is64BitOperatingSystem) *"
Write-Host "$(Get-Date) * Running as administrator: $IsAdmin *"
Write-Host "$(Get-Date) * Program Files root: $ProgramFilesRoot *"
Write-Host "$(Get-Date) * Install root: $InstallRoot *"
Write-Host "$(Get-Date) * Version root: $VersionRoot *"
Write-Host "$(Get-Date) * Fluent detection target: $FluentExe *"
Write-Host "$(Get-Date) * Using local uninstall workflow only. No package media is required. *"

if (-not $IsAdmin) {
    Write-Host "$(Get-Date) * Administrator rights are required to remove the Ansys install and machine environment values. *"
    Write-Host "$(Get-Date) * Ending uninstall transcript *"
    Stop-Transcript
    $Host.SetShouldExit(5)
    exit 5
}

Write-Host "$(Get-Date) * Checking for running Ansys processes *"
Stop-AnsysProcesses -Stage "pre-uninstall cleanup"
Write-Host "$(Get-Date) * Process scan complete *"

Write-Host "$(Get-Date) * Removing machine environment values that point into the Ansys install *"
Remove-EnvironmentValues -RegistryPath $EnvironmentKeyPath -PrefixPaths @($VersionRoot, $InstallRoot)

foreach ($ShortcutRoot in $ShortcutRoots) {
    if (Test-Path -Path $ShortcutRoot) {
        Write-Host "$(Get-Date) Removing shortcut folder: $ShortcutRoot"
        try {
            Remove-Item -Path $ShortcutRoot -Recurse -Force -ErrorAction Stop
        } catch {
            Write-Host "$(Get-Date) Failed to remove shortcut folder ${ShortcutRoot}: $($_.Exception.Message)"
        }
    }
}

if (Test-Path -Path $InstallRoot) {
    Write-Host "$(Get-Date) * Removing install root: $InstallRoot *"
    try {
        Remove-Item -Path $InstallRoot -Recurse -Force -ErrorAction Stop
    } catch {
        Write-Host "$(Get-Date) Failed to remove install root ${InstallRoot}: $($_.Exception.Message)"
    }
} else {
    Write-Host "$(Get-Date) Install root already absent: $InstallRoot"
}

if (Test-Path -Path (Split-Path -Path $InstallRoot -Parent)) {
    $ParentRoot = Split-Path -Path $InstallRoot -Parent
    $RemainingItems = @(Get-ChildItem -Path $ParentRoot -Force -ErrorAction SilentlyContinue)
    if ($RemainingItems.Count -eq 0) {
        Write-Host "$(Get-Date) Removing empty parent folder: $ParentRoot"
        try {
            Remove-Item -Path $ParentRoot -Recurse -Force -ErrorAction Stop
        } catch {
            Write-Host "$(Get-Date) Failed to remove empty parent folder ${ParentRoot}: $($_.Exception.Message)"
        }
    }
}

Write-Host "$(Get-Date) * Running final process cleanup *"
Stop-AnsysProcesses -Stage "post-uninstall cleanup"

$EnvironmentValuesAfter = $null
if (Test-Path -Path $EnvironmentKeyPath) {
    $EnvironmentValuesAfter = Get-ItemProperty -Path $EnvironmentKeyPath -ErrorAction SilentlyContinue
}

$MarkersRemain = $false
if (Test-Path -Path $InstallRoot) { $MarkersRemain = $true }
if (Test-Path -Path $VersionRoot) { $MarkersRemain = $true }
if (Test-Path -Path $FluentExe -PathType Leaf) { $MarkersRemain = $true }
if ($EnvironmentValuesAfter.$AwpRootName) { $MarkersRemain = $true }
if ($EnvironmentValuesAfter.$AnsysDirName) { $MarkersRemain = $true }

if ($MarkersRemain) {
    Write-Host "$(Get-Date) * Uninstall verification failed. One or more install markers are still present. *"
    Write-Host "$(Get-Date) * Ending uninstall transcript *"
    Stop-Transcript
    $Host.SetShouldExit(1)
    exit 1
}

Write-Host "$(Get-Date) * Uninstall verification succeeded. Install markers are absent. *"
Write-Host "$(Get-Date) * Ending uninstall transcript *"
Stop-Transcript
$Host.SetShouldExit(0)
exit 0
