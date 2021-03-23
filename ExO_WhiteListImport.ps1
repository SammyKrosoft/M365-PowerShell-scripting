#
#  WhiteListImport.ps1 <inputfile.txt>
#
#
#  This script takes as input a txt file of domain names (example.com) one per line, and creates a transport rule with the 
#  name and date of the person running the script. 
# 
#  Up to 100 domains can be imported into a single rule (recommended max)
#
 
 
 
Param(
 
 
[Parameter(Mandatory=$True,Position=1)]
 [string]$domainListFilePath
 )
 
 
$maxlistsize=100
$Date=get-date 
$log = ".\whitelistimport.log"
$Admin=Get-CurrentUser
$RuleName = "Whitelist $date by: " + $Admin.name 
 
Write-host $RuleName
"Admin: " + $admin.name |out-file $log 
$Rulename|out-file $log -Append
Write-host " "
Write-host "About to import:  $rulename from File: $WhiteListFile " -ForeGroundColor Green
Write-host " "
 
Read-Host "Hit ENTER to continue or Ctrl+C to quit"
 
 
#Read the contents of the text file into an array
 $safeDomainList = Get-Content $domainListFilePath
 
#Create a new array and remove all text for each line up to and including the @ symbol, also remove whitespace
 $newSafeDomainList = @()
 $newSafeDomainList += foreach ($domain in $safeDomainList)
     {
     $tmpdomain = $domain -replace “.*@”
     $tmpdomain.trim()
     }
 
Write-host "List size: " $newSafeDomainList.count -ForeGroundColor Green
Write-host " "
 
 
 
#add error checking on filename and contents here
 
if ($newSafeDomainList.count -gt 0)
    {
    if ($newSafeDomainList.count -lt $maxlistsize) 
        {
        “Creating new rule…”
        " "
        $newSafeDomainList = $newSafeDomainList | sort
        $Error.clear();
        New-TransportRule $ruleName -SenderDomainIs $newSafeDomainList -SetSCL -1
        If ($Error -ne $null) {"Error FixingUser [$LineItem.InputDomain]" | Out-File $Log -Append }
        }
 
    if ($newSafeDomainList.count -gt $maxlistsize) 
        {     
        write-host "`n                                                              " -backgroundcolor Blue 
        write-host "    Input List is " $newSafeDomainList.count "Items and must be 100 items or less    " -backgroundcolor Blue -ForegroundColor Yellow 
        write-host "                                                              " -backgroundcolor Blue 
        }
 
    }
Write-host "`nFin..." -ForeGroundColor Green
 
 
