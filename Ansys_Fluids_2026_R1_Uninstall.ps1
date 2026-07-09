if (!(Test-Path -Path "C:\ITD\Logs")) {
    New-Item -Path "C:\ITD\Logs" -ItemType Directory -Force | Out-Null
}

$AppFullName = "Ansys Fluids_2026_R1"
$UninstallLog = "C:\ITD\Logs\" + $AppFullName + "_script_uninstall.log"

Start-Transcript -Path $UninstallLog -Append -NoClobber
Write-Host "$(Get-Date) * $AppFullName uninstall was intentionally disabled for the main Company Portal install app. *"
Write-Host "$(Get-Date) * This script returns success so the install app does not attempt a package-based uninstall. *"
Write-Host "$(Get-Date) * Use the separate removal process if uninstall is required. *"
Stop-Transcript
exit 0
