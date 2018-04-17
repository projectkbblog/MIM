#####
#
# Script to create the SharePoint site used for the MIM Portal.  The script configuration should be updated with the appropriate settings before running.
# 
# Note: 
#   - The script assumes that the managed service account already exists in Sharepoint.
#   - The script should be run within the SharePoint 2013 Management Shell
# 
# Author: Andrew Silcock
# Date Created: 17-Apr-2018
# Version: 0.1
#
#####

####
#
# Script config

# The application pool acocunt that will run the MIM Portal
$AppPoolAccount = "MIMDEV\svc_mim_sp"

# The MIM Portal URL
$MimPortalUrl = "http://mimportal.mimdev.local"

# The non-SSL port that will be utilised by the MIM installer (by default 82).
$MimPortalPort = 82

# The full MIM Portal URL used by the installer
$MIMPortalUrlFull = ("{0}:{1}" -f $MimPortalUrl, $MimPortalPort)

# The MIM Portal Site Owner
$SiteOwner = "MIMDEV\svc_mim_install"

# The backup MIM Portal Site Owner
$BackupOwner = "MIMDEV\admin"
#
####

$dbManagedAccount = Get-SPManagedAccount -Identity $AppPoolAccount
New-SpWebApplication -Name "MIM Portal" -ApplicationPool "MIMAppPool" -ApplicationPoolAccount $dbManagedAccount -AuthenticationMethod "Kerberos" -Port $MimPortalPort -URL $MimPortalUrl

$t = Get-SPWebTemplate -compatibilityLevel 14 -Identity "STS#1"
$w = Get-SPWebApplication $MIMPortalUrlFull
New-SPSite -Url $w.Url -Template $t -OwnerAlias $SiteOwner -CompatibilityLevel 14 -Name "MIM Portal" -SecondaryOwnerAlias $BackupOwner
$s = SpSite($w.Url)
$s.AllowSelfServiceUpgrade = $false
$s.CompatibilityLevel

$contentService = [Microsoft.SharePoint.Administration.SPWebService]::ContentService;
$contentService.ViewStateOnServer = $false;
$contentService.Update();
Get-SPTimerJob hourly-all-sptimerservice-health-analysis-job | disable-SPTimerJob