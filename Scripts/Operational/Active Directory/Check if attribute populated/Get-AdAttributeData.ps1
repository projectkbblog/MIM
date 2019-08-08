#####
#
# Script that queries Active Directory to check if there are users in AD with the specified attribute value populated.  
#  For example the script can be used to determine if a particular extension attribute is currently in use
#
# Using the -DisplayData switch the data can be displayed to Screen, and -OutputFile will output the data to the specified file. 
# Optionally the script can check only specific OUs (using -SearchBase)
#
# See the usage instructions below for full details.
#
# Sample Usage:
#     1 - Check if there are any users where extensionAttribute1 is populated from the root of the domain
#         .\Get-AdAttributeData.ps1 -AttributeName "extensionAttribute1"
#
#     2 - Check if there are any users where extensionAttribute1 is populated from the root of the domain, and output data to a CSV file
#         .\Get-AdAttributeData.ps1 -AttributeName "extensionAttribute1" -OutputFile "C:\Temp\ExtensionAttribute1.csv"
#
#
#     3 - Check if there are any users where extensionAttribute1 is populated from the root of the domain, output data to a CSV file and the screen
#         .\Get-AdAttributeData.ps1 -AttributeName "extensionAttribute1" -OutputFile "C:\Temp\ExtensionAttribute1.csv" -DisplayData
#
#     4 - Check if there are any users in the OU "OU=Users,DC=mydomain,DC=com" where extensionAttribute1 is populated
#         .\Get-AdAttributeData.ps1 -AttributeName "extensionAttribute1" -SearchBase "OU=Users,DC=mydomain,DC=com"
#
#
# Author: Andrew Silcock
# Date Created: 8-Aug-2019
# Version: 1.0
#
#####
param(
    [Parameter(Mandatory=$true)]
    [string]$AttributeName,
    [Parameter(Mandatory=$false)]
    [string]$SearchBase,
    [switch]$DisplayData,
    [Parameter(Mandatory=$false)]
    [string]$OutputFile

)

if (-not $SearchBase)
{
    $DomainDetails = Get-ADDomain
    $SearchBase = $DomainDetails.DistinguishedName
}

$LDAPFilter = ("(&(objectClass=user)({0}=*))" -f $AttributeName) 
$Properties = @()
$Properties += $AttributeName

"Checking Active Directory to determine if users have a value populated for the attribute '{0}'" -f $AttributeName
""

$Users = Get-ADUser -LDAPFilter $LDAPFilter -SearchBase $SearchBase -SearchScope Subtree -Properties $Properties

if ($Users.count -gt 0)
{
    Write-Warning ("There were '{0}' users with a value for the attribute '{1}'  " -f $Users.count, $AttributeName)

    if ($DisplayData)
    {
        # Display the data in a table
        $Users | Format-Table -Property DistinguishedName, $AttributeName
    }        

    if ($OutputFile)
    {
        $Users | Export-Csv -Path $OutputFile -NoTypeInformation
        ""
        Write-Warning ("Data has been written to the file '{0}' " -f $OutputFile)
    }
}
else
{
    write-warning ("No users were found under the OU '{0}' with the attribute '{1}' populated" -f $SearchBase, $AttributeName)
}