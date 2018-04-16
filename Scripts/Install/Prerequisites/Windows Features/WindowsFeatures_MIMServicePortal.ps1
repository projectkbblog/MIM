#####
#
# Script to install the required Windows Feature pre-requisites for a server where the MIM Service & Portal will be installed.
# 
# Author: Andrew Silcock
# Date Created: 16-Apr-2018
# Version: 0.1
#
#####

. .\Functions.ps1

# Install Windows Identity Foundation
Install-WindowsIdentityFoundation

# Install IIS for the MIM Portal
Install-IIS -MIMPortal

# Install only the Powershell component of the Remote Active Directory Management tools
Install-ActiveDirectoryManagement -PowerShellOnly