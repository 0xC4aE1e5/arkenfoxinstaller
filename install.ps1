###VARIABLES###
# Essentials - Always on top.
$timeout = 10 # The amount of time that Firefox has to complete loading.
# Paths
$af = "$home\arkenfox" # the install path
$mozilla_appdata_profiles = "$home\AppData\Roaming\Mozilla\Firefox\Profiles" # the mozilla appdata path for profiles
$mozilla_appdata_top = "$home\AppData\Roaming\Mozilla" # the mozilla appdata path for profiles
###END VARIABLES###
Add-Type -AssemblyName PresentationCore, PresentationFramework
$continue = [Windows.MessageBox]::Show("This will download a fresh copy of Firefox, with arkenfox installed. This will delete all of your Firefox data, because arkenfox and Firefox conflict. Continue?", "Continue", 4, 32)
if ($continue -ne 6) {
    exit
}
Remove-Item -recurse -force $af
Remove-Item -recurse -force tmp
Remove-Item -recurse -force $mozilla_appdata_profiles
Remove-Item -recurse -force $mozilla_appdata_top
mkdir tmp
curl.exe -Lo tmp\firefox.exe "https://download.mozilla.org/?product=firefox-latest-ssl&os=win&lang=en-US"
curl.exe -Lo tmp\user.js "https://raw.githubusercontent.com/arkenfox/user.js/master/user.js"
Expand-Archive -Path 7z.zip -DestinationPath tmp
tmp\7z x tmp\firefox.exe -otmp
Move-Item -Path tmp\core -Destination $af
[Windows.MessageBox]::Show("Do not touch the upcoming Firefox window. It will close in $timeout seconds.", "Warning", 0, 48)
cmd /c "$af\firefox.exe"
Start-Sleep -s $timeout
taskkill /f /im firefox.exe

Push-Location $mozilla_appdata_profiles
Set-Location *.default-release
$loc = Get-Location
Pop-Location
$loc = $loc.Path
Copy-Item tmp\user.js $loc

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\arkenfox.lnk")
$Shortcut.TargetPath = "$af\firefox.exe"
$Shortcut.Save()

remove-item tmp -recurse -force

$run = [Windows.MessageBox]::Show("arkenfox is now installed & a shortcut has been created on your desktop. Would you like me to open arkenfox now?", "Open arkenfox?", 4, 32)

if ($run -eq 6) {
    Start-Process -FilePath "$af\firefox.exe"
}