<#

Compare-ObjectProperties.ps1 | Version 1.4

by David.Whitney@microsoft.com

THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED “AS IS” WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR
PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.

.Synopsis
   Compares two objects' properties
.DESCRIPTION
   Compares two objects' properties, with options to filter by property or
   properties, and show matching properties as well as different, or don't
   show differing properties at all
.EXAMPLE
   .\Compare-ObjectProperties.ps1 $obj1 $obj2

   Show properties that differ between $obj1 and $obj2
.EXAMPLE
   .\Compare-ObjectProperties.ps1 $obj1 $obj2 -IncludeEqual -ExcludeDifferent

   Show only properties that are the same betweeen $obj1 and $obj2
.EXAMPLE
   .\Compare-ObjectProperties.ps1 $obj1 $obj2 -CompareCollections

   Show properties that differ betweeen $obj1 and $obj2, including checking item values for properties that are collections
.EXAMPLE
   .\Compare-ObjectProperties.ps1 $obj1 $obj2 -Properties property1, property2, wilcardprop* -IncludeEqual

   Show how property1, property2, and any properties with names starting with wildcardprop
   differ and are the same between $obj1 and $obj2
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true,
               Position=0)]
    [ValidateNotNullOrEmpty()]
    $Left,
    
    [Parameter(Mandatory=$true,
               Position=1)]
    [ValidateNotNullOrEmpty()]
    $Right,

    [Parameter(Mandatory=$false,
               Position=2)]
    [string[]]
    $Property,
    
    [Parameter(Mandatory=$false)]
    [switch]
    $IncludeEqual,

    [Parameter(Mandatory=$false)]
    [switch]
    $ExcludeDifferent,

    [Parameter(Mandatory=$false)]
    [switch]
    $ExcludeEmpty,

    [Parameter(Mandatory=$false)]
    [switch]
    $CompareCollections
)

# Change these string results for aesthetics
function sameValueString  ($value)    {"<< same value >>"}
function noPropertyString ($property) {"<< no property >>"}

# Get the names of the properties of the objects
$propertiesLeft  = ($Left  | gm | ? {($_.MemberType -like "Property") -or ($_.MemberType -like "NoteProperty")}).Name
$propertiesRight = ($Right | gm | ? {($_.MemberType -like "Property") -or ($_.MemberType -like "NoteProperty")}).Name

Write-Verbose "Left object properties:  $propertiesLeft"
Write-Debug   "Left object properties:  $propertiesLeft"
Write-Verbose "Right object properties: $propertiesRight"
Write-Debug   "Right object properties: $propertiesRight"

# Combine property names
# Have to check for nulls as `compare` throws an error on null input
# (Using `compare` here to an easy way to deal with zero- or one-property objects that would not give a Collection of properties)
$propertiesBoth = if     (!$propertiesLeft ) {$propertiesRight}
                  elseif (!$propertiesRight) {$propertiesLeft }
                  else                       {compare $propertiesLeft $propertiesRight -IncludeEqual -PassThru}

# Ensure resulting properties list is a Collection, even if a single property
$script:propertiesList = [string[]]$propertiesBoth

Write-Debug "Properties list (unfiltered): $script:propertiesList"

if ($Property) {
    # Property list specified by user, so have to limit list to those specified

    $userPropertyList = @()
    foreach ($userProperty in $Property) {
        # using -like here gives wildcard support for free
        $matchingProperties = $script:propertiesList -like $userProperty
        $userPropertyList += if ($matchingProperties) {$matchingProperties} else {$userProperty}
    }
    $script:propertiesList = $userPropertyList | sort -Unique
    Write-Debug ">> Properties list (filtered by -Property): $script:propertiesList"
}

# Loop through properties to compare
foreach ($objectProperty in $script:propertiesList) {
    # First check that both objects have (or don't have) the property, and then that either both properties are null/empty or are equal
    # Need the property check to because, for example, `.length` on a number returns a non-null response
    # Need null/empty check as '-eq' against sets returns the members that match, which would be nothing ("false") for two empty sets
    $propertiesAreSame = $false
    if (!(($propertiesLeft -contains $objectProperty) -xor ($propertiesRight -contains $objectProperty))) {
        Write-Debug "Both objects have property $objectProperty"
        
        # Check if both properties are null/empty
        if (!$Left.$objectProperty -and !$Right.$objectProperty) {
            Write-Debug "Both objects have empy or null property $objectProperty"
            $propertiesAreSame = $true
        }

        # Check if both properties are equal with object comparison
        if ($Left.$objectProperty -eq $Right.$objectProperty) {
            Write-Verbose "Both objects have equal-object property $objectProperty"
            $propertiesAreSame = $true
        }

        # Check if collections contain same items if asked
        if ($CompareCollections -and ($Left.$objectProperty -and $Right.$objectProperty)) {
            Write-Debug "Asked to compare collections and both objects have values for property $objectProperty"
            
            $leftPropertyType  =  $Left.$objectProperty.GetType()
            $rightPropertyType = $Right.$objectProperty.GetType()
            Write-Debug " Left type:  $leftPropertyType"
            Write-Debug " Right type: $rightPropertyType"
            if (    ( $leftPropertyType.IsArray -or ( $leftPropertyType.FullName -ilike "*collections*")) `
                    -and 
                    ($rightPropertyType.IsArray -or ($rightPropertyType.FullName -ilike "*collections*"))) {
                Write-Debug "Both objects have collection types for property $objectProperty"
                $compareout = compare $Left.$objectProperty $Right.$objectProperty
                Write-Debug "Output of compare: $compareout"
                if (!($compareout)) {
                    Write-Debug "Both objects have collections whose items are the same for property $objectProperty"
                    $propertiesAreSame = $true
                }
            }
        }
    }
    
    if ($propertiesAreSame) {
        Write-Debug "Same values for property $objectProperty"
        Write-Debug " Left:  $($Left.$objectProperty)"
        Write-Debug " Right: $($Right.$objectProperty)"

        if ($IncludeEqual) {
            $valueLeft  = if ($propertiesLeft  -contains $objectProperty) {                 $Left.$objectProperty} else {noPropertyString $objectProperty}
            $valueRight = if ($propertiesRight -contains $objectProperty) {sameValueString $Right.$objectProperty} else {noPropertyString $objectProperty}
            
            if ($ExcludeEmpty -and (($valueLeft -eq "") -or ($valueLeft -eq $null))) {
                # empty property, so skip if told to
                Write-Verbose "Excluding empty property $objectProperty" 
                continue
            }
            
            [pscustomobject]@{Property   = $objectProperty;
                              ValueLeft  = $valueLeft;
                              ValueRight = $valueRight}
        } 
    } else {
        Write-Debug "Different values for property $objectProperty"
        Write-Debug " Left:  $($Left.$objectProperty)"
        Write-Debug " Right: $($Right.$objectProperty)"

        if (!$ExcludeDifferent) {
            $valueLeft  = if ($propertiesLeft  -contains $objectProperty) { $Left.$objectProperty} else {noPropertyString $objectProperty}
            $valueRight = if ($propertiesRight -contains $objectProperty) {$Right.$objectProperty} else {noPropertyString $objectProperty}
            [pscustomobject]@{Property   = $objectProperty;
                              ValueLeft  = $valueLeft;
                              ValueRight = $valueRight}
        }
    }
}