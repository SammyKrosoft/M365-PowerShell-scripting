# Change user@contoso.com to the mailbox you want to find In-Place Holds for
$mailbox = Get-Mailbox user@contoso.com
 $holds = foreach ($hold in $mailbox.InPlaceHolds) {
 $search = Get-MailboxSearch -InPlaceHoldIdentity $hold
 
 # Returns UPN instead of SID to easily identify who created the eDiscovery Search
 $createdByUpn = (Get-User $search.CreatedBy).UserPrincipalName
 $search | Add-Member -MemberType NoteProperty -Name CreatedByUPN -Value $createdByUpn
 $search
 }
 $holds | ft Name, CreatedByUPN, InPlaceHoldEnabled, Status -AutoSize
