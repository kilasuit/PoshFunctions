function Install-OfficeDevPnPPowerShell {
<#
.Synopsis
   This Function will Check and see if PowerShellGet (aka PowerShellPackageManagement) is installed on your system and then will install the Office Dev PnP PowerShell Cmdlets 
   from the PowerShell Gallery
.DESCRIPTION
   This uses Invoke-Expression which should be used with care in any case and if you are not happy to proceed from here then please run the scripts referenced individually
   .EXAMPLE
   Install-OfficeDevPnPPowerShell
   #>

#Requires -Version 3.0
[Cmdletbinding()]
param()

Invoke-Expression (New-Object Net.WebClient).DownloadString('http://bit.ly/PSPackManInstall') # We use this to install the PowerShell Package Manager for the PowerShell Gallery
Invoke-Expression (New-Object Net.WebClient).DownloadString('http://bit.ly/ODevPnPPowerShellHelper1')
}
Install-OfficeDevPnPPowerShell