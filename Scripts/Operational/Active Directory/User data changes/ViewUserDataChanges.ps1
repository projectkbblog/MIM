#####
#
# Script that will query Active Directory replication information to determine when attributes were modified for a given user account, and what domain controller
#  the change occurred on.  The script will automatically attempt to determine the name of the domain, however if that doesn't work as expected or you want to run this
#  across a forest trust you can specify the domain manually using the Domain parameter.
#
# The output from the rep admin command includes the following information 
# - attribute on the user account
# - date and time when the attribute was last updated
# - originating domain controller where the change occurred
# - USN information
#
# Pre-Requisites:
#  - run this as an administrative AD user
#  - run from a computer where the AD remote administration tools and powershell module is installed.
#
# Sample Usage:
#  1.  View the attribute changes for the user account 'asmith' (using the detected domain)
#     - ViewUserDataChanges.ps1 -AccountName asmith
#
#  2.  View the attribute changes for the user account 'asmith' specifying the domain
#     - ViewUserDataChanges.ps1 -AccountName asmith -Domain mydomain.local
#
# Author: Andrew Silcock
# Date Created: 14-Feb-2019
# Version: 1.0
#
#####
param
(
    [parameter(Mandatory=$true)]
    [string] $AccountName,
    [parameter(Mandatory=$false)]
    [string] $Domain
)

# if the domain name wasn't provided - try and determine it from available domain information
if (-not $Domain)
{
    $Domain = (Get-ADDomain).DNSRoot
    "`nDetected the Active Directory domain as {0}" -f $Domain
}
else 
{
    "Using the provided domain {0}" -f $Domain
}

"Retrieving replication information for the account {0}" -f $AccountName
repadmin /showobjmeta $Domain (Get-ADUser $AccountName).DistinguishedName