function Get-ExchangedCurrency{
param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("SGD","EUR", "USD")]
    [string] $curCode,

    [Parameter(Mandatory=$false)]
    [Bool] $toGBP = $true,

    [Parameter(Mandatory=$true)]
    [int]$amount
    )

$rst = Invoke-RestMethod -Method Get -Uri http://api.fixer.io/latest?base=GBP

if ($toGBP -eq $true)
    { 
    $rtn = $amount / $rst.rates."$curcode"
    }
    else
    { 
    $rtn =$amount * $rst.rates."$curcode"
    }

    [math]::round($rtn,2)
    }
