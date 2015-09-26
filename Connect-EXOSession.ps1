Function Connect-EXOSession {
param (
    [Parameter(Mandatory=$true)][PSCredential]$EXOCredential
    )


$O365Session = New-PSSession -ConfigurationName Microsoft.Exchange `
			-ConnectionUri "https://ps.outlook.com/powershell" -Credential $EXOCredential `
			-Authentication Basic -AllowRedirection -WarningAction SilentlyContinue -Name EXOSession
			#If session is newly created, import the session.
			$global:exosession = Import-PSSession -Session $O365Session -Verbose:$false -DisableNameChecking -AllowClobber | Out-Null
}
