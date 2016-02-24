function Install-WMF5 {
<#
    .Synopsis
    This Function will Install WMF5 on your system
    .DESCRIPTION
    This uses System.Net.WebRequest & System.Net.WebClient to download the specific version of PowerShellPackageManager for your OS version (x64/x86) and then uses
    msiexec to install it.
    .EXAMPLE
    Install-WMF5 -Verbose
#>
[CmdletBinding()]
param()
$versionNumber = (Get-WmiObject -class Win32_OperatingSystem |  Select-Object -ExpandProperty version)
$versionarray = @()
$versionNumber.Split('.') | ForEach-Object { $versionArray += [int]$_}
$SimpleVersionNumber = "$($versionArray[0]).$($versionArray[1])"
$caption = (Get-WmiObject -class Win32_OperatingSystem | Select-Object -ExpandProperty Caption)
$architecture = Get-WmiObject -Class Win32_OperatingSystem |  Select-Object -ExpandProperty OSArchitecture
Write-Verbose 'We have Identified your OS and are now determining the Correct package to Download'
If ($SimpleVersionNumber -ge 7) { 
Write-Warning 'WMF 5 is not installable via this method as you are already running Windows10 or Server 2016'} 
else {
    switch ($SimpleVersionNumber)
    {
        6.3    {$version = "Windows 2012R2/Win8.1"}
        6.2    {$version = "Windows 2012/Win8"}
        6.1    {$version = "Windows 2008R2/Win7"}
    }
    }
    if ($version -eq "Windows 2008R2/Win7") {
        if ($caption.contains('Windows 7')) {
            switch ($architecture)
            {
                '64-bit' {$version = "Windows 7 64Bit"}
                '32-bit' {$version = "Windows 7 32Bit"}
            }
        } else { $version = "Windows 2008R2"}
    }
    elseif($version -eq "Windows 2012R2/Win8.1") {
        if ($caption.contains('Windows 8.1')) {
            switch ($architecture)
            {
                '64-bit' {$version = "Windows 8.1 64Bit"}
                '32-bit' {$version = "Windows 8.1 32Bit"}
            }
        }
        else { $version = "Windows 2012R2"}
    }
    elseif($version -eq "Windows 2012/Win8") {
        if ($caption.contains('Windows 8')) { Write-Warning 'Windows 8 is not supported for WMF5 - Sorry about that!' }
        else { $version = "Windows 2012"}
    
  }  
              
    switch ($Version)
    {
        "Windows 2012R2"      {$link = "https://download.microsoft.com/download/2/C/6/2C6E1B4A-EBE5-48A6-B225-2D2058A9CEFB/Win8.1AndW2K12R2-KB3134758-x64.msu"}
        "Windows 2012"        {$link = "https://download.microsoft.com/download/2/C/6/2C6E1B4A-EBE5-48A6-B225-2D2058A9CEFB/W2K12-KB3134759-x64.msu"}
        #"Windows 2008R2"      {$link = "https://download.microsoft.com/download/2/C/6/2C6E1B4A-EBE5-48A6-B225-2D2058A9CEFB/Win7AndW2K8R2-KB3134760-x64.msu"}    
        "Windows 8.1 64Bit"   {$link = "https://download.microsoft.com/download/2/C/6/2C6E1B4A-EBE5-48A6-B225-2D2058A9CEFB/Win8.1AndW2K12R2-KB3134758-x64.msu"}
        "Windows 8.1 32Bit"   {$link = "https://download.microsoft.com/download/2/C/6/2C6E1B4A-EBE5-48A6-B225-2D2058A9CEFB/Win8.1-KB3134758-x86.msu"}
        #"Windows 7 64Bit"     {$link = "https://download.microsoft.com/download/2/C/6/2C6E1B4A-EBE5-48A6-B225-2D2058A9CEFB/Win7AndW2K8R2-KB3134760-x64.msu"}
        #"Windows 7 32Bit"     {$link = "https://download.microsoft.com/download/2/C/6/2C6E1B4A-EBE5-48A6-B225-2D2058A9CEFB/Win7-KB3134760-x86.msu"}
    }

    Write-Verbose 'We are now downloading the correct version of WMF5 for your System'
    Write-Verbose "System has been Identified as $version"
    $Request = [System.Net.WebRequest]::Create($link)
    $Request.Timeout = "100000000"
    $URL = $Request.GetResponse()
    $Filename = $URL.ResponseUri.OriginalString.Split("/")[-1]
    $url.close()
    $WC = New-Object System.Net.WebClient
    $WC.DownloadFile($link,"$env:TEMP\$Filename")
    $WC.Dispose()
    Write-Verbose 'We are Installing WMF5 silently for you'
    Set-Location $env:Temp
    & .\$Filename /quiet

    Start-Sleep 80
    Remove-Item "$env:TEMP\$Filename"
    if(Test-path $env:TEMP\WMF4Installed.txt) {Remove-Item $env:Temp\installedWMF4.txt}
    Write-Verbose 'We need to Reboot after install of WMF4 - you can now proceed to install WMF5'
    Start-Sleep 5
    shutdown /r /t 1
    }

    
Install-WMF5 -Verbose