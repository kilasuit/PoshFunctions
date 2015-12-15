#Connect-EXOSession#
Function Connect-EXOSession {
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
param (
    [Parameter(Mandatory=$true)][PSCredential]$EXOCredential

     )
$Global:Session = New-PSSession -ConfigurationName Microsoft.Exchange `
                    -ConnectionUri https://ps.outlook.com/powershell/ `
                    -Credential $EXOCredential -Authentication Basic `
                    -AllowRedirection -Name EXOSession -WarningAction SilentlyContinue 
Import-Module (Import-PSSession -Session $Global:Session -Verbose:$false -DisableNameChecking -AllowClobber) -Global -DisableNameChecking
}
