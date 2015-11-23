Function Connect-EXOSession {
param (
    [Parameter(Mandatory=$true)][PSCredential]$EXOCredential

     )
 

$Global:Session = New-PSSession -ConfigurationName Microsoft.Exchange `
                    -ConnectionUri https://ps.outlook.com/powershell/ `
                    -Credential $EXOCredential `
                    -Authentication Basic -AllowRedirection -Name EXOSession
$global:exosession = Import-PSSession -Session $Global:Session -Verbose:$false -DisableNameChecking -AllowClobber 
$global:exomodule = Import-Module $Global:exosession -Global -DisableNameChecking -NoClobber
}
