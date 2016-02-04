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
 
    $Attendees = Invoke-RestMethod -Uri https://www.eventbriteapi.com/v3/events/$eventID/attendees/?token=$EventbriteToken 
    $Orders = Invoke-RestMethod -Uri https://www.eventbriteapi.com/v3/events/$eventID/orders/?token=$EventbriteToken 

    
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
$Global:Events = Invoke-RestMethod https://www.eventbriteapi.com/v3/users/me/owned_events/?token=$EventbriteToken 

Foreach ($event in $events.events ) 
{
$event.Name = $event.Name.Text
$event.start = (([DateTime]($event.start.local)).ToUniversalTime())
$event.end = (([DateTime]($event.end.local)).ToUniversalTime())
Add-Member -Name Year -InputObject $event -MemberType NoteProperty -Value $event.start.Year
}
}

function Get-EventAttendees {
[cmdletbinding()]
param (
    [Parameter(Mandatory=$true)][string]$EventbriteToken,
    [Parameter(Mandatory=$true)][ValidateSet('Manchester','London','Bristol','Derby','Leeds','Birmingham','Cambridge')][String]$location,
    [Parameter(Mandatory=$true)][ValidateSet('January','February','March','April','May','June','July','August','September','October','November','December')][String]$month,
    [Parameter(Mandatory=$true)][ValidateSet('2016','2015','2017','2018','2019','2020')][String]$year
      )

Get-EventbriteEvents -EventbriteToken $EventbriteToken

$event = $($events.events.Where({$_.Name.contains($location)}).where({$_.name.contains($month)}).where({$_.Year -eq $year}))
$emails = New-Object System.Collections.Arraylist

    $eventid = $event.id
 
    $Attendees = Invoke-RestMethod -Uri https://www.eventbriteapi.com/v3/events/$eventID/attendees/?token=$EventbriteToken 
    $Orders = Invoke-RestMethod -Uri https://www.eventbriteapi.com/v3/events/$eventID/orders/?token=$EventbriteToken 

    
    $pscustom = [PSCustomObject]@{Attendees = $Attendees.attendees ; Orders = $Orders.orders}
    
        foreach ($attendee in $pscustom.Attendees)
        {
            if($attendee.status -eq 'Attending')
               {
                if ($pscustom.Orders.Id -contains $attendee.order_id)
                      {
                        $details = $pscustom.Orders | Where-Object {$_.Id -eq $attendee.order_id} | Select-Object name,first_name,last_name,email
                        $emails.add($details) | Out-Null
                      }
                }
        }
    $emails
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
$global:orders = Invoke-RestMethod https://www.eventbriteapi.com/v3/users/me/orders/?token=$EventbriteToken
$global:Myevents =@()

foreach ($order in $orders.orders) {
    Get-EventbriteEvent -EventbriteToken $EventbriteToken -EventID $order.event_id
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
$Global:Event = Invoke-RestMethod https://www.eventbriteapi.com/v3/events/$eventid/?token=$EventbriteToken 
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
$Global:questions = (Invoke-RestMethod https://www.eventbriteapi.com/v3/events/$eventid/questions/?token=$EventbriteToken ).questions

}

function Get-EventAttendees {
[cmdletbinding()]
param (
    [Parameter(Mandatory=$true)][string]$EventbriteToken,
    [Parameter(Mandatory=$true)][ValidateSet('Manchester','London','Bristol','Derby','Leeds','Birmingham','Cambridge')][String]$location,
    [Parameter(Mandatory=$true)][ValidateSet('January','February','March','April','May','June','July','August','September','October','November','December')][String]$month
      )

Get-EventbriteEvents -EventbriteToken $EventbriteToken

$event = $($events.events.Where({$_.Name.contains($location)}).where({$_.name.contains($month)}))
$emails = New-Object System.Collections.Arraylist

    $eventid = $event.id
 
    $Attendees = Invoke-RestMethod -Uri https://www.eventbriteapi.com/v3/events/$eventID/attendees/?token=$EventbriteToken 
    $Orders = Invoke-RestMethod -Uri https://www.eventbriteapi.com/v3/events/$eventID/orders/?token=$EventbriteToken 

    
    $pscustom = [PSCustomObject]@{Attendees = $Attendees.attendees ; Orders = $Orders.orders}
    
        foreach ($attendee in $pscustom.Attendees)
        {
            if($attendee.status -eq 'Attending')
               {
                if ($pscustom.Orders.Id -contains $attendee.order_id)
                      {
                        $details = $pscustom.Orders | Where-Object {$_.Id -eq $attendee.order_id} | Select-Object name,first_name,last_name,email
                        $emails.add($details) | Out-Null
                      }
                }
        }
    $emails
 }

function Get-EventbriteVenue {
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
[Parameter(Mandatory=$true)][string]$EventbriteToken,
[Parameter(Mandatory=$true)][string]$VenueID

        )
$global:Venue = Invoke-RestMethod https://www.eventbriteapi.com/v3/venues/$VenueID/?token=$EventbriteToken
}
