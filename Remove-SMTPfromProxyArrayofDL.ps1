# calling: .\Modify-email.ps1 <groupname> <smtp> <type>
# get object name - user or dl
# confirm it's valid
# read in email address array
# display values
# promp for value to omit
# reconstruct array from remailing values
# write back to object
# Ver 2.0 will not display  :)   

param
(
    [parameter(position = 0,mandatory=$true,helpmessage="Enter the name of the group.")]
    [string] $objectname,
    [parameter(position = 1,mandatory=$true,helpmessage="Enter the action: Add or Remove")]
    [string] $action
)
# write-host $objecttype,$objectname,$removesmtp
 
#check for msonline connectivity
if (!(get-module -name msonline))
{
import-module msonline
$cred = Get-Credential
Connect-MsolService –Credential $cred
}
 
# check for exo ps commands are  loaded
if (!(get-pssession | where {$_.configurationname -match "Microsoft.Exchange"}))
{
$s = New-PSSession -ConfigurationName Microsoft.Exchange –ConnectionUri https://ps.outlook.com/powershell -Credential $cred -Authentication Basic –AllowRedirection
Import-PSSession $s
}
 
if ($action -eq "Remove")
{
  if (!(Get-DistributionGroup -Identity $objectname)){write-host -fore red "$objectname does not exist.";exit} 
  if ((Get-MsolGroup -ObjectId ((Get-DistributionGroup -Identity $objectname).ExternalDirectoryObjectId)).lastdirsynctime -ne $null){write-host -fore red "$objectname is sync'd from on prem.";exit} 
 
     $arrsmtp = (Get-DistributionGroup -Identity $objectname).emailaddresses
     foreach ($number in (0 .. ($arrsmtp.count -1))){if(!($arrsmtp[$number] -match "X500")){Write-host "[$number] "$arrsmtp[$number]}}
     $remove = read-host "Please enter the number of the SMTP value you want to remove from this $objecttype"
     if ($arrsmtp[$remove] -cmatch "SMTP:"){write-host -fore red "You cannot remove the PRIMARY SMTP address";exit}
     if ($arrsmtp[$remove] -match "X500:"){exit}
     if ($remove -ge $arrsmtp.count){exit}
     write-host "Removing: "$arrsmtp[$remove]
     $newarrSMTP = @($arrsmtp|where{$_ -ne $arrsmtp[$remove]})
     #write-host $newarrsmtp
     Set-DistributionGroup -Identity $objectname -EmailAddresses $newarrSMTP
}   
if ($action -eq "Add")
{
  if (!(Get-DistributionGroup -Identity $objectname)){write-host -fore red "$objectname does not exist.";exit} 
  if ((Get-MsolGroup -ObjectId ((Get-DistributionGroup -Identity $objectname).ExternalDirectoryObjectId)).lastdirsynctime -ne $null){write-host -fore red "$objectname is sync'd from on prem.";exit} 
     $arrsmtp = (Get-DistributionGroup -Identity $objectname).emailaddresses
     write-host "arrsmtp"$arrsmtp
     $newsmtp = read-host "Enter the SMTP address to add. Type smtp:<email>"
     write-host "newsmtp"$newsmtp
     $arrsmtp += $newsmtp
     write-host "newarrsmtp"$arrsmtp
     Set-DistributionGroup -Identity $objectname -EmailAddresses $arrSMTP  
}