# Template for the group filter
$GroupFilterTemplate = "<Filter xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" Dialect=""http://schemas.microsoft.com/2006/11/XPathFilterDialect"" xmlns=""http://schemas.xmlsoap.org/ws/2004/09/enumeration"">{0}</Filter>"

function Get-UserByAccountName
{
    param
    (
        [Parameter(Mandatory=$true)]
        [string] $AccountName
    )

    return Get-Resource -ObjectType Person -AttributeName AccountName -AttributeValue $AccountName
}

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

function Generate-GroupObject
{
    param
    (
        $GroupData
    )
    $newObject = New-Resource -ObjectType Group
    $newObject.AccountName = $CurGroup.AccountName
    $newObject.DisplayName = $CurGroup.DisplayName
    $newObject.MailNickname =  $CurGroup.MailNickname
    $newObject.Description = $CurGroup.Description
    $newObject.Domain = $CurGroup.Domain
    $newObject.MembershipAddWorkflow = $CurGroup.MembershipAddWorkflow
    $newObject.MembershipLocked = $DynamicGroup
    $newObject.Scope = $CurGroup.Scope
    $newObject.Type = $CurGroup.Type

    if ($Owner)
    {
        $newObject.Owner = $Owner.ObjectID.Value;
    }
    if ($DisplayedOwner)
    {
        $newObject.DisplayedOwner = $DisplayedOwner.ObjectID.Value;
    }
    $newObject.Filter = ($GroupFilterTemplate -f $CurGroup.Filter)

    return $newObject
}