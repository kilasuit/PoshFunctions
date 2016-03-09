#Module#New-GitHubEmailStuff#
function New-GithubEmailStuffs { 
<#
.SYNOPSIS
   Creates New Folders and Rules in EXO Mailbox for the Github User & Exchange Mailbox User (Could be run by Exchange Admins in a company)
.DESCRIPTION
   Really saves time with nonsense for GitHub Issues tracking using the Open GitHub API for watched Public Repositories.
.EXAMPLE
   New-GithubEmailStuffs -githubUser 'kilasuit' -MailboxFolderParent 'ryan.yates:\Inbox\GitHub Stuff' -EXOCredential $MYO365cred

   This will connect to Github API for the GitHub User kilasuit and then will connect to Exchange Online using the Required Connect-EXOSession Module with the Credentials
   passed to the EXOCredential Parameter and then will use the MailboxFolderParent Parameter for checking/adding the new folders and rules.
.NOTES
    TO-DO
    Parameter help
    Include private repo searching via OAuth tokens and additional Parameter
    Ideally Clean up the multiple replaces that are used to set up the Last Link variable.
    Quicken the execution of this function as it is quite slow at the moment.
    Adapt and release a version that doesnt require use of Exchange functionality and can be used with Outlook using the Outlook COM model.
    LICENSE
    MIT
    AUTHOR
    Ryan Yates - Ryan.yates@kilasuit.org
    REQUIRES Modules Connect-EXOSession,GithubConnect
#>
[CmdletBinding()]
Param ( 
    [Parameter(Mandatory=$true,Position=0)] 
    [string]$MailboxFolderParent,
    [Parameter(Mandatory=$true,Position=0)] 
    [PSCredential]$EXOCredential,
    [Parameter(Mandatory=$true,Position=0)] 
    [string]$PersonalGithubOauthToken
      )
$repos =@()
Connect-Github -PersonalOAuthToken $PersonalGithubOauthToken | Out-Null
$web = Invoke-WebRequest -Uri "https://api.github.com/user/subscriptions" -Method Get -Headers @{"Authorization"="token $GithubPersonalOAuthToken"}
$page1 = Invoke-RestMethod -Uri "https://api.github.com/user/subscriptions" -Method Get -Headers @{"Authorization"="token $GithubPersonalOAuthToken"}
$page1 | ForEach-Object { $repos += $_.name }
if ($web.Headers.Keys.Contains('Link'))
{
    $LastLink = $web.Headers.Link.Split(',')[1].replace('<','').replace('>','').replace(' ','').replace('rel="last"','').replace(';','')
    [int]$last = $($lastlink[($lastlink.ToCharArray().count -1)]).tostring()
    $pages = 2..$last
    foreach ($page in $pages)
        {
        Invoke-RestMethod -Uri "https://api.github.com/user/subscriptions?page=$page" -Method Get -Headers @{"Authorization"="token $GithubPersonalOAuthToken"} | ForEach-Object { $repos += $_.name }
        }
}
$repos = $repos | Sort-Object -Unique
Connect-EXOSession -EXOCredential $EXOCredential
$folders = Get-MailboxFolder $MailboxFolderParent -GetChildren | Select-Object -ExpandProperty Name 
foreach ($repo in $repos) {
    if($folders -notcontains $repo) {
          New-MailboxFolder -Parent $MailboxFolderParent -Name $repo | Out-Null
          New-InboxRule -SubjectContainsWords "[$repo]" -MoveToFolder $MailboxFolderParent\$repo -Name "[$repo]" -Force | Out-Null 
          Write-Output "Folder & rule for $repo have been created"
        }
    }
Remove-PSSession -Name EXOSession
}

