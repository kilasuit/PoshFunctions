Function Connect-EXOSession {
param (
    [Parameter(Mandatory=$true)][PSCredential]$EXOCredential

     )
 

$Session = New-PSSession -ConfigurationName Microsoft.Exchange `
-ConnectionUri https://outlook.office365.com/powershell-liveid/ `
-Credential $EXOCredential -Authentication Basic -AllowRedirection -Name EXOSession
$global:exosession = Import-PSSession -Session $Session -Verbose:$false -DisableNameChecking -AllowClobber | Out-Null
}
