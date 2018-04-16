#####
#
# Script to install the required Windows Feature pre-requisites for a server where the MIM Synchronization Service will be installed
# 
# Author: Andrew Silcock
# Date Created: 16-Apr-2018
# Version: 0.1
#
#####

. .\Functions.ps1

# Install .NET 3.5 Framework using a custom source location
Install-NetFramework35 -SourcePath "D:\sources\sxs"

# Install the Remote Active Directory Management Tools (including PowerShell)
Install-ActiveDirectoryManagement