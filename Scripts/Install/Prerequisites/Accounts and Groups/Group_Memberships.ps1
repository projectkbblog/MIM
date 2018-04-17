#####
#
# Script to assign user accounts to the MIM administrator groups
# the groups and users are defined in a CSV file (see GroupMemberships.csv as a sample file)
#
# Author: Andrew Silcock
# Date Created: 16-Apr-2018
# Version: 0.1
#
#####

param
(
    [Parameter(Mandatory=$false)]
    [string]$File
)


$Memberships = Import-CSV $File


foreach ($m in $Memberships)
{
    Add-ADGroupMember -Identity $m.Group -Members $m.Account
    "Group '{0}' - added user '{1}'" -f $m.Group, $m.Account
}