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


function Set-EVGroupDistributionList
{

param (
    [Parameter(Mandatory=$true)][string]$ExistingXML,
    [Parameter(Mandatory=$true)][string]$EventbrightToken,
    [Parameter(Mandatory=$true)][string]$distributionList,
    [Parameter(Mandatory=$true)][PSCredential]$EXOcredential
    )

Get-EventbriteEvents -EventbrightToken $EventbrightToken
$iemail = Import-Clixml -Path $existingXML
Connect-EXOSession -EXOCredential $EXOcredential # Custom Function for Connecting to EXO PSSession

$emails = New-Object System.Collections.Arraylist
foreach ($event in $events.events)
    {
    $eventid = $event.id
 
    $Attendees = Invoke-WebRequest -Uri https://www.eventbriteapi.com/v3/events/$eventID/attendees/?token=$EventbrightToken | ConvertFrom-Json
    $Orders = Invoke-WebRequest -Uri https://www.eventbriteapi.com/v3/events/$eventID/orders/?token=$EventbrightToken | ConvertFrom-Json

    
    $pscustom = [PSCustomObject]@{Attendees = $Attendees.attendees ; Orders = $Orders.orders}
    
        foreach ($attendee in $pscustom.Attendees)
        {
            if($attendee.status -eq 'Attending')
               {
                if ($attendee.answers.answer.Contains("Please include me in email updates"))
                  {
                    if ($pscustom.Orders.Id -contains $attendee.order_id)
                      {
                        $details = $pscustom.Orders | Where-Object {$_.Id -eq $attendee.order_id} | Select name,first_name,last_name,email
                        $emails.add($details)
                      }

                   }
               }
        }
    }
    foreach ($email in $emails)
    {
    If (!$iemail.Name.Contains($email.name))
        {
        New-MailContact -LastName $email.Last_name `
                        -DisplayName $email.name `
                        -Name $email.name `
                        -ExternalEmailAddress $email.email `
                        -FirstName $email.first_name ; Add-DistributionGroupMember -Identity $distributionList -Member $email.email
        }
    }
    Export-Clixml -InputObject $emails -Path $ExistingXML
    Remove-PSSession -Name EXOSession
}

function Get-EventbriteEvents
{
param (
[Parameter(Mandatory=$true)][string]$EventbrightToken

        )
$Global:Events = Invoke-WebRequest https://www.eventbriteapi.com/v3/users/me/owned_events/?token=$EventbrightToken | ConvertFrom-Json

Foreach ($event in $events.events ) 
{
$event.Name = $event.Name.Text
$event.start = (([DateTime]($event.start.local)).ToUniversalTime())
$event.end = (([DateTime]($event.end.local)).ToUniversalTime())
}
}

function get-eventbriteOrders
{
param (
[Parameter(Mandatory=$true)][string]$EventbrightToken

        )
$global:orders = Invoke-WebRequest https://www.eventbriteapi.com/v3/users/me/orders/?token=$EventbrightToken | ConvertFrom-Json

$global:Myevents =@()

foreach ($order in $orders.orders) {
    Get-EventbriteEvent -EventbrightToken $EventbrightToken -EventID $order.event_id
    }

}


function Get-EventbriteEvent
{
param (
    [Parameter(Mandatory=$true)][string]$EventbrightToken,
    [Parameter(Mandatory=$true)][string]$EventID
        )
$Global:Event = Invoke-WebRequest https://www.eventbriteapi.com/v3/events/$eventid/?token=$EventbrightToken | ConvertFrom-Json

$event.Name = $event.Name.Text
$event.start = (([DateTime]($event.start.local)).ToUniversalTime())
$event.end = (([DateTime]($event.end.local)).ToUniversalTime())

$global:myevents += $event
}

function Get-EventbriteEventQuestions
{
param (
    [Parameter(Mandatory=$true)][string]$EventbrightToken,
    [Parameter(Mandatory=$true)][string]$EventID
        )
$Global:questions = (Invoke-WebRequest https://www.eventbriteapi.com/v3/events/$eventid/questions/?token=$EventbrightToken | ConvertFrom-Json).questions

}