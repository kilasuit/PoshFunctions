function Get-ExchangedCurrency{
<#
.SYNOPSIS
   This function will get back a rough estimate on how much that item will cost you in GBP
.DESCRIPTION
   This will check if the List Name already exists (as there cannot be 2 lists or libraries with the same name) 
   and will create a new List/library based on the passed parameters 
.PARAMETER curCode
   curCode is used for the exchanging from currency 
.PARAMETER toGBP 
   By default this is set to true as likely you are looking at items in USD or EUR (or SGD in my case) and you
   want to get the rough costing in £
.PARAMETER Amount
   Is it 1, 145, 450 etc
.EXAMPLE
   Get-ExchangedCurrency -curCode USD -amount 7 

   Returns the GBP amount for $7
.EXAMPLE
    Get-ExchangedCurrency -curCode USD -amount 7 -toGBP $false
   
   Returns the $USD amount for £7
#>

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
