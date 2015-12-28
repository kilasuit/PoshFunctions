function Set-EVGroupDistributionList {
<#
.Synopsis
   This Function will Set users in a Distribution Group in Exchange Online based on the Orders placed in Eventbrite
.DESCRIPTION
   To be completed
.EXAMPLE
   Set-EVGroupDistributionList -ExistingXML C:\xml\EVGroup.xml -EventbrightToken $env:EventBriteToken -DistributionList MyEventBriteList -EXOCredential $MyEXOCredential
   #>
[cmdletbinding()]
param (
    [Parameter(Mandatory=$true)][string]$ExistingXML,
    [Parameter(Mandatory=$true)][string]$EventbriteToken,
    [Parameter(Mandatory=$true)][string]$distributionList,
    [Parameter(Mandatory=$true)][PSCredential]$EXOcredential
    )

Get-EventbriteEvents -EventbrightToken $EventbriteToken
$iemail = Import-Clixml -Path $existingXML
Connect-EXOSession -EXOCredential $EXOcredential # Custom Function for Connecting to EXO PSSession

$emails = New-Object System.Collections.Arraylist
foreach ($event in $events.events)
    {
    $eventid = $event.id
 
    $Attendees = Invoke-WebRequest -Uri https://www.eventbriteapi.com/v3/events/$eventID/attendees/?token=$EventbriteToken | ConvertFrom-Json
    $Orders = Invoke-WebRequest -Uri https://www.eventbriteapi.com/v3/events/$eventID/orders/?token=$EventbriteToken | ConvertFrom-Json

    
    $pscustom = [PSCustomObject]@{Attendees = $Attendees.attendees ; Orders = $Orders.orders}
    
        foreach ($attendee in $pscustom.Attendees)
        {
            if($attendee.status -eq 'Attending')
               {
                if ($attendee.answers.answer.Contains("Please include me in email updates"))
                  {
                    if ($pscustom.Orders.Id -contains $attendee.order_id)
                      {
                        $details = $pscustom.Orders | Where-Object {$_.Id -eq $attendee.order_id} | Select-Object name,first_name,last_name,email
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

function Get-EventbriteEvents {
<#
.Synopsis
   This Function will Get all EventBrite Events 
.DESCRIPTION
   To be completed
.EXAMPLE
   Get-EventbriteEvents -EventbrightToken $env:EventBriteToken 
   #>
[cmdletbinding()]
param (
[Parameter(Mandatory=$true)][string]$EventbriteToken

        )
$Global:Events = Invoke-WebRequest https://www.eventbriteapi.com/v3/users/me/owned_events/?token=$EventbriteToken | ConvertFrom-Json

Foreach ($event in $events.events ) 
{
$event.Name = $event.Name.Text
$event.start = (([DateTime]($event.start.local)).ToUniversalTime())
$event.end = (([DateTime]($event.end.local)).ToUniversalTime())
}
}

function Get-EventbriteOrders {
<#
.Synopsis
   This Function will Get all EventBrite Orders 
.DESCRIPTION
   To be completed
.EXAMPLE
   Get-EventbriteOrders -EventbrightToken $env:EventBriteToken 
   #>
[cmdletbinding()]
param (
[Parameter(Mandatory=$true)][string]$EventbriteToken

        )
$global:orders = Invoke-WebRequest https://www.eventbriteapi.com/v3/users/me/orders/?token=$EventbriteToken | ConvertFrom-Json

$global:Myevents =@()

foreach ($order in $orders.orders) {
    Get-EventbriteEvent -EventbrightToken $EventbriteToken -EventID $order.event_id
    }

}


function Get-EventbriteEvent {
<#
.Synopsis
   This Function will Get a specific EventBrite Event 
.DESCRIPTION
   To be completed
.EXAMPLE
   Get-EventbriteEvent -EventbrightToken $env:EventBriteToken -EventID 1234376727438
   #>
[cmdletbinding()]
param (
    [Parameter(Mandatory=$true)][string]$EventbriteToken,
    [Parameter(Mandatory=$true)][string]$EventID
        )
$Global:Event = Invoke-WebRequest https://www.eventbriteapi.com/v3/events/$eventid/?token=$EventbriteToken | ConvertFrom-Json

$event.Name = $event.Name.Text
$event.start = (([DateTime]($event.start.local)).ToUniversalTime())
$event.end = (([DateTime]($event.end.local)).ToUniversalTime())

$global:myevents += $event
}

function Get-EventbriteEventQuestions {
<#
.Synopsis
   This Function will Get all Questions from a specificed EventBrite Event
.DESCRIPTION
   To be completed
.EXAMPLE
   Get-EventbriteEventQuestions -EventbrightToken $env:EventBriteToken -EventID 1232786423
   #>
[cmdletbinding()]
param (
    [Parameter(Mandatory=$true)][string]$EventbriteToken,
    [Parameter(Mandatory=$true)][string]$EventID
        )
$Global:questions = (Invoke-WebRequest https://www.eventbriteapi.com/v3/events/$eventid/questions/?token=$EventbriteToken | ConvertFrom-Json).questions

}