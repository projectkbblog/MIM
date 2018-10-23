#####
#
# Script that will perform the following backups for the Synchronization Service
#   - Perform a server export of the Metaverse
#   - Perform an export of each management agent
#   - take a backup of .exe.config files from the BIN directory of the sync service
#   - take a backup of all files in the Extensions directory
#   - optionall create a ZIP archive of the exported directories (using the -CreateArchive switch) and delete the exported files (using the -DeleteFiles switch)
#
#  The backups will be exported to a directory, that should be empty (due to limitations on the way that exports of MIM configuration works)
#
# Sample Usage:
#     Perform a backup of the synchronization service to the specified location
#     - Backup-SyncServiceFiles.ps1 -DestinationFolder "C:\MIM\Backups\20180518"
#
#     Perform a backup of the synchronization service to the specified location
#      and creation of a zip archive named the same as the directory (e.g. C:\MIM\Backups\20180518.zip)
#     - Backup-SyncServiceFiles.ps1 -DestinationFolder "C:\MIM\Backups\20180518" -CreateArchive
#
#     Perform a backup of the synchronization service to the specified location
#      , creation of a zip archive named the same as the directory (e.g. C:\MIM\Backups\20180518.zip)
#      and deletion of the files in the DestinationFolder after the zip file is created
#     - Backup-SyncServiceFiles.ps1 -DestinationFolder "C:\MIM\Backups\20180518" -CreateArchive -DeleteFiles
#    
# Author: Andrew Silcock
# Date Created: 18-May-2018
# Date Modified: 21-Jun-2018
# Version: 1.1
#
# Changes
#   Version 1.0 - 18-May-2018 - Initial Release
#   Version 1.1 - 21-Jun-2018 - Add -DeleteFiles switch to allow the uncompressed files to be deleted after the ZIP file is created.
#
#####
param
(
    [Parameter(Mandatory=$true)]
    [string]$DestinationFolder,
    [switch]$CreateArchive,
    [switch]$DeleteFiles
)

# Export the server configuration
function Export-ServerConfig
{
    & $ServerExportExe $ServerExportFolder
}

# Get the names of management agents from the server export
function Get-ManagementAgentNames
{
    $MANames = @()
    
    $MAFiles = Get-ChildItem -Path $ServerExportFolder -Filter "MA*.xml"

    foreach ($MaXml in $MAFiles)
    {
        [xml]$XmlDoc = Get-Content $MaXml.FullName -Raw

        $MANames += $XmlDoc.'saved-ma-configuration'.'ma-data'.name
    }
    
    return $MANames
}

# export the management agent config
function Export-ManagementAgent
{
    param
    (
        [parameter(Mandatory=$true)]
        [string]$ManagementAgent,
        [parameter(Mandatory=$true)]
        [string]$OutputFolder           
    )
    $OutputFile = ("{0}\{1}.xml" -f $OutputFolder, $ManagementAgent)
    $OutputFile
    & $MAExportExe $ManagementAgent $OutputFile
}

# backup the extensions folder
function Backup-Extensions
{
    param
    (
        [parameter(Mandatory=$true)]
        [string]$OutputFolder 
    )

    $Files = Get-ChildItem -Path $ExtensionsDir

    foreach ($f in $Files)
    {
        Copy-Item $f.FullName -Destination $OutputFolder
    }
}

# backup config files in the bin folder
function Backup-ConfigFiles
{
    param
    (
        [parameter(Mandatory=$true)]
        [string]$OutputFolder 
    )

    $Files = Get-ChildItem -Path $BinDir -Filter "*.exe.config"

    foreach ($f in $Files)
    {
        Copy-Item $f.FullName -Destination $OutputFolder
    }
}

if (Test-Path -Path $DestinationFolder)
{
    Write-Warning ("The folder '{0}' already exists, please specify an alternate directory that does not yet exist" -f $DestinationFolder)
    Start-Sleep -seconds 10
    exit
}

# attempt to auto detect the Sync Service installation location, if not use the default installation path
try
{
	$MimPath = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\FIMSynchronizationService\Parameters" -Name "Path").Path
}
catch 
{
    $MimPath = "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\"
}

# Detemrine location of exe files
$BinDir = ("{0}bin" -f $MimPath)
$ServerExportExe = ("{0}\svrexport.exe" -f $BinDir)
$MAExportExe = ("{0}\maexport.exe" -f $BinDir)
$ExtensionsDir = ("{0}extensions" -f $MimPath)

# Detemrine location of export folders
$ServerExportFolder = ("{0}\SyncService\Server" -f $DestinationFolder)
$MAExportFolder = ("{0}\SyncService\Management Agents" -f $DestinationFolder)
$DLLExportFolder = ("{0}\SyncService\Extensions" -f $DestinationFolder)
$ConfigFiles = ("{0}\SyncService\Configuration Files" -f $DestinationFolder)

# Create the export directories
New-Item -ItemType Directory -Path $ServerExportFolder -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $MAExportFolder -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $DLLExportFolder -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $ConfigFiles -ErrorAction SilentlyContinue

"Exporting Server Configuration"
Export-ServerConfig
""
"Complete"
""
"Exporting Management Agents"
$MANames = Get-ManagementAgentNames
foreach ($ma in $MANames)
{
    "`t$ma"
    Export-ManagementAgent -ManagementAgent $ma -OutputFolder $MAExportFolder
}
""
"Completed exporting Management Agents"

"Backing up configuration files "
Backup-ConfigFiles -OutputFolder $ConfigFiles
""

"Backing up DLL extensions"
Backup-Extensions -OutputFolder $DLLExportFolder
""

if ($CreateArchive)
{
    "Creating ZIP Archive of all exported files"
    Add-Type -AssemblyName "System.IO.Compression.FileSystem"
    
    $ZipFile = ("{0}backup.zip" -f $DestinationFolder)
    $SourceFolder = "{0}\SyncService" -f $DestinationFolder
    [io.compression.zipfile]::CreateFromDirectory($SourceFolder, $ZipFile)
    "Zip file created - {0} " -f $ZipFile

    if ($DeleteFiles)
    {
        "`nDeleting the source files now the ZIP file has been created"
        Remove-Item -Path $DestinationFolder -Recurse -Confirm:$false -Force
        "Completed"

    }
}