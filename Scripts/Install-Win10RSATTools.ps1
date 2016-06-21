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

#Requires -Version 5.0
[Cmdletbinding()]
param()
        $x86 = 'https://download.microsoft.com/download/1/D/8/1D8B5022-5477-4B9A-8104-6A71FF9D98AB/WindowsTH-KB2693643-x86.msu'
        $x64 = 'https://download.microsoft.com/download/1/D/8/1D8B5022-5477-4B9A-8104-6A71FF9D98AB/WindowsTH-KB2693643-x64.msu'

    switch ($env:PROCESSOR_ARCHITECTURE)
    {
        'x86' {$version = $x86}
        'AMD64' {$version = $x64}
    }

    $Request = [System.Net.WebRequest]::Create($version)
    $Request.Timeout = "100000000"
    $URL = $Request.GetResponse()
    $Filename = $URL.ResponseUri.OriginalString.Split("/")[-1]
    $url.close()
    $WC = New-Object System.Net.WebClient
    $WC.DownloadFile($version,"$env:TEMP\$Filename")
    $WC.Dispose()

    wusa.exe $env:TEMP\$Filename /quiet

    Start-Sleep 80
    Remove-Item "$env:TEMP\$Filename"
    
}

Install-Win10RSATTools -Verbose


       