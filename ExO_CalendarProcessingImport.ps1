# aarontie@microsoft.com

param(
[string]$csvfile
)

# As of 06/05/2014, non-user mailboxes are limited to 10GB *going up to 50GB

$ProhibitSendReceiveQuota = 10GB
$ProhibitSendQuota = 9.75GB
$IssueWarningQuota = 9.5GB

$users = import-csv $csvfile
foreach ($user in $users)
{
	Write-Host Processing user: $user.EmailAddress -ForegroundColor Yellow

	# Verify mailbox exists
	$test = Get-Mailbox $user.EmailAddress -ErrorAction SilentlyContinue

	if ($test -ne $null) {

		if ($user.RoomType -eq "Shared" -or $user.RoomType -eq "Room" -or $user.RoomType -eq "Equipment")
		{
			# Do the "clever" stuff to find out if mbx is less than $IssueWarningQuota 
			$stat = Get-MailboxStatistics $user.EmailAddress
			$tmp = $stat.TotalItemSize.Value.ToString().Split("(")[0].Replace(" ","")
			$mb = Invoke-Expression $tmp/1MB
			if ([int]$mb -lt $IssueWarningQuota) {

				# Setting the actual mailbox parameters
				Write-Host Converting user $user.EmailAddress to $user.RoomType and setting quota to $ProhibitSendReceiveQuota

				#[long]$longProhibitSendReceiveQuota = $ProhibitSendReceiveQuota

				#Set-Mailbox -Identity $user.EmailAddress -Type $user.RoomType -IssueWarningQuota [long]$IssueWarningQuota
				#Set-Mailbox -Identity $user.EmailAddress -Type $user.RoomType -ProhibitSendQuota [long]$ProhibitSendQuota
				#Set-Mailbox -Identity $user.EmailAddress -Type $user.RoomType -ProhibitSendReceiveQuota [long]$ProhibitSendReceiveQuota

				Set-Mailbox -Identity $user.EmailAddress -Type $user.RoomType -IssueWarningQuota 9.5GB
				Set-Mailbox -Identity $user.EmailAddress -Type $user.RoomType -ProhibitSendQuota 9.75GB
				Set-Mailbox -Identity $user.EmailAddress -Type $user.RoomType -ProhibitSendReceiveQuota 10GB

				# Adding permissions
				if ($user.Recipient -ne $null) {
					Write-Host Adding permissions for $user.Recipient on $user.EmailAddress
					Add-MailboxPermission $user.EmailAddress -User $user.ResourceDelegates -AccessRights FullAccess -AutoMapping ?{([bool]::Parse($user.AutoMapping) -eq "TRUE")}
					Add-RecipientPermission $user.EmailAddress -Trustee $user.ResourceDelegates -AccessRights SendAs -Confirm:$false
				}
				
				if ($user.RoomType -eq "Room" -or $user.RoomType -eq "Equipment") {
					Write-Host Setting calendar options for $user.EmailAddress

					#[System.Convert]::ToBoolean($persistent)	
					[boolean]$bAddAdditionalResponse = [System.Convert]::ToBoolean($user.AddAdditionalResponse)
					Set-CalendarProcessing -identity $user.EmailAddress -AddAdditionalResponse $bAddAdditionalResponse 

					Set-CalendarProcessing -identity $user.EmailAddress -AdditionalResponse $user.AdditionalResponse 

					[boolean]$bAddNewRequestsTentatively = [System.Convert]::ToBoolean($user.AddNewRequestsTentatively)
					Set-CalendarProcessing -identity $user.EmailAddress -AddNewRequestsTentatively $bAddNewRequestsTentatively

					[boolean]$bAddOrganizerToSubject = [System.Convert]::ToBoolean($user.AddOrganizerToSubject)
					Set-CalendarProcessing -identity $user.EmailAddress -AddOrganizerToSubject $bAddOrganizerToSubject 

					[boolean]$bAllowConflicts = [System.Convert]::ToBoolean($user.AllowConflicts)
					Set-CalendarProcessing -identity $user.EmailAddress -AllowConflicts $bAllowConflicts 

					[boolean]$bAllowRecurringMeetings = [System.Convert]::ToBoolean($user.AllowRecurringMeetings)
					Set-CalendarProcessing -identity $user.EmailAddress -AllowRecurringMeetings $bAllowRecurringMeetings

					[boolean]$bAllRequestInPolicy = [System.Convert]::ToBoolean($user.AllRequestInPolicy)
					Set-CalendarProcessing -identity $user.EmailAddress -AllRequestInPolicy $bAllRequestInPolicy

					[boolean]$bAllRequestOutOfPolicy = [System.Convert]::ToBoolean($user.AllRequestOutOfPolicy)
					Set-CalendarProcessing -identity $user.EmailAddress -AllRequestInPolicy $bAllRequestOutOfPolicy

					Set-CalendarProcessing -identity $user.EmailAddress -AutomateProcessing $user.AutomateProcessing 

					[int]$intBookingWindowInDays = [System.Convert]::ToInt32($user.BookingWindowInDays)
					Set-CalendarProcessing -identity $user.EmailAddress -BookingWindowInDays $intBookingWindowInDays  

					[boolean]$bDeleteAttachments = [System.Convert]::ToBoolean($user.DeleteAttachments)
					Set-CalendarProcessing -identity $user.EmailAddress -DeleteAttachments $bDeleteAttachments

					[boolean]$bDeleteComments = [System.Convert]::ToBoolean($user.DeleteComments)
					Set-CalendarProcessing -identity $user.EmailAddress -DeleteComments $bDeleteComments

					[boolean]$bDeleteNonCalendarItems = [System.Convert]::ToBoolean($user.DeleteNonCalendarItems)
					Set-CalendarProcessing -identity $user.EmailAddress -DeleteNonCalendarItems $bDeleteNonCalendarItems

					[boolean]$bDeleteSubject = [System.Convert]::ToBoolean($user.DeleteSubject)
					Set-CalendarProcessing -identity $user.EmailAddress -DeleteSubject $bDeleteSubject  

					#[boolean]$bDisableReminders = [System.Convert]::ToBoolean($user.DisableReminders)
					#Set-CalendarProcessing -identity $user.EmailAddress -DisableReminders $bDisableReminders 

					[boolean]$bEnableResponseDetails = [System.Convert]::ToBoolean($user.EnableResponseDetails)
					Set-CalendarProcessing -identity $user.EmailAddress -EnableResponseDetails $bEnableResponseDetails

					[boolean]$bEnforceSchedulingHorizon = [System.Convert]::ToBoolean($user.EnforceSchedulingHorizon)
					Set-CalendarProcessing -identity $user.EmailAddress -EnforceSchedulingHorizon $bEnforceSchedulingHorizon

					[boolean]$bForwardRequestsToDelegates = [System.Convert]::ToBoolean($user.ForwardRequestsToDelegates)
					Set-CalendarProcessing -identity $user.EmailAddress -ForwardRequestsToDelegates $bForwardRequestsToDelegates

					[int]$intMaximumDurationInMinutes = [System.Convert]::ToInt32($user.MaximumDurationInMinutes)
					Set-CalendarProcessing -identity $user.EmailAddress -MaximumDurationInMinutes $intMaximumDurationInMinutes 

					# Set-CalendarProcessing -identity $user.EmailAddress -OrganizerInfo $user.OrganizerInfo 

					[boolean]$bProcessExternalMeetingMessages = [System.Convert]::ToBoolean($user.ProcessExternalMeetingMessages)
					Set-CalendarProcessing -identity $user.EmailAddress -ProcessExternalMeetingMessages $bProcessExternalMeetingMessages

					[boolean]$bRemoveForwardedMeetingNotifications = [System.Convert]::ToBoolean($user.RemoveForwardedMeetingNotifications)
					Set-CalendarProcessing -identity $user.EmailAddress -RemoveForwardedMeetingNotifications $bRemoveForwardedMeetingNotifications

					[boolean]$bRemoveOldMeetingMessages = [System.Convert]::ToBoolean($user.RemoveOldMeetingMessages)
					Set-CalendarProcessing -identity $user.EmailAddress -RemoveOldMeetingMessages $bRemoveOldMeetingMessages

					[boolean]$bRemovePrivateProperty = [System.Convert]::ToBoolean($user.RemovePrivateProperty)
					Set-CalendarProcessing -identity $user.EmailAddress -RemovePrivateProperty $bRemovePrivateProperty

					#[boolean]$bRequestInPolicy = [System.Convert]::ToBoolean($user.RequestInPolicy)
					#Set-CalendarProcessing -identity $user.EmailAddress -RequestInPolicy $bRequestInPolicy

					#[boolean]$bRequestOutOfPolicy = [System.Convert]::ToBoolean($user.RequestOutOfPolicy)
					#Set-CalendarProcessing -identity $user.EmailAddress -RequestOutOfPolicy $bRequestOutOfPolicy

					Set-CalendarProcessing -identity $user.EmailAddress -ResourceDelegates $user.ResourceDelegates 

					[boolean]$bScheduleOnlyDuringWorkHours = [System.Convert]::ToBoolean($user.ScheduleOnlyDuringWorkHours)
					Set-CalendarProcessing -identity $user.EmailAddress -ScheduleOnlyDuringWorkHours $bScheduleOnlyDuringWorkHours

					[boolean]$bTentativePendingApproval  = [System.Convert]::ToBoolean($user.TentativePendingApproval)
					Set-CalendarProcessing -identity $user.EmailAddress -TentativePendingApproval $bTentativePendingApproval
				}
				
				# Remove the license, Shared Mailboxes with a 10GB limit are free of charge

				#Write-Host Removing license for $user.EmailAddress

				#$MSOLSKU = (Get-MSOLUser -UserPrincipalName $user.EmailAddress).Licenses[0].AccountSkuId
				#Set-MsolUserLicense -UserPrincipalName $user.EmailAddress -RemoveLicenses $MSOLSKU
				Write-Host Done! -ForegroundColor Green
			}
		}
	}
}



<#
Example CSV:
EmailAddress	RoomType	AutomateProcessing	AllowConflicts	BookingWindowInDays	MaximumDurationInMinutes	AllowRecurringMeetings	EnforceSchedulingHorizon	ScheduleOnlyDuringWorkHours	ForwardRequestsToDelegates	DeleteAttachments	DeleteComments	RemovePrivateProperty	DeleteSubject	DisableReminders	AddOrganizerToSubject	DeleteNonCalendarItems	TentativePendingApproval	EnableResponseDetails	OrganizerInfo	$_.ResourceDelegates	RequestOutOfPolicy	AllRequestOutOfPolicy	RequestInPolicy	AllRequestInPolicy	AddAdditionalResponse	AdditionalResponse	RemoveOldMeetingMessages	AddNewRequestsTentatively	ProcessExternalMeetingMessages	RemoveForwardedMeetingNotifications		
DigitalProdDevelop@contoso.com	Shared	AutoAccept	FALSE	180	1440	TRUE	TRUE	FALSE	TRUE	TRUE	TRUE	TRUE	TRUE	TRUE	TRUE	TRUE	TRUE	TRUE	TRUE			FALSE		FALSE	FALSE		TRUE	TRUE	FALSE	FALSE		
#>