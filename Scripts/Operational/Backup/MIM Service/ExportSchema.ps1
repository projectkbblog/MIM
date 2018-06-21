#####
#
# Script that will export the FIM Portal Schema configuration and export it to the nominated XML file
#
# NOTE: the script must be run as a user with adminstrative priviliges within the FIM Portal
#
# Sample Usage:
#     Perform an export of the policy from the currently logged on server
#     - ExportSchema.ps1 -ExportFile C:\MIM\Backups\PortalSchema.xml
#
#     Perform an export of the policy from another server
#     - ExportSchema.ps1 -ExportFile C:\MIM\Backups\PortalSchema.xml -ServiceHost mimservice.domain.local
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

# Exports the schema from the specified server - writing the export to the specified file name
function SchemaExport
{
    param 
    (
       [Parameter(Mandatory=$true)]
       [string]$HostName,
       [Parameter(Mandatory=$true)]
       [string]$OutputFile
    )

    Write-Host "Exporting configuration objects from $HostName to file $OutputFile "
    # Please note that SynchronizationFilter Resources inform the FIM MA.
    $schema = Export-FIMConfig -uri $HostName -schemaConfig -customConfig "/SynchronizationFilter"
    if ($schema -eq $null)
    {
        Write-Error "Export did not successfully retrieve configuration from FIM."
    }
    else
    {
        $schema | ConvertFrom-FIMResource -file $OutputFile
        if($schema.Count -gt 0)
        {
            "`n`nExport Complete - {0} objects exported" -f $schema.Count
        }
        else
        {
            "`n`nWhile export completed, there were no resources." 
        }
    }
}

if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
    
# generate the full URL for the FIM Service
$FullHostName = ("http://{0}:5725" -f $ServiceHost)
    
# call the export
SchemaExport -HostName $FullHostName -OutputFile $ExportFile