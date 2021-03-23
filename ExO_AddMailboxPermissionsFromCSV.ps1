#Script to set folder permissions based on list input
#
# See below for variables of $folder and $permission that can be adjusted
 
#input file must have 1st line as a header for CSV values of:  Mailbox,Delegate as follows
#  mailbox,delegate
#  user1@tenant.com,delgateofuser1@tenant.com
#  user2@tenant.com,delgateofuser2@tenant.com
#  ...
#  etc.
#
 
Param(
[Parameter(Mandatory=$True,Position=1)]
[string]$File
)
 
 
# Common permissions are Reviewer, Editor, Contributor
# see http://technet.microsoft.com/en-us/library/dd298062(v=exchg.150).aspx  
 
#            The AccessRights parameter specifies the permissions for the user with the following access rights:
#            • ReadItems   The user has the right to read items within the specified folder.
#            • CreateItems   The user has the right to create items within the specified folder.
#            • EditOwnedItems   The user has the right to edit the items that the user owns in the specified folder.
#            • DeleteOwnedItems   The user has the right to delete items that the user owns in the specified folder.
#            • EditAllItems   The user has the right to edit all items in the specified folder.
#            • DeleteAllItems   The user has the right to delete all items in the specified folder.
#            • CreateSubfolders   The user has the right to create subfolders in the specified folder.
#            • FolderOwner   The user is the owner of the specified folder. The user has the right to view and move the folder and create subfolders. The user can't read items, edit items, delete items, or create items.
#            • FolderContact   The user is the contact for the specified public folder.
#            • FolderVisible   The user can view the specified folder, but can't read or edit items within the specified public folder.
#            
#            The AccessRights parameter also specifies the permissions for the user with the following roles, which are a combination of the rights listed previously:
#            • None   FolderVisible
#            • Owner   CreateItems, ReadItems, CreateSubfolders, FolderOwner, FolderContact, FolderVisible, EditOwnedItems, EditAllItems, DeleteOwnedItems, DeleteAllItems
#            • PublishingEditor   CreateItems, ReadItems, CreateSubfolders, FolderVisible, EditOwnedItems, EditAllItems, DeleteOwnedItems, DeleteAllItems
#            • Editor   CreateItems, ReadItems, FolderVisible, EditOwnedItems, EditAllItems, DeleteOwnedItems, DeleteAllItems
#            • PublishingAuthor   CreateItems, ReadItems, CreateSubfolders, FolderVisible, EditOwnedItems, DeleteOwnedItems
#            • Author   CreateItems, ReadItems, FolderVisible, EditOwnedItems, DeleteOwnedItems
#            • NonEditingAuthor   CreateItems, ReadItems, FolderVisible
#            • Reviewer   ReadItems, FolderVisible
#            • Contributor   CreateItems, FolderVisible
#
#            The following roles apply specifically to calendar folders: 
#
#            • AvailabilityOnly   View only availability data
#            • LimitedDetails   View availability data with subject and location
#
 
$permission="Reviewer"
# common folder types are :\inbox and :\calendar
$folder=":\inbox" 
 
$list = import-csv $file 
$list.count 
 
Write-host " "
Write-host "About to parse file:" $file "of" $list.count "items" -ForeGroundColor Green
Write-host " "
 
Read-Host "Hit ENTER to continue or Ctrl+C to quit"
 
 
$i=0
Foreach ($mailbox in $list)
{
    $j=$i+1
    Write-host  $j "of" $list.count "Adding $permission permission for mailbox"$list.mailbox[$i] $folder "to Delegate" $list.delegate[$i]  -ForeGroundColor Green

# used for testing (removes permission before assignment
 
    #Remove-MailboxFolderPermission -Identity ($list.mailbox[$i]+":\Inbox") -user $list.delegate[$i] -Confirm:$false
 
 
    Add-MailboxFolderPermission -Identity ($list.mailbox[$i]+":\Inbox") -user $list.delegate[$i] -accessrights $Permission
    $i++
}
