#####
#
#  Script that can be run on servers where FIM 2010/MIM 2016 components are installed and determine what SQL Server database instance is being used by that server.  
#   The script will check for the location of both the MIM Synchronziation Service and MIM Service databases.
#   
#  Note: You will need administrative permissions on the server to be able to read entries from the Windows registry
#
#  Sample usage:
#     - Get-DBLocations.ps1
#
# Author: Andrew Silcock
# Date Created: 27-Feb-2019
# Date Modified: 27-Feb-2019
# Version: 1.0
#
# Changes
#   Version 1.0 - 27-Feb-2019 - Initial Version
#
#####
$ServiceConfig = get-itemproperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\FIMService -ErrorAction SilentlyContinue
$SyncServiceConfig = get-itemproperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\FIMSynchronizationService\Parameters -ErrorAction SilentlyContinue

if ($SyncServiceConfig)
{
    "MIM Synchronization Service Database location"
    "---------------------------------------------"
    "Server:   {0}" -f $SyncServiceConfig.Server
    "Instance: {0}" -f $SyncServiceConfig.SQLInstance
    "DB Name:  {0}" -f $SyncServiceConfig.DBName
}
else
{
    Write-Warning "The Synchronization Service does not appear to be installed on this server"
}
""
if ($ServiceConfig)
{
    "MIM Service Database location"
    "---------------------------------------------"
    "Server & Instance:   {0}" -f $ServiceConfig.DatabaseServer
    "DB Name:             {0}" -f $ServiceConfig.DatabaseName
}
else
{
    Write-Warning "The MIM Service does not appear to be installed on this server"
}