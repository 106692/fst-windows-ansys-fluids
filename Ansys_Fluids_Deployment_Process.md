# Ansys Fluids 2026 R1 - What To Pass To DE

This package should be reviewed against the application packaging criteria before upload.

Reviewed source locations:

- Main install package:
  `C:\Users\106692\Documents\Codex\2026-06-22\dfdf\outputs\Ansys_Fluids_Package\src`
- Separate uninstall package:
  `C:\Users\106692\Documents\Codex\2026-06-22\dfdf\outputs\Ansys_Fluids_Uninstall_Package\src`

Intune packaging notes:

- Main install app remains the normal Company Portal install tile
- Uninstall is provided as a separate Company Portal tile
- Main install detection stays based on `fluent.exe`
- Separate uninstall tile uses a custom detection script that succeeds only when `fluent.exe` is gone

## Main Install App

Name of app

- `Ansys Fluids 2026 R1`

Description for user

- `Installs Ansys Fluids 2026 R1 on your managed device. Use the separate Remove Ansys Fluids 2026 R1 tile in Company Portal if you need to uninstall it.`

Publisher

- `Ansys`

App version

- `2026 R1`

Logo (.png file)

- `C:\Users\106692\Documents\Codex\2026-06-22\dfdf\outputs\Ansys_Fluids_Package\src\Ansys_Fluids_2026_R1_Icon.png`

Any notes

- Main Company Portal tile is install-only
- Set `Allow available uninstall` to `No`
- Main package uninstall script is intentionally a no-op that returns success
- Keep installation detection unchanged using `fluent.exe`
- If the main package content is updated, rebuild and re-upload the install `.intunewin`

Install command e.g. Powershell.exe -ExecutionPolicy Bypass -Windowstyle Hidden -File "" (32 bit) for 64 bit

- `%windir%\SysNative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -NoLogo -NoProfile -File ".\Ansys_Fluids_2026_R1_Install.ps1"`

Uninstall command powershell.exe -ExecutionPolicy bypass -WindowStyle Hidden -NoLogo -NoProfile -File "" for 64 bit

- `%windir%\SysNative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -NoLogo -NoProfile -File ".\Ansys_Fluids_2026_R1_Uninstall.ps1"`

Any system requirements

- Windows 64-bit device
- Run in `System` context

Detection rules

- Rule type: `File`
- Path: `C:\Program Files\ANSYS Inc\v261\fluent\ntbin\win64`
- File or folder: `fluent.exe`
- Detection method: `File version`
- Operator: `Equals`
- Version: `26.1.0.0`
- Associated with a 32-bit app on 64-bit clients: `No`

Any dependancies on another app

- `None`

Group (please create/ have one in mind prior to getting app created/ uploaded)

- `FST | Software | Ansys Fluids`

## Separate Uninstall App

Name of app

- `Remove Ansys Fluids 2026 R1`

Description for user

- `Removes Ansys Fluids 2026 R1 from your managed device. Use this tile only if the main Ansys Fluids 2026 R1 app is already installed.`

Publisher

- `Ansys`

App version

- `2026 R1`

Logo (.png file)

- `C:\Users\106692\Documents\Codex\2026-06-22\dfdf\outputs\Ansys_Fluids_Package\src\Ansys_Fluids_2026_R1_Icon.png`

Any notes

- This is a separate Company Portal tile for uninstall
- Package is script-only and small
- Detection is a custom script that succeeds only when `fluent.exe` and `AWP_ROOT261` are gone
- No requirement script is used
- If the uninstall package content changes, rebuild and re-upload the uninstall `.intunewin`
- Current uninstall `.intunewin`:
  `C:\Users\106692\Documents\Codex\2026-06-22\dfdf\outputs\Ansys_Fluids_Uninstall_Package\Ansys_Fluids_2026_R1_Uninstall.intunewin`

Install command e.g. Powershell.exe -ExecutionPolicy Bypass -Windowstyle Hidden -File "" (32 bit) for 64 bit

- `%windir%\SysNative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -NoLogo -NoProfile -File ".\Ansys_Fluids_2026_R1_Uninstall.ps1"`

Uninstall command powershell.exe -ExecutionPolicy bypass -WindowStyle Hidden -NoLogo -NoProfile -File "" for 64 bit

- `%windir%\SysNative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -NoLogo -NoProfile -File ".\Ansys_Fluids_2026_R1_Uninstall.ps1"`

Any system requirements

- Windows 64-bit device
- Run in `System` context

Detection rules

- Rule type: `Custom detection script`
- Script:
  `C:\Users\106692\Documents\Codex\2026-06-22\dfdf\outputs\Ansys_Fluids_Uninstall_Package\src\Ansys_Fluids_2026_R1_Uninstall_Detection.ps1`
- Run script as 32-bit process on 64-bit clients: `No`

Detection script logic:

- If `C:\Program Files\ANSYS Inc\v261\fluent\ntbin\win64\fluent.exe` exists, detection fails
- If `AWP_ROOT261` still exists, detection fails
- If both are absent, detection succeeds

Any dependancies on another app

- `None`

Group (please create/ have one in mind prior to getting app created/ uploaded)

- `FST | Software | Ansys Fluids`

## Files to provide to DE

Main install package files:

- `C:\Users\106692\Documents\Codex\2026-06-22\dfdf\outputs\Ansys_Fluids_Package\src\Ansys_Fluids_2026_R1_Install.ps1`
- `C:\Users\106692\Documents\Codex\2026-06-22\dfdf\outputs\Ansys_Fluids_Package\src\Ansys_Fluids_2026_R1_Uninstall.ps1`
- `C:\Users\106692\Documents\Codex\2026-06-22\dfdf\outputs\Ansys_Fluids_Package\src\Ansys_Fluids_2026_R1_Detection.ps1`
- `C:\Users\106692\Documents\Codex\2026-06-22\dfdf\outputs\Ansys_Fluids_Package\src\README.md`

Separate uninstall package files:

- `C:\Users\106692\Documents\Codex\2026-06-22\dfdf\outputs\Ansys_Fluids_Uninstall_Package\Ansys_Fluids_2026_R1_Uninstall.intunewin`
- `C:\Users\106692\Documents\Codex\2026-06-22\dfdf\outputs\Ansys_Fluids_Uninstall_Package\src\Ansys_Fluids_2026_R1_Uninstall.ps1`
- `C:\Users\106692\Documents\Codex\2026-06-22\dfdf\outputs\Ansys_Fluids_Uninstall_Package\src\Ansys_Fluids_2026_R1_Uninstall_Detection.ps1`
- `C:\Users\106692\Documents\Codex\2026-06-22\dfdf\outputs\Ansys_Fluids_Uninstall_Package\src\README.md`
