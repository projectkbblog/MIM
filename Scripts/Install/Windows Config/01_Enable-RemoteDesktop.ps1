#### # This script will enable remote desktop for the local server# # Author: Andrew Silcock
# Date Created: 16-Apr-2018
# Version: 0.1
#
#####

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f