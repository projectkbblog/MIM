#####
#
# Script to create a MIM Portal administrative user based on the details of their Active Directory account
#
# Dependencies:
#   - The script must be run by a user with Administrator access to the MIM Portal
#   - Depends on the LithnetRMA PowerShell module (https://github.com/lithnet/resourcemanagement-powershell/wiki/installing-the-module)
#   - Depends on the Active Directory cmdlets being installed.
#
# Sample Usage:
#    1 - Create an AD user as an administrator in the MIM Portal, where their username is smithp-admin, they exist in the domain CONTOSO and make the update using the MIM Service address mimservice.contoso.local
#         CreatePortalAdmin.ps1 -Username smithp-admin -Domain contoso -ServiceHost mimservice.contoso.local
#
# Author: Andrew Silcock
# Date Created: 5-May-2020
# Version: 1.0
#
#####

param (
    [Parameter(Mandatory=$true)]
    [string] $Username,
    [Parameter(Mandatory=$true)]
    [string] $Domain,
    [Parameter(Mandatory=$true)]
    [string] $ServiceHost
)

Import-Module LithnetRMA
Set-ResourceManagementClient -BaseAddress $ServiceHost

$ADUser = Get-ADUser $Username -Properties DisplayName

$objUser = New-Object System.Security.Principal.NTAccount($domain,$username) 
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier]) 
 
$bytes = New-Object byte[] $strSID.BinaryLength
$strSID.GetBinaryForm($bytes, 0)

# Create the resource
$UserToCreate = New-Resource -ObjectType Person
$UserToCreate.AccountName = $username
$UserToCreate.Domain = $domain
$UserToCreate.DisplayName = $ADUser.DisplayName
$UserToCreate.ObjectSID = $bytes
Save-Resource $UserToCreate

# Add to administrators set
$AdminSet = Get-Resource Set DisplayName 'Administrators'
$AdminSet.ExplicitMember.Add($UserToCreate)
Save-Resource $AdminSet