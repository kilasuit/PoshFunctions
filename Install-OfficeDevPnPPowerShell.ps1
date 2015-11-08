Invoke-Expression (New-Object Net.WebClient).DownloadString('http://bit.ly/PSPackManInstall') # We use this to install the PowerShell Package Manager for the PowerShell Gallery
Start-Sleep 120
Invoke-Expression (New-Object Net.WebClient).DownloadString('http://bit.ly/ODevPnPPowerShellHelper1')