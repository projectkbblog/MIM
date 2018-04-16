#####
#
# Script to install the required Windows Feature pre-requisites for a server where the MIM Password Reset or Registration Portals will be installed
# 
# Author: Andrew Silcock
# Date Created: 16-Apr-2018
# Version: 0.1
#
#####

. .\Functions.ps1

# Install IIS for the MIM Password Reset Portals
Install-IIS -PasswordReset