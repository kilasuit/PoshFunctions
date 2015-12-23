#Script#Install-WMF5#
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
$versionNumber = Get-WmiObject -class Win32_OperatingSystem |  Select-Object -ExpandProperty version
$versionArray = $versionNumber.Split('.')
$caption = (Get-WmiObject -class Win32_OperatingSystem | Select-Object -ExpandProperty Caption)
$architecture = Get-WmiObject -Class Win32_OperatingSystem |  Select-Object -ExpandProperty OSArchitecture
Write-Verbose 'We have Identified your OS and are now determining the Correct package to Download'
If ($Versionarray[0] -ge 7) { Write-Warning 'WMF 5 is not installable via this method'}
else {
if ($Versionarray[0] -eq 6) { 
    switch ($Versionarray[1])
    {
        3    {$version = "Windows 2012R2/Win8.1"}
        2    {$version = "Windows 2012/Win8"}
        1    {$version = "Windows 2008R2/Win7"}
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
        if ($caption.contains('Windows 8')) { Write-Warning 'Looks like Windows 8 is not supported - Please check this link for more details' }
        else { $version = "Windows 2012"}
    }
  }  
 }             
    switch ($Version)
    {
        "Windows 2012R2"      {$link = "http://go.microsoft.com/fwlink/?LinkId=717507"}
        "Windows 2012"        {$link = "http://go.microsoft.com/fwlink/?LinkId=717506"}
        "Windows 2008R2"      {$link = "http://go.microsoft.com/fwlink/?LinkId=717504"}    
        "Windows 8.1 64Bit"   {$link = "http://go.microsoft.com/fwlink/?LinkId=717507"}
        "Windows 8.1 32Bit"   {$link = "http://go.microsoft.com/fwlink/?LinkID=717963"}
        "Windows 7 64Bit"     {$link = "http://go.microsoft.com/fwlink/?LinkId=717504"}
        "Windows 7 32Bit"     {$link = "http://go.microsoft.com/fwlink/?LinkID=717962"}
    }

    if(($version -eq 'Windows 2008R2' -or 'Windows 7 64Bit' -or 'Windows 7 32Bit') -and (Test-path $env:TEMP\WMF4Installed.txt) -eq $false )
   
    {
    Write-Warning 'Please use the Install WMF4 Script first'
    break
    }
     
    else
    {

    Write-Verbose 'We are now downloading the correct version of WMF5 for your System'
   
    $Request = [System.Net.WebRequest]::Create($link)
    $Request.Timeout = "100000000"
    $URL = $Request.GetResponse()
    $Filename = $URL.ResponseUri.OriginalString.Split("/")[-1]
    $url.close()
    $WC = New-Object System.Net.WebClient
    $WC.DownloadFile($link,"$env:TEMP\$Filename")
    $WC.Dispose()

    Set-Location $env:Temp
    & .\$Filename /quiet

    Start-Sleep 80
    Remove-Item "$env:TEMP\$Filename"
    if(Test-path $env:TEMP\WMF4Installed.txt) {Remove-Item $env:Temp\installedWMF4.txt}

    shutdown /r /t 1
    }
}

Install-WMF5 -Verbose