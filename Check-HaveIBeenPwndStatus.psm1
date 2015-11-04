Function Check-HaveIBeenPwndStatus {
[CmdletBinding()]
	param
	(
		[Parameter(Mandatory=$true, Position=1)]
		[string] $Account
    )

Try
{$output = Invoke-RestMethod -Method get -Uri "https://haveibeenpwned.com/api/v2/breachedaccount/$account"}
Catch
{$error1 = $error}

if ($error1 -eq $null)
    { Write-Warning "We have your account $account marked as having been pwnd on the following sites $($output.Title) - Please Check and change your passwords across other sites as soon as you can!"}
    else
    { Write-Output "Although $account has not been found in this database of PwndSites we advise that you change passwords regularly for any other accounts that may be linked to $account for your own protection"}
}