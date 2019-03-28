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
# Version: 1.0
#
#####

Stop-Service FIMSynchronizationService

$Directory = "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\ExtensionsCache"
# Delete all contents of the ExtensionsCache directory (but do not delete the root directory)
Remove-Item -Path $Directory -Recurse -Exclude ExtensionsCache

Start-Service FIMSynchronizationService