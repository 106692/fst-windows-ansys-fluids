# Ansys Fluids Package Scripts

These scripts follow the same simple, logged, silent-install pattern as the Leximancer package.

Use this package for the main install tile in Company Portal.

## Folder layout

```text
src
  Ansys_Fluids_2026_R1_Install.ps1
  Ansys_Fluids_2026_R1_Uninstall.ps1
  Ansys_Fluids_2026_R1_Detection.ps1
  Ansys_Fluids_2026_R1_Icon.png
  build
    FLUIDS_2026R1_WINX64
      setup.exe
      ...
```

## Behaviour

- Re-runs itself through 64-bit PowerShell on 64-bit Windows if launched from a 32-bit host
- Writes script transcripts to `C:\ITD\Logs`
- Uses `setup.exe` or `AnsysInstaller.exe` from `src\build` and its subfolders
- Runs the installer in silent mode
- Uses a local custom detection script for Intune
- Includes a no-op uninstall script for the main install app
- Resolves the install path from the 64-bit Program Files root first (`%ProgramW6432%`), then falls back to the other Program Files variables

## Assumptions

- The package name/version shown in logs is `Ansys Fluids_2026_R1`
- The target release folder is `C:\Program Files\ANSYS Inc\v261`
- If your media targets a different release, update the default `Install Dir` in the install script.

## Detection method

Preferred for Intune:

- Rule type: Custom detection script
- Script: `Ansys_Fluids_2026_R1_Detection.ps1`
- Run script as 32-bit process on 64-bit clients: `No`

This script checks both:

- `HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\AWP_ROOT261`
- `C:\Program Files\ANSYS Inc\v261\fluent\ntbin\win64\fluent.exe`

Fallback file rule if you want to keep the built-in UI detection:

- Rule type: File
- Path: `C:\Program Files\ANSYS Inc\v261\fluent\ntbin\win64`
- File or folder: `fluent.exe`
- Detection method: File version
- Operator: Equals
- Version: `26.1.0.0`
- Associated with a 32-bit app on 64-bit clients: `No`

Simplest built-in file exists rule:

- Rule type: File
- Path: `C:\Program Files\ANSYS Inc\v261\fluent\ntbin\win64`
- File or folder: `fluent.exe`
- Detection method: File or folder exists
- Associated with a 32-bit app on 64-bit clients: `No`

## Main app uninstall setting

- In Intune, set `Allow available uninstall` to `No` for the main install app
- The bundled `Ansys_Fluids_2026_R1_Uninstall.ps1` now returns success without removing anything
- This keeps the Company Portal install tile from presenting a functional uninstall path

## Separate uninstall tile

Use the separate package at:

- `C:\Users\106692\Documents\Codex\2026-06-22\dfdf\outputs\Ansys_Fluids_Uninstall_Package`

This keeps install and uninstall as two separate Company Portal tiles.
