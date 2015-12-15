Function Get-ExternalIpOnTrain {

try{
    $wc=New-Object net.webclient
    $ip = $wc.downloadstring("http://checkip.dyndns.com") -replace "[^\d\.]"
    }
catch
    {
    $currenterror = $_.Exception.HResult
    }
    if ($currenterror -eq '-2146233087')
        {
        Add-Content -Value "Not Connected ; to the internet at $(Get-Date)" -Path C:\TextFile\VirginInternet.log  
        }
        Else
            {
            $speed = "{0:N2} Mbit/sec" -f ((10/(Measure-Command {Invoke-WebRequest 'http://cachefly.cachefly.net/1mb.test' | Out-null}).TotalSeconds)*8)
            $data = ping 8.8.8.8            
            Add-Content -Value "Connected ; to the internet with an external IP of $ip at $(Get-date) and a Download speed of $speed with Ping data of $($data[10].Trim())" -Path C:\TextFile\VirginInternet.log 
            }

}
$end = (Get-Date).AddMinutes(150)
do{
Get-ExternalIpOnTrain
Start-Sleep -Seconds 60
}
until($(Get-Date) -gt $end)


