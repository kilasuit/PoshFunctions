Function Connect-EXOSession {
param (
    [Parameter(Mandatory=$true)][PSCredential]$EXOCredential

     )
 

$Global:Session = New-PSSession -ConfigurationName Microsoft.Exchange `
-ConnectionUri https://outlook.office365.com/powershell-liveid/ `
-Credential $EXOCredential -Authentication Basic -AllowRedirection -Name EXOSession
$global:exosession = Import-PSSession -Session $Global:Session -Verbose:$false -DisableNameChecking -AllowClobber
$exoModule = Import-Module $exosession -Global
}
