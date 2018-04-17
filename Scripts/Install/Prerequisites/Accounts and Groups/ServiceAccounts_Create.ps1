#####
#
# Script to create service accounts for MIM - see Groups.csv as a sample input file - Accounts.csv
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


$Accounts = Import-CSV $File


foreach ($a in $Accounts)
{
    #sAMAccountName UserPrincipalName FirstName LastName OU Password
    # Default values
    $DisplayName = ("{0} {1}" -f $a.FirstName, $a.LastName)
    $PasswordNeverExpires = $true
    $UserCannotChangePassword = $true
    $Enabled = $true

    New-ADUser -Name $a.sAMAccountName -DisplayName $DisplayName -GivenName $a.FirstName -Surname $a.LastName -AccountPassword (ConvertTo-SecureString $a.Password -AsPlainText -Force) -SamAccountName $a.sAMAccountName -UserPrincipalName $a.UserPrincipalName -CannotChangePassword $UserCannotChangePassword -PasswordNeverExpires $PasswordNeverExpires -Path $a.OU -Enabled $Enabled
    "Account '{0}' - created" -f $a.sAMAccountName
}