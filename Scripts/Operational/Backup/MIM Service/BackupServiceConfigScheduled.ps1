param
(
    [Parameter(Mandatory=$true)]
    [string]$DestinationFolder,
    [switch]$CreateArchive,
    [switch]$DeleteFiles
)

#$DestinationFolder = "E:\Backup\ServicePortal\"
$DailyDirectory = ("{0}\{1}" -f $DestinationFolder, (Get-Date -format "yyyyMMdd"))
$PolicyExportFile = ("{0}\policy.xml" -f $DailyDirectory)
$SchemaExportFile = ("{0}\schema.xml" -f $DailyDirectory)

New-Item -ItemType Directory -Path $DailyDirectory -ErrorAction SilentlyContinue

.\ExportPolicy.ps1 -ExportFile $PolicyExportFile
.\ExportSchema.ps1 -ExportFile $SchemaExportFile

if ($CreateArchive)
{
    "Creating ZIP Archive of all exported files"
    Add-Type -AssemblyName "System.IO.Compression.FileSystem"
    
    $ZipFile = ("{0}{1}_service_backup.zip" -f $DestinationFolder, (Get-Date -format "yyyyMMdd"))
    [io.compression.zipfile]::CreateFromDirectory($DailyDirectory, $ZipFile)

    if ($DeleteFiles)
    {
        Remove-Item -Path $DailyDirectory -Recurse -Confirm:$false

    }
}