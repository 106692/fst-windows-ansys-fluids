if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess) {
    $PowerShell64 = "$env:WINDIR\SysNative\WindowsPowerShell\v1.0\powershell.exe"
    & $PowerShell64 -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath
    exit $LASTEXITCODE
}

$MarkerFile = "C:\ProgramData\IntuneMarkers\Ansys_Fluids_2026_R1\Uninstalled.tag"
$FluentExe = "C:\Program Files\ANSYS Inc\v261\fluent\ntbin\win64\fluent.exe"
$EnvironmentKeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
$AwpRootName = "AWP_ROOT261"

$AwpRoot = $null
if (Test-Path -Path $EnvironmentKeyPath) {
    $EnvironmentValues = Get-ItemProperty -Path $EnvironmentKeyPath -ErrorAction SilentlyContinue
    $AwpRoot = $EnvironmentValues.$AwpRootName
}

$AppStillInstalled = $false
if (Test-Path -Path $FluentExe -PathType Leaf) { $AppStillInstalled = $true }
if ($AwpRoot) { $AppStillInstalled = $true }

if (-not $AppStillInstalled) {
    Write-Output "Detected Ansys Fluids 2026 R1 as removed"
    exit 0
}

exit 1
