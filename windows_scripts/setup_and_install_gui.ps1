# Starts by making sure the app is set up
Write-Host "`n# SETTING UP iDotMatrix #"
Write-Host "NOTE: If something goes wrong, try running the script with an administrator instance of Powershell."


$root = Resolve-Path -Path "$PSScriptRoot\.."

cd "$root"
if (-not $?) {
    Write-Host "\nERROR: Failed to navigate to root of repository"
    pause
    exit
}


Write-Host "`n## PYTHON SETUP ##"
Write-Host "`n### VERIFYING LAUNCH DIRECTORY ###"
Write-Host "INFO: Launching from $PSScriptRoot"
Write-Host "INFO: Assuming $root is the root of the git repository."

$GuiFileFound = Test-Path -Path ".\gui.py"
if (-not $GuiFileFound) {
    Write-Host "`nERROR: gui.py not found. `nThis means that the script wasn't launched from the correct folder.`n"
    Write-Host "`nTo work correctly, you need to launch this script from the root folder of the iDotMatrix git folder."
    Write-Host "`nTo do this, open the folder this script is located in in Windws Explorer, right click the script, and press 'Run in powershell'.`n"
    Write-Host "`nIf that doesn't work, either open a powershell window and cd to the folder, or open the iDotMatrix git folder in Windows Explorer, then shift-right-click inside in an empty spot in the folder window, and click 'Open in powershell'."
    Write-Host "`nWith powershell open, write .\windows_scripts\setup_and_make_launcher.ps1 and press enter"
    pause
    exit
}

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
$py_cmd = "$root/run_in_venv.ps1"

Write-Host "`n### OPENING/MAKING VENV & INSTALLING DEPENDENCIES ###"
& $py_cmd -DontInvokeApp -m pip install pyqt5 requests numpy


Write-Host "`n## CREATING LAUNCHER SHORTCUT ##"
Write-Host "This script will now create the shortcut on your desktop and in Windows list of programs if possible."

$WshShell = New-Object -COMObject WScript.Shell

$ShortcutRoot = "$Home\Desktop"
$ShortcutRootFound = Test-Path -Path "$ShortcutRoot"
if (-not $ShortcutRootFound) {
    Write-Host "`nERROR: Your desktop couldn't be found by the script, the shortcut will be placed in the same folder as this script instead."
    $ShortcutRoot = "$PSScriptRoot"
}

$ShortcutPath = "$ShortcutRoot\iDotMatrix GUI.lnk"


$Shortcut = $WshShell.CreateShortcut("$ShortcutPath")
$Shortcut.TargetPath = "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe"

$userInput = Read-Host -Prompt "`nCHOICE: Do you want the terminal to be hidden when launching the GUI?`n[y/n]"
if ($userInput -eq "y") {
    $Shortcut.Arguments = "-WindowStyle Hidden -File `"$PSScriptRoot\gui.ps1`""
    Write-Host "INFO: The launcher shortcut will now hide its terminal after opening. If the GUI isn't opening, re-run this script without hiding the terminal, so you can see what went wrong."
} else {
    $Shortcut.Arguments = "-File `"$PSScriptRoot\gui.ps1`""  #-WindowStyle Hidden 
}

$Shortcut.IconLocation = "$root\idmc.ico"
$Shortcut.WorkingDirectory = split-path -parent $MyInvocation.MyCommand.Definition
$Shortcut.Save()

$ProgramsPath = "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
if (Test-Path -Path "$ProgramsPath") {
    Write-Host "INFO: Copying shortcut to make it register as an app, to the path: $ProgramsPath"
    Copy-Item "$ShortcutPath" -Destination "$ProgramsPath"
} else {
    Write-Host "ERROR: Couldn't find your program folder. You can copy the shortcut to this folder manually instead, the path should look like this, but possibly with a different drive letter: $ProgramsPath"
}

Write-Host "`n## FINISHED ##"

Write-Host "`n### OPTIONAL TROUBLESHOOTING ###"
Write-Host "- If something went wrong with the shortcut, try running the script with an administrator instance of Powershell, as Windows might require this for making the shortcut."
Write-Host "- If some commands in the script fails, first re-run without a hidden terminal if you chose to hide it, to see the errors."
Write-Host "- If that doesn't help, make sure you have Python installed, and see if you can open the GUI manually through powershell, by copying the commands in this file that start with `"python`"."
Write-Host "`n### SUMMARY ###"
Write-Host "A shortcut should now have been created on your desktop, and a copy of it added to $ProgramsPath to make the program searchable, unless the log above states otherwise."
Write-Host "Try opening it, if the shortcut isn't there or nothing shows up, read the TROUBLESHOOTING section above."
Write-Host "`n`n"

pause
