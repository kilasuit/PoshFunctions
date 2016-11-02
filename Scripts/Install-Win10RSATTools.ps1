<#PSScriptInfo

.VERSION 1.0

.GUID 0b6b6733-a339-401a-b804-d107534bca0e

.AUTHOR Ryan Yates

.COMPANYNAME Re-Digitise

.COPYRIGHT Re-Digitise Limited

.TAGS RSAT, Win10

.LICENSEURI https://github.com/kilasuit/poshfunctions/License

.PROJECTURI https://github.com/kilasuit/poshfunctions/

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES Released to PowerShell Gallery and updated with the latest Win10 RSAT Update 


#>

<# 

.DESCRIPTION 
 Installs RSAT Tools for Windows 10 

#>
function Install-Win10RSATTools {
<#
.Synopsis
   This Function will Install Win10 RSAT Tools on your windows 10 Machine
.DESCRIPTION
   This uses System.Net.WebRequest & System.Net.WebClient to download the specific version of Win10 RSAT Tools for your OS version (x64/x86) and then uses
   msiexec to install it.
.EXAMPLE
   Install-Win10RSATTools
   #>

#Requires -Version 5.0 -RunAsAdministrator
[Cmdletbinding()]
param()
        $x86 = 'https://download.microsoft.com/download/1/D/8/1D8B5022-5477-4B9A-8104-6A71FF9D98AB/WindowsTH-RSAT_WS2016-x86.msu'
        $x64 = 'https://download.microsoft.com/download/1/D/8/1D8B5022-5477-4B9A-8104-6A71FF9D98AB/WindowsTH-RSAT_WS2016-x64.msu'

    switch ($env:PROCESSOR_ARCHITECTURE)
    {
        'x86' {$version = $x86}
        'AMD64' {$version = $x64}
    }

    Write-Verbose -Message "OS Version is $env:PROCESSOR_ARCHITECTURE"
    Write-Verbose -Message "Now Downloading RSAT Tools installer"

    $Filename = $version.Split('/')[-1]
    Invoke-WebRequest -Uri $version -UseBasicParsing -OutFile "$env:TEMP\$Filename" 
    
    Write-Verbose -Message "Starting the Windows Update Service to install the RSAT Tools "
    
    Start-Process -FilePath wusa.exe -ArgumentList "$env:TEMP\$Filename /quiet" -Wait -Verbose
    
    Write-Verbose -Message "RSAT Tools are now be installed"
    
    Remove-Item "$env:TEMP\$Filename" -Verbose
    
    Write-Verbose -Message "Script Cleanup complete"
    
    Write-Verbose -Message "Remote Administration"
}

Install-Win10RSATTools -Verbose


       