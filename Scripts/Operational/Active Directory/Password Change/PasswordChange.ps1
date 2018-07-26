#####
#
# Script that allows you to change your AD password whilst logged onto an RDP session (often where you can't get to ALT-CTRL-DEL change password).
# 
# The username of the account is specified as a parameter, however the script will then prompt you to enter the current and new password.
#
# Sample Usage:
#     - PasswordChange.ps1 -AccountName bsmith
#
# Author: Andrew Silcock
# Date Created: 27-Jul-2018
# Version: 0.1
#
#####
param
(
    [Parameter(Mandatory=$true)]
    [string] $AccountName
)

Set-ADAccountPassword -Identity $AccountName -OldPassword (Read-Host "Enter your old password" -AsSecureString) -NewPassword (Read-Host "Enter your new password" -AsSecureString)