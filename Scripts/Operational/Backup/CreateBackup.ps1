#####
#
# Script that will take a backup of files in the specified folder, copies them to the specified folder and can optionally create a ZIP archive of the backed up files
#
#  By default the script will create the backup archive named in the format backup_yyyyMMdd_HHmmss.zip (e.g. backup_20180518_230000.zip)
#
# Additional parameters can be provided to alter the behaviour such as
#   - Include   - string array of string filters to include particular files (e.g. *.ps1)
#   - Exclude   - string array of string filters to exclude particular files (e.g. *.xlsx)
#   - NoZip     - switch so the script will not create a ZIP archive
#   - NoDelete  - switch so that the temporary backup directory won't be deleted
#   - NoRecurse - don't recursively backup subdirectories (can be used if only files in the root directory should be backed up)
#
# Sample Usage:
#     Take a backup of all files in C:\Scripts (and all subdirectories) to a zip archive in C:\Backups\Scripts
#     - CreateBackup.ps1 -FolderToBackup "C:\Scripts" -BackupTo "C:\Backup\Scripts"
#
#     Take a backup of all ps1 files in C:\Scripts (and all subdirectories) to a zip archive in C:\Backups\Scripts
#     - CreateBackup.ps1 -FolderToBackup "C:\Scripts" -BackupTo "C:\Backup\Scripts" -Include @("*.ps1")
#
#     Take a backup of all files (except .log files) in C:\Scripts (and all subdirectories) to a zip archive in C:\Backups\Scripts
#     - CreateBackup.ps1 -FolderToBackup "C:\Scripts" -BackupTo "C:\Backup\Scripts" -Exclude @("*.log")
#    
#     Take a backup of all files in C:\Scripts (excluding subdirectories) to a zip archive in C:\Backups\Scripts
#     - CreateBackup.ps1 -FolderToBackup "C:\Scripts" -BackupTo "C:\Backup\Scripts" -NoRecurse
#
#     Take a backup of all files in C:\Scripts (and all subdirectories) to a zip archive in C:\Backups\Scripts, but dont delete the temporary backup folder
#     - CreateBackup.ps1 -FolderToBackup "C:\Scripts" -BackupTo "C:\Backup\Scripts" -NoDelete
#
#     Take a backup of all files in C:\Scripts (and all subdirectories) to a temp folder in C:\Backups\Scripts, don't delete the temp folder and don't create the zip file
#     - CreateBackup.ps1 -FolderToBackup "C:\Scripts" -BackupTo "C:\Backup\Scripts" -NoDelete -NoZip
#
# Author: Andrew Silcock
# Date Created: 18-May-2018
# Version: 0.1
#
#####

param
(
    [parameter(Mandatory=$true)]
    [string] $FolderToBackup,
    [parameter(Mandatory=$true)]
    [string] $BackupTo,
    [parameter(Mandatory=$false)]
    [string[]] $Include,
    [parameter(Mandatory=$false)]
    [string[]] $Exclude,
    [switch] $NoZip,
    [switch] $NoDelete,
    [switch] $NoRecurse
)

#Creates the specified directory if it doesnt exist already
function Create-DirectoryIfNotExists
{
    param
    (
          [parameter(Mandatory=$true)]
          [string]$DirectoryPath
    )

    if (-not(Test-Path -Path $DirectoryPath))
    {
        New-Item -ItemType Directory -Path $DirectoryPath
    }

}

###  BEGIN
#
if (-not $NoZip)
{
    #Add the Assembly required for creating ZIP files
    try
    {
        Add-Type -AssemblyName "System.IO.Compression.FileSystem"
    }
    catch 
    {
        Write-Error "An exception has occurred loading the Compression library, attempt runnign the script using the -NoZip switch"
        exit
    }
}

# Determine the name for the target folder we are backing up to
$DateString = (Get-Date -format "yyyyMMdd_HHmmss")
$TempBackupFolder = ("{0}\{1}" -f $BackupTo, $DateString)

# Determine the name of the zip file
$ZipFile = ("{0}\backup_{1}.zip" -f $BackupTo,  $DateString)
#
###

###  PROCESS
#

Create-DirectoryIfNotExists -DirectoryPath $TempBackupFolder

# Copy files scripts into the temp target folder from the folder to backup
if ($NoRecurse)
{
    $ItemList = Get-ChildItem -Path $FolderToBackup -Include $Include  -Exclude $Exclude
}
else
{
    $ItemList = Get-ChildItem -Path $FolderToBackup -Include $Include  -Exclude $Exclude -Recurse 
}

foreach ($file in $ItemList)
{
    $TargetFolder = "{0}\{1}" -f $TempBackupFolder, $file.Directory.ToString().Replace($FolderToBackup, "")
    $TargetFolder.Replace("\\","\")
    Create-DirectoryIfNotExists -DirectoryPath $TargetFolder

    Copy-Item $file.FullName -Destination $TargetFolder
}

Write-Output ("`nBackup taken to the temporary folder '{0}' " -f $TempBackupFolder)

# Create a zip file of the target backup folder if required
if (-not $NoZip)
{
    [io.compression.zipfile]::CreateFromDirectory($TempBackupFolder, $ZipFile)
    Write-Output ("`nBackup ZIP file '{0}' has been created" -f $ZipFile)
}
else
{
    Write-Warning ("No backup ZIP file has been created" -f $ZipFile)
}

# Delete the folder now that the zip file has been created if required
if (-not $NoDelete)
{
    Write-Output ("`nDeleting the temporary folder '{0}' " -f $TempBackupFolder)
    Remove-Item $TempBackupFolder -Recurse -Confirm:$false
}
else
{
    Write-Output ("`nThe temporary backup folder {0} has note been deleted" -f $TempBackupFolder)
}

#
###