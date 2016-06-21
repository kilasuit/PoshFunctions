function Install-PowerShellPackageManagement {
<#
.Synopsis
   This Function will Check and see if PowerShellGet (aka PowerShellPackageManagement) is installed on your system
.DESCRIPTION
   This uses System.Net.WebRequest & System.Net.WebClient to download the specific version of PowerShellPackageManager for your OS version (x64/x86) and then uses
   msiexec to install it.
.EXAMPLE
   Install-PowerShellPackageManagement -Latest -Verbose
   #>

#Requires -Version 3.0
[Cmdletbinding()]
param(
[Switch]$Latest

)

if (!(Get-command -Module PowerShellGet).count -gt 0)
    {
    if ($Latest) {
    $x86 = 'https://download.microsoft.com/download/C/4/1/C41378D4-7F41-4BBE-9D0D-0E4F98585C61/PackageManagement_x86.msi'
    $x64 = 'https://download.microsoft.com/download/C/4/1/C41378D4-7F41-4BBE-9D0D-0E4F98585C61/PackageManagement_x64.msi'
        Write-Verbose "Using the March 2016 Version of the MSI installer"
    }
    Else{ 
        $x86 = 'https://download.microsoft.com/download/4/1/A/41A369FA-AA36-4EE9-845B-20BCC1691FC5/PackageManagement_x86.msi'
        $x64 = 'https://download.microsoft.com/download/4/1/A/41A369FA-AA36-4EE9-845B-20BCC1691FC5/PackageManagement_x64.msi'
        Write-Verbose "Using the Pre-March 2016 Version of the MSI installer"
        }
    switch ($env:PROCESSOR_ARCHITECTURE)
    {
        'x86' {$version = $x86}
        'AMD64' {$version = $x64}
    }
    Write-Verbose "You are on a $version based OS and we are starting the Download of the MSI for your OS Version"
    $Request = [System.Net.WebRequest]::Create($version)
    $Request.Timeout = "100000000"
    $URL = $Request.GetResponse()
    $Filename = $URL.ResponseUri.OriginalString.Split("/")[-1]
    $url.close()
    $WC = New-Object System.Net.WebClient
    $WC.DownloadFile($version,"$env:TEMP\$Filename")
    $WC.Dispose()
    Write-Verbose "MSI Downloaded - Now executing the MSI to add the PackageManagement functionality to your Machine"
    msiexec.exe /package "$env:TEMP\$Filename"
    
    Start-Sleep 80
    Write-Verbose "MSI installed now removing the temporary file from your machine"
    Remove-Item "$env:TEMP\$Filename"
    }
}

Install-PowerShellPackageManagement -Latest -Verbose