#####
#
# Script that will query AD and return the date and time the user's password is due to expire.
# 
# Sample Usage:
#     - Get-AccountPasswordExpiration.ps1 -AccountName bsmith
#
# Author: Andrew Silcock
# Date Created: 15-May-2018
# Version: 0.1
#
#####
param
(
    [parameter(Mandatory=$true)]
    [string] $AccountName
)


$User = Get-ADUser $AccountName -Properties 'msDS-UserPasswordExpiryTimeComputed'
[datetime]::FromFileTime($User."msDS-UserPasswordExpiryTimeComputed")