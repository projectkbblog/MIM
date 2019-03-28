#####
#
# Script to delete the contents of the FIM Synchronization Service ExtensionCache directory. The script performs the following tasks
# 1 - Stops the Synchronization Service
# 2 - Clears the cache directory
# 3 - Starts the Synchronization Service
#
# Note: This script should only be used during an outage, and depending on the number of files/folders in the extension cache directory may take a considerable amount of time (potentially hours) to complete.
#
# Author: Andrew Silcock
# Date Created: 28-Mar-2018
# Version: 1.1
#
#####################
# Change history
#####################
# 
# Version: 1.1 - 28-Mar-2018
# Changes: added confirmation prompt before taking any actions, and provide feedback to screen of what steps the script is performing
#
#####

"This script will stop the FIM Synchronization Service,  clear the contents of the ExtensionsCache Directory and start the Synchronization Service again - it may run for an extended period of time"
$ValueEntered = Read-Host -Prompt "If you want to continue type Y and press enter"
""

if ($ValueEntered -eq "Y" -or $ValueEntered -eq "y")
{
    "Continuing - Stopping the Synchronization Service"
    Stop-Service FIMSynchronizationService
    "Stopped`n"

    "Clearing the contents of the ExtensionsCache directory - this may take an extended period of time and provides no feedback on its progress`n"
    $Directory = "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\ExtensionsCache"
    # Delete all contents of the ExtensionsCache directory (but do not delete the root directory)
    Remove-Item -Path $Directory -Recurse -Exclude ExtensionsCache
    "Complete`n"

    "Starting the FIM Synchornization Service"
    Start-Service FIMSynchronizationService
    "Complete"
}
else
{
    Write-Warning "Script cancelled and no action taken"
}