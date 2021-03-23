<#
.DESCRIPTION

.LINK
Advanced identity integration with Office 365 using FIM and the Windows Azure Active Directory (WAAD) Management agent.   That guidance is now available on TechNet Here :
http://aka.ms/WAADFIMQuickStart
http://aka.ms/WAADTechRef
 
One of the many advantages of the migration of a traditional account forest \ resource forest model to Office 365 is the ability to collapse the resource forest upon completion.

.LINK
I use the Quest powershell cmdlets, you can get those here : 
http://www.quest.com/powershell/activeroles-server.aspx
#>

# Source forest is the Exchange Resource Forest
 
$Source = Connect-QADService sourcedomain.local -Credential "sourcedomain\Administrator"
 
# Target forest is the Account Forest
 
$Target = Connect-QADService targetdomain.local -Credential "targetdomain\Administrator"
 
# Create an array of all users in targetdomain.local\Users OU, only capturing sAMAccountName, ObjectSid and mail
 
$users = Get-QADuser * -connection $target -includedProperties "objectSid,sAMAccountName,mail" -SearchRoot "OU=users,DC=targetdomain,DC=local" 
 
# Loop, match on mail, and set attributes via the –ObjectAttributes array method
 
foreach ($user in $users) 
 
{
 
   $SourceUser = Get-QADUser $user.mail -Connection $Source -includedProperties "mail,msExchMasterAccountSID,extensionattribute1,extensionattribute2"
 
   Set-QADUser $user.mail -connection $target -ObjectAttributes @{extensionAttribute1 = $SourceUser.extensionAttribute1;extensionattribute2 = $SourceUser.extensionattribute2} 
 
}
