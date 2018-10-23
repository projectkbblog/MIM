param
(
    [Parameter(Mandatory=$true)]
    [string]$DestinationFolder,
    [switch]$CreateArchive,
    [switch]$DeleteFiles
)
$DailyDirectory = ("{0}\{1}" -f $DestinationFolder, (Get-Date -format "yyyyMMdd"))

#$ExportDirectory = ("E:\Backup\SyncService\{0}" -f (Get-Date -format "yyyyMMdd"))

if (-not $CreateArchive)
{
    E:\Scripts\BackupSyncServiceFiles.ps1 -DestinationFolder $DailyDirectory 
}
elseif ($CreateArchive -and $DeleteFiles)
{
    E:\Scripts\BackupSyncServiceFiles.ps1 -DestinationFolder $DailyDirectory -CreateArchive -DeleteFiles
}
elseif ($CreateArchive -and (-not $DeleteFiles))
{
    E:\Scripts\BackupSyncServiceFiles.ps1 -DestinationFolder $DailyDirectory -CreateArchive
}

