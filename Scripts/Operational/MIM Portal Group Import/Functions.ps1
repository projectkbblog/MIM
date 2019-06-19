# Template for the group filter (Xpath Query goes in place of {0})
$GroupFilterTemplate = "<Filter xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" Dialect=""http://schemas.microsoft.com/2006/11/XPathFilterDialect"" xmlns=""http://schemas.xmlsoap.org/ws/2004/09/enumeration"">{0}</Filter>"

# Get's a user from the MIM Service using their account name
function Get-UserByAccountName
{
    param
    (
        [Parameter(Mandatory=$true)]
        [string] $AccountName
    )

    return Get-Resource -ObjectType Person -AttributeName AccountName -AttributeValue $AccountName
}

# Checks against the MIM Service if a group already exists with the given DisplayName
function Does-GroupAlreadyExist
{
    param
    (
        [Parameter(Mandatory=$true)]
        [string] $DisplayName
    )

    try
    {
        $Group = Get-Resource -ObjectType Group -AttributeName DisplayName -AttributeValue $DisplayName -ErrorAction SilentlyContinue
    }
    catch
    {
        return $false
    }

    if ($Group)
    {
        return $true
    }
    else
    {
        return $false
    }
}

# Determines if the group is dynamic (based on the membership locked value)
function Is-GroupDynamic
{
    param
    (
        [Parameter(Mandatory=$false)]
        [string] $MembershipLocked
    )

    if ($MembershipLocked -and ($MembershipLocked -eq "true"))
    {
        return $true
    }
    else
    {
        return $false
    }
}

# Generates a group object that can then be saved in the MIM Service
function Generate-GroupObject
{
    param
    (
        $GroupData
    )
    # determine if the group is dynamic
    $DynamicGroup = Is-GroupDynamic -MembershipLocked $GroupData.MembershipLocked

    # Create the group object
    $newObject = New-Resource -ObjectType Group
    $newObject.AccountName = $CurGroup.AccountName
    $newObject.DisplayName = $CurGroup.DisplayName
    $newObject.Domain = $CurGroup.Domain
    $newObject.MembershipAddWorkflow = $CurGroup.MembershipAddWorkflow
    $newObject.MembershipLocked = $DynamicGroup
    $newObject.Scope = $CurGroup.Scope
    $newObject.Type = $CurGroup.Type

    # only set mailnickname/description if they have a value
    if ($CurGroup.MailNickname) { $newObject.MailNickname =  $CurGroup.MailNickname }
    if ($CurGroup.Description) { $newObject.Description = $CurGroup.Description }

    # only set owner attributes if they have a value
    if ($Owner)
    {
        $newObject.Owner = $Owner.ObjectID.Value;
    }
    if ($DisplayedOwner)
    {
        $newObject.DisplayedOwner = $DisplayedOwner.ObjectID.Value;
    }
    # only set the filter if a dynamic group
    if ($DynamicGroup)
    {
        $newObject.Filter = ($GroupFilterTemplate -f $CurGroup.Filter)
    }

    return $newObject
}