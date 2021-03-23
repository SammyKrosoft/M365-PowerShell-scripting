
#  Blacklist-by-email.ps1 <inputfile.txt>
#
#
#  This script takes as input a txt file of email names (user1@example.com) one per line, and creates a transport rule with the 
#  name and date of the person running the script. 
# 
#  Up to ~80 email addresses can be imported into a single rule
#



Param(


[Parameter(Mandatory=$True,Position=1)]
[string]$emaillistFilePath
)


$maxlistsize=100
$Date=get-date 
$log = ".\blacklistimport2.log"
$Admin=Get-CurrentUser
$RuleName = "Blacklist-by-email $date by: " + $Admin.name 

Write-host $RuleName
"Admin: " + $admin.name |out-file $log 
$Rulename|out-file $log -Append
Write-host " "
Write-host "About to import:  $rulename from File: $emaillistFilePath " -ForeGroundColor Green
Write-host " "

Read-Host "Hit ENTER to continue or Ctrl+C to quit"


#Read the contents of the text file into an array
$safeemaillist = Get-Content $emaillistFilePath


Write-host "List size: " $Safeemaillist.count -ForeGroundColor Green
Write-host " "



#add error checking on filename and contents here

if ($Safeemaillist.count -gt 0)
    {
    if ($Safeemaillist.count -lt $maxlistsize) 
        {
        “Creating new rule…”
        " "
        $Safeemaillist = $Safeemaillist | sort
        $Error.clear();
        New-TransportRule $ruleName -from $Safeemaillist -Quarantine $true
        If ($Error -ne $null) {"Error FixingUser [$LineItem.Inputemail]" | Out-File $Log -Append }
        }

    if ($newSafeemaillist.count -gt $maxlistsize) 
        {     
        write-host "`n                                                              " -backgroundcolor Blue 
        write-host "    Input List is " $Safeemaillist.count "Items and must be 100 items or less    " -backgroundcolor Blue -ForegroundColor Yellow 
        write-host "                                                              " -backgroundcolor Blue 
        }

    }
Write-host "`nFin..." -ForeGroundColor Green


