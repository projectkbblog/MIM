#####
#
#  Script that can be run on servers where FIM 2010/MIM 2016 components are installed and used to update the database locations in the system registry.  
#  You will need administrative permissions on the server to be able to read and update entries from the Windows registry
#
#  Recommendations: 
#   - It is recommended that the FIM Services should be stopped whilst the registry change is made
#   - The FIM Service MA connectivity information will also need to be updated once the FIMService database has been moved.
#   
#  Sample usage:
#     - Set-DBLocation.ps1
#
# Author: Andrew Silcock
# Date Created: 12-Apr-2019
# Date Modified: 12-Apr-2019
# Version: 1.0
#
# Changes
#   Version 1.0 - 12-Apr-2019 - Initial Version
#
#####
param
(
    [switch] $SyncService,
    [switch] $Service,
    [Parameter(Mandatory=$true)]
    [string] $Server,
    [Parameter(Mandatory=$false)]
    [string] $Instance,
    [Parameter(Mandatory=$false)]
    [string] $DatabaseName
)

function Display-Warning
{
    param
    (
        [Parameter(Mandatory=$true)]
        [string] $Message,
        [switch] $ExitScript
    )

    Write-Warning $Message
    ""
    if ($ExitScript) 
    { 
        exit 0
    }
}

function Does-ValueNeedUpdating
{
    param
    (
        [Parameter(Mandatory=$false)]
        [string] $CurrentValue,
        [Parameter(Mandatory=$false)]
        [string] $ProposedValue
    )

    if ($CurrentValue -eq $ProposedValue)
    {
        return $true
    }
    else
    {
        return $false
    }

}

if ($SyncService -and $Service)
{
    Display-Warning -ExitScript -Message "You cannot use both the -SyncService and -FIMService parameters at the same time"
}
elseif ($SyncService)
{
    # Registry key locations for the Sync Service
    $SyncServiceConfig = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\FIMSynchronizationService\Parameters -ErrorAction SilentlyContinue
    if (-not $SyncServiceConfig)
    {
        Display-Warning -ExitScript -Message "The FIM Synchronization Service does not appear to be installed on this server"
    }

    "Current Configuration"
    "------------------"
    "`tSync Service"
    "`tServer:        {0}" -f $SyncServiceConfig.Server 
    "`tSQL Instance:  {0}" -f $SyncServiceConfig.SQLInstance
    "`tDatabase name: {0}" -f $SyncServiceConfig.DBName

    "Proposed changes"
    "------------------"
    "`tSync Service"
    if ($Server -and (Does-ValueNeedUpdating -ProposedValue $Server -CurrentValue $SyncServiceConfig.Server)) 
    {
        "`tServer:        {0}" -f $Server 
    }
    if ($SQLInstance -and (Does-ValueNeedUpdating -ProposedValue $Instance -CurrentValue $SyncServiceConfig.SQLInstance))
    {
        "`tSQL Instance:  {0}" -f $SQLInstance 
    }
    if ($DatabaseName -and (Does-ValueNeedUpdating -ProposedValue $DatabaseName -CurrentValue $SyncServiceConfig.DBName))
    {
        "`tDatabase name: {0}" -f $DatabaseName 
    }

    if (($Server -and $Server -eq $SyncServiceConfig.Server) -and ($Instance -and $Instance -eq $SyncServiceConfig.SQLInstance) -and ($DatabaseName -and $DatabaseName -eq $SyncServiceConfig.DBName))
    {
        Display-Warning -ExitScript -Message "The updated configuration is the same as the existing configuration, no changes will be made"
    }

    ""
    "The database configuration will be updated to the proposed configuration above"
    $Continue = Read-Host -Prompt "Type Y and press enter to perform the update"

    if ($Continue -eq "Y")
    {
        if (Does-ValueNeedUpdating -ProposedValue $Server -CurrentValue $SyncServiceConfig.Server)
        {
            "Updating the Server name to {0}" -f $Server
        }        
        if (Does-ValueNeedUpdating -ProposedValue $Instance -CurrentValue $SyncServiceConfig.SQLInstance)
        {
            "Updating the SQL Instance to {0}" -f $Instance
        }        
        if (Does-ValueNeedUpdating -ProposedValue $DatabaseName -CurrentValue $SyncServiceConfig.DBName)
        {
            "Updating the Database name to {0}" -f $DatabaseName
        }        

        "Updated"
    }
    else
    {
        ""
        Display-Warning -ExitScript -Message  "Script cancelled - no settings have been updated"
       
    }

}
elseif ($Service)
{
    # Registry key locations for the FIM Service
    $ServiceConfig = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\FIMService -ErrorAction SilentlyContinue
    if (-not $ServiceConfig)
    {
        Display-Warning -ExitScript -Message "The FIM Service does not appear to be installed on this server"
    }

    "Current Configuration"
    ""
    "`nFIM Service"
    "------------------"
    "Server & Instance: {0}" -f $ServiceConfig.DatabaseServer
    "Database name:     {0}" -f $ServiceConfig.DatabaseName
    ""
}