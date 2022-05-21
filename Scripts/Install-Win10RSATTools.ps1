<#PSScriptInfo

.VERSION 1.1.0

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
#Requires -Version 5.0 -RunAsAdministrator
[Cmdletbinding()]
param()
    $VerbosePreference = 'Continue'
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
    $OutputFile = "$env:TEMP\$Filename"
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile($version, $OutputFile)
    Write-Verbose -Message "Starting the Windows Update Service to install the RSAT Tools"
    Start-Process -FilePath wusa.exe -ArgumentList "$OutputFile /quiet" -Wait -Verbose
    Write-Verbose -Message "RSAT Tools are now be installed"
    Remove-Item $OutputFile -Verbose
    Write-Verbose -Message "Script Cleanup complete"