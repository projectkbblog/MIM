#####
#
# Function Library to assist with the installation of Windows Features required for MIM 2016 components. 
# Currently only tested on Windows Server 2016
#
# 
# Author: Andrew Silcock
# Date Created: 16-Apr-2018
# Version: 0.1
#
#####

#####
#
# Install-WindowsFeature is a generic helper function to install windows features.
#
#  Parameters:
#     - Features   - (mandatory) - String array of the features that should be installed.
#     - SourcePath - (optional)  - the source path to install the feature (if required) 
#  
#  Sample Usage:
#      # Install the RSAT-AD-Tools feature 
#    - Install-WindowsFeatures -Features "RSAT-AD-Tools"
#
#      # Install the RSAT-AD-Tools and RSAT-AD-PowerShell feature 
#    - Install-WindowsFeatures -Features "RSAT-AD-Tools","RSAT-AD-PowerShell"
#
#      # Install the Net-Framework-Features and Net-Framework-Core features from the alternate source path D:\sources\sxs
#    - Install-WindowsFeatures -Features "Net-Framework-Features","Net-Framework-Core"
#
#
#####
function Install-WindowsFeatures
{
    param
    (
        [Parameter(Mandatory=$false)]
        [string]$SourcePath,
        [Parameter(Mandatory=$false)]
        [string[]]$Features
    )

    if ($SourcePath)
    {
        Install-WindowsFeature -Name $Features -Source $SourcePath
    }
    else
    {
        Install-WindowsFeature -Name $Features
    }

}

#####
#
#  Installs .NET 3.5 Framework as required for MIM 2016 Sync Service
#
#  Parameters:
#     - SourcePath - (mandatory)  - the source path to install .NET 3.5 (mandatory as must be installed from the installation media).
#
#  Sample Usage:
#    - Install-WindowsFeatures -SourcePath "D:\sources\sxs"
#
#####
function Install-NetFramework35
{
    param
    (
        [Parameter(Mandatory=$true)]
        $SourcePath
    )
    # Features to install for .NET 3.5
    $Features = @("Net-Framework-Features","Net-Framework-Core")

    Install-WindowsFeatures -Features $Features -SourcePath $SourcePath
}

#####
#
#  Installs the Active Directory administration tools (including PowerShell module)
#
#  Parameters: none
#
#  Sample Usage:
#    - Install-ActiveDirectoryManagement
#
#####
function Install-ActiveDirectoryManagement
{
    param
    (
        [switch] $PowerShellOnly  # Only install the PowerShell module

    )
    # Features to install for .NET 3.5
    $Features = @("RSAT-AD-Tools","RSAT-AD-PowerShell","RSAT-ADDS")
    if ($PowerShellOnly)
    {
        $Features = "RSAT-AD-PowerShell"
    }

    Install-WindowsFeatures -Features $Features
}

#####
#
#  Installs the Windows Identity Foundation role, this is required for SharePoint Foundation.
#
#  Parameters: none
#
#  Sample Usage:
#    - Install-WindowsIdentityFoundation
#
#####
function Install-WindowsIdentityFoundation
{
    # Features to install for .NET 3.5
    $Features = "Windows-Identity-Foundation"

    Install-WindowsFeatures -Features $Features
}

#####
#
#  Installs the IIS roles required for the installaion of MIM Password Reset
#
#  Parameters: none
#
#  Sample Usage:
#      # Install IIS for the Password Reset Portals
#    - Install-IIS -PasswordReset
#
#      # Install IIS for the MIM Portal
#    - Install-IIS -MIMPortal
#
#
#####
function Install-IIS
{
    param
    (
       [switch] $PasswordReset,
       [switch] $MIMPortal
    )

    # Common features for MIM Portal and Password Reset
    $Features = @("Web-Server","Web-Mgmt-Console","Web-Mgmt-Compat","Web-Metabase","Web-Lgcy-Mgmt-Console","Web-Lgcy-Scripting","Web-WMI")

    if ($PasswordReset)
    {
        # Additional features for Password Reset
        $PasswordResetFeatures = @("Web-Common-Http","Web-Default-Doc","Web-Dir-Browsing","Web-Static-Content","Web-Http-Errors","Web-Http-Redirect",
         "Web-App-Dev","Web-Net-Ext","Web-Asp-Net","Web-ISAPI-Ext","Web-ISAPI-Filter","Web-Health","Web-Http-Logging","Web-Request-Monitor",
         "Web-Security","Web-Basic-Auth","Web-Windows-Auth","Web-Filtering","Web-Performance","Web-Stat-Compression","Web-Dyn-Compression",
         "Web-Mgmt-Tools")

        $Features += $PasswordResetFeatures
    }

    Install-WindowsFeatures -Features $Features
}