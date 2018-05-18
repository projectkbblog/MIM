#####
#
# Script that will perform the following backups for the Synchronization Service
#   - Perform a server export of the Metaverse
#   - Perform an export of each management agent
#   - take a backup of .exe.config files from the BIN directory of the sync service
#   - take a backup of all files in the Extensions directory
#
#  The backups will be exported to a directory, that should be empty (due to limitations on the way that exports of MIM configuration works)
#
# Sample Usage:
#     Perform a backup of the synchronization service to the specified location
#     - Backup-SyncServiceFiles.ps1 -DestinationFolder "C:\MIM\Backups\20180518"
#
#     Perform a backup of the synchronization service to the specified location including a zip archieve
#     - Backup-SyncServiceFiles.ps1 -DestinationFolder "C:\MIM\Backups\20180518" -CreateArchive
#    
# Author: Andrew Silcock
# Date Created: 18-May-2018
# Version: 0.1
#
#####
param
(
    [Parameter(Mandatory=$true)]
    [string]$DestinationFolder,
    [switch]$CreateArchive
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
$ServerExportFolder = ("{0}\Files\Server" -f $DestinationFolder)
$MAExportFolder = ("{0}\Files\Management Agents" -f $DestinationFolder)
$DLLExportFolder = ("{0}\Files\Extensions" -f $DestinationFolder)
$ConfigFiles = ("{0}\Files\Configuration Files" -f $DestinationFolder)

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
    $SourceFolder = "{0}Files" -f $DestinationFolder
    [io.compression.zipfile]::CreateFromDirectory($SourceFolder, $ZipFile)
}