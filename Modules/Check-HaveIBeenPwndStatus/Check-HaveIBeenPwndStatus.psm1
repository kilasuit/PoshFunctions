Function Check-HaveIBeenPwndStatus {
<#
.Synopsis
   This Function will Check and see if your Email Account has recently been marked as being at risk of any breaches as detailed on https://haveibeenpwned.com/
.DESCRIPTION
   This uses Invoke-RestMethod to check if the account passed to it has been breached
.EXAMPLE
   Check-HaveIBeenPwndStatus -Account me@abc.co.uk
   #>
[CmdletBinding()]
	param
	(
		[Parameter(Mandatory=$true, Position=1)]
		[string] $Account
    )
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Try
{$output = Invoke-RestMethod -Method get -Uri "https://haveibeenpwned.com/api/v2/breachedaccount/$account"}
Catch
{$error1 = $error}

if ($error1 -eq $null)
    { Write-Warning "We have your account $account marked as having been pwnd on the following sites $($output.Title) - Please Check and change your passwords across other sites as soon as you can!"}
    else
    { Write-Output "Although $account has not been found in this database of PwndSites we advise that you change passwords regularly for any other accounts that may be linked to $account for your own protection"}
}