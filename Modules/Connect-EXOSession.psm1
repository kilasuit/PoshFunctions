Function Connect-EXOSession {
param (
    [Parameter(Mandatory=$true)][PSCredential]$EXOCredential

     )
 

$Global:Session = New-PSSession -ConfigurationName Microsoft.Exchange `
                    -ConnectionUri https://ps.outlook.com/powershell/ `
                    -Credential $EXOCredential -Authentication Basic `
                    -AllowRedirection -Name EXOSession -WarningAction SilentlyContinue 
Import-Module (Import-PSSession -Session $Global:Session -Verbose:$false -DisableNameChecking -AllowClobber) -Global
}
