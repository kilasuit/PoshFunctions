function Install-PowerShellPackageManagement {

$x86 = 'https://download.microsoft.com/download/4/1/A/41A369FA-AA36-4EE9-845B-20BCC1691FC5/PackageManagement_x86.msi'
$x64 = 'https://download.microsoft.com/download/4/1/A/41A369FA-AA36-4EE9-845B-20BCC1691FC5/PackageManagement_x64.msi'

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

    msiexec.exe /package "$env:TEMP\$Filename"
}

Install-PowerShellPackageManagement
