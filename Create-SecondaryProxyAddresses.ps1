 <#
.NOTES
Author : Darryl Kegg



.NOTES
  Just in case you want to use a regex match in the proxy IF statement  (my customer uses an employeeID@contoso.com and I want to use that for an alternate smtp.

    $regex = “[A-Z0-9._%+-]+[0-9][0-9][0-9][0-9]@[A-Z0-9.-]+\.[A-Z]{2,4}”
    Get-MsolUser -all |?{$_.UserPrincipalName -match $regex} | select-object UserPrincipalName,displayname,lastdirsynctime,islicensed

 #>

if(!(get-module -name ActiveDirectory)){import-module ActiveDirectory}
$userlist = get-aduser  -Filter * -SearchBase "DC=contoso,DC=com" -properties SamAccountName, ProxyAddresses, DisplayName
foreach ($user in $userlist)
{
$proxies = $user.proxyaddresses
$primarySMTP = $null
foreach ($proxy in $proxies)
  {
  if ($proxy -cmatch "SMTP"){$primarySMTP = $proxy.split("@")}
  }
if (!($primarySMTP))
  {write-host "No primary SMTP located for "$user.displayname}
else
  {
  $newSMTP = $primarySMTP[0]+"@wyn365.mail.onmicrosoft.com"
  set-aduser -identity $user.samaccountname -add @{proxyaddresses=$newSMTP.tolower()}
  }
}
