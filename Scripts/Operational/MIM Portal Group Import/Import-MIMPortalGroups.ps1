param
(
    [Parameter(Mandatory=$false)]
    [string] $MIMServiceHost,
    [Parameter(Mandatory=$true)]
    [string] $GroupsFile
)

if (-not $MIMServiceHost)
{
    $MIMServiceHost = "localhost"    
}
. .\Functions.ps1

try
{
    Import-Module LithnetRMA
}
catch
{
    Write-Warning "The LithnetRMA module is not installed, please download and install it from 'https://github.com/lithnet/resourcemanagement-powershell/wiki/installing-the-module'"
    exit -1
}

# Define the MIM Service Host address
Set-ResourceManagementClient -BaseAddress ("http://{0}:5725" -f $MIMServiceHost)

# Import the groups file
"Reading Group data from {0}" -f $GroupsFile
$GroupsCsv = Import-CSV -Path $GroupsFile
$counter = 1
foreach($CurGroup in $GroupsCsv)
{
    "`n{0} - {1} - Processing the Group '{2}'" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $counter, $CurGroup.DisplayName

    # If the group is dynamic then get the owner/displayed owner
    $DynamicGroup = Is-GroupDynamic -MembershipLocked $CurGroup.MembershipLocked
    if ($DynamicGroup)
    {
        "`tResolving group owner references"
        # Get the reference for the group owner
        $Owner =  Get-UserByAccountName -AccountName $CurGroup.Owner
        $DisplayedOwner = Get-UserByAccountName -AccountName $CurGroup.DisplayedOwner
    }

    if (Does-GroupAlreadyExist -DisplayName $CurGroup.DisplayName)
    {
        "`tGroup already exists - no action being taken"
    }
    else
    {
        "`tGroup doesn't yet exit - creating the group"
        # Generate the group object
        $NewGroup = Generate-GroupObject -GroupData $CurGroup 

        # SAve the resource to the MIM Service (this is a LithnetRMA cmdlet)
        Save-Resource $NewGroup    
        "`tGroup created"
    }
    $counter++
}