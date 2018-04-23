#####
#
# can be taken from a server with Azure AD Connect installed.
# 
# Note: This script requires CSExportAnalyzer.exe, which can be found on servers with Azure AD Connect installed, and should be placed
#       in the same directory as this script
#
# Sample Usage:
#     Generate Pending exports for a single management agent
#     - GeneratePE-Report.ps1 -ManagementAgent "ADMA"
#
#     Generate Pending exports for a multiple management agents
#     - GeneratePE-Report.ps1 -ManagementAgent @("ADMA","MIM Service")
#    
#     or 
#     $ManagementAgents = "ADMA","MIM Service"
#     GeneratePE-Report.ps1 -ManagementAgent $ManagementAgents
#
# Author: Andrew Silcock
# Date Created: 23-Apr-2018
# Version: 0.1
#
#####

param
(
    [Parameter(Mandatory=$true)]
    [string[]]$ManagementAgent
)

# Get the install path from the registry; if there are errors use the default installation path
try
{
	$MimPath = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\FIMSynchronizationService\Parameters" -Name "Path").Path
}
catch 
{
    $MimPath = "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\"
}
# Executable paths
$CSExport = ("{0}Bin\csexport.exe" -f $MimPath)
$CSExportAnalyzer = "{0}\CSExportAnalyzer.exe" -f (Get-Location)

foreach ($ma in $ManagementAgent)
{
    # Generate Export file names
    $DateString = Get-Date -Format "yyyyMMdd_hhmmss"
    $XmlExportFile = "{0}\{1}_{2}.xml" -f (Get-Location), $DateString, $ma
    $CsvReportFile = "{0}\{1}_{2}_Changes.csv" -f (Get-Location), $DateString, $ma

    # Get the pending exports from the Synchronization Service
    "Management Agent {0}" -f $ma
    "Generating raw pending changes file for MA:'{0}' " -f $ma
    & $CSExport $ma $XmlExportFile /f:x

    "`t"
    "`tGenerated pending export file '{0}'" -f $XmlExportFile
    "`t"

    # Generate the CSV view of the data
    "`tGenerating pending export report file " -f $CsvReportFile
    & $CSExportAnalyzer $XmlExportFile unapplied-export > $CsvReportFile
    "`t"
    "`tGenerated pending export report file '{0}" -f $CsvReportFile
}