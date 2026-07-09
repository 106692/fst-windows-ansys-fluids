if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess) {
    $powerShell64 = "$env:WINDIR\SysNative\WindowsPowerShell\v1.0\powershell.exe"
    & $powerShell64 -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath
    exit $LASTEXITCODE
}

$envKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
$awpRoot = $null

if (Test-Path $envKey) {
    $envProps = Get-ItemProperty -Path $envKey -ErrorAction SilentlyContinue
    $awpRoot = $envProps.AWP_ROOT261
}

if (-not $awpRoot) {
    $awpRoot = "C:\Program Files\ANSYS Inc\v261"
}

$fluentExe = Join-Path -Path $awpRoot -ChildPath "fluent\ntbin\win64\fluent.exe"

if ((Test-Path -Path $awpRoot) -and (Test-Path -Path $fluentExe -PathType Leaf)) {
    Write-Output "Detected Ansys Fluids 2026 R1"
    exit 0
}

exit 1
