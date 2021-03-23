 
#Note:  input file looks like this: (without # signs)
#
#Delegator: alvin.powell
# Delegate: terrence.schnarrs
# Status: ACCEPTED
# Delegate Email: terrence.schnarrs@ferc.gov
# Delegate ID: terrence.schnarrs@ferc.gov
#
#Delegator: Old_Efiling
# Delegate: Anthony Trice
# Status: ACCEPTED
# Delegate Email: anthony.trice@ferc.gov
# Delegate ID: anthony.trice@ferc.gov
#
 
 
#adjust variables below for different behaviors
 
 
 
param
(
    $GooglePermissionsFile = (Read-Host "Enter file path of Google Permissions Export").Trim('"')
)
 
$log = ".\FERC-MailboxFolderPermissions.log"
Get-Date | Out-File $Log 
 
$Folder=':\inbox'
$Domain='@mikemilq.us'
$Folderpermission='Reviewer'
 
 
 
 
# probably won't need to change this, but so that it's not hard coded..
$separator = ": "
 
# get the permissions text, don't continue if you can't!
$GooglePermissionsText = Get-Content $GooglePermissionsFile -ErrorAction Stop
 
# we're going to build a hash since it's easy to add to and convert to array of values when done
$gPermHash = @{}
$currentIndex = 0
 
# make sure our temp working object is null from anything previous
$gPermObj = $null
 
# create collection of permissions 
$GooglePermissions = foreach ($gPermLine in $GooglePermissionsText)
{
    if ($gPermLine -eq "")
    { # we're done with the section of keys, so save to collection and reset temp var
        if ($gPermObj)
        {
            $gPermHash.Add($currentIndex, $gPermObj)
            $currentIndex++
            $gPermObj = $null
        }
        continue
    }
    # init the temp var if needed
    if (!$gPermObj)
    {
        $gPermObj = [pscustomobject]@{}
    }
    # save the next encountered keys and value
    # have to use substring logic since the separator may have multiple chars
    $separatorIndex = $gPermLine.IndexOf(": ")
    $key = $gPermLine.Substring(0, $separatorIndex)
    $key = $key.Trim(' ')
    $key = $key.Replace(" ", "")
 
 
    $value = $gPermLine.Substring($separatorIndex + $separator.Length)
    $gPermObj | Add-Member -MemberType NoteProperty -Name $key -Value $value
}
 
# save last one in case the text file did not have a trailing empty line
if ($gPermObj)
{
    $gPermHash.Add($currentIndex, $gPermObj)
    $currentIndex++
    $gPermObj = $null
}
 
# grab just values of hash which are the objects we want in an array
$GooglePermissions = $gPermHash.Values
 
 
$i=0
 
$GooglePermissions | Foreach {
    $i++
    " "
    "Working on "+$i
    " "
    $DelegatorEmail=$GooglePermissions.Delegator[$i]+$Domain+$Folder
    $DelegateEmail=$GooglePermissions.DelegateEmail[$i]
    $Error.clear();
 
    "Granting: "+$DelegateEmail
    "permissions to: "+$DelegatorEmail
    
    " "
    "Current permissions: " 
    " "
    Get-MailboxFolderPermission -Identity $Delegatoremail
   
    #"Removing: "
    #remove-MailboxFolderPermission -Identity $Delegatoremail -User $DelegateEmail -Confirm:$False
   
    " "
    "Adding: "
    " "
    Add-MailboxFolderPermission -Identity $Delegatoremail -User $DelegateEmail -AccessRights $Folderpermission
 
    
 
    If ($Error -ne $null) {"Error FixingUser [$DelegatorEmail]" | Out-File $Log -Append }
} 
 
