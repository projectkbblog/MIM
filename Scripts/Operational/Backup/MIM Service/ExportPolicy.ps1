#####
#
# Script that will export the FIM Portal Policy configuration and export it to the nominated XML file
#
# NOTE: the script must be run as a user with adminstrative priviliges within the FIM Portal
#
# Sample Usage:
#     Perform an export of the policy from the currently logged on server
#     - ExportPolicy.ps1 -ExportFile C:\MIM\Backups\PortalPolicy.xml
#
#     Perform an export of the policy from another server
#     - ExportPolicy.ps1 -ExportFile C:\MIM\Backups\PortalPolicy.xml -ServiceHost mimservice.domain.local
#    
# Author: Andrew Silcock
# Date Created: 15-Jun-2018
# Version: 1.0
#
#####
param 
(
   [Parameter(Mandatory=$true)]
   [string]$ExportFile,
   [string]$ServiceHost = "localhost"
)

# Exports the schema from the specified environment - writing the export to the specified file name
function PolicyExport
{
    param 
    (
       [Parameter(Mandatory=$true)]
       [string]$HostName,
       [Parameter(Mandatory=$true)]
       [string]$OutputFile
    )

    "Exporting configuration objects "
    "`tFIM Server - {0}" -f $HostName
    "`tOutput File - {0}" -f $OutputFile
    
    # Please note that SynchronizationFilter Resources inform the FIM MA.
    $policy = Export-FIMConfig -uri $HostName -policyConfig -portalConfig -MessageSize 9999999
    if ($policy -eq $null)
    {
        Write-Error "ERROR Export did not successfully retrieve configuration from FIM."
    }
    else
    {
        $policy | ConvertFrom-FIMResource -file $OutputFile
        if($policy.Count -gt 0)
        {
            "`n`nExport Complete - {0} objects exported" -f $policy.Count
        }
        else
        {
            "`n`nExport Complete - NO objects found" 
        }
    }
}

if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
    
# generate the full URL for the FIM Service
$FullHostName = ("http://{0}:5725" -f $ServiceHost)
#[String]$FullFilePath = Get-Location
#$FullFilePath = "{0}\{1}" -f $FullFilePath, $ExportFile
    
#Write-Host $FullFilePath
    
# call the export
PolicyExport -HostName $FullHostName -OutputFile $ExportFile