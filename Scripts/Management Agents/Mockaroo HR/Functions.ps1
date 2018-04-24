$TimeStampFormat =  "yyyy-MM-dd HH:mm:ss"

####
# 
# the function calls the Mockaroo web services to retrieve additional randomised data, which is returned as an array of PowerShell objects
# 
#  Parameters:
#    - MockarooURL - the complete URL to retrieve data from (including the access key) e.g. https://my.api.mockaroo.com/users.json?key=abc123
#
#  Return: an array of PowerShell objects
#
#  Sample usage:
#    Get-MoreMockarooUsers -MockarooURL "https://my.api.mockaroo.com/users.json?key=abc123"
#
####
function Get-MoreMockarooUsers
{
    param
    (
        [parameter(Mandatory=$true)]
        [string] $MockarooURL
    )
    
    $MockarooData = (Invoke-WebRequest -Uri $MockarooURL -UseBasicParsing).Content
    $UserData = @()
    $UserData = ConvertFrom-Json -InputObject $MockarooData

    return $UserData
}

####
# 
# the function converts a PowerShell object to a Hashtable object
# 
#  Parameters:
#    - ObjToConvert - the powershell object to convert to a hashtable object
#
#  Return: a Hashtable object
#
####
function Convert-PSObjectToHashTable
{
   param
    (
        [parameter(Mandatory=$true)]
        $ObjToConvert
    )

    $obj = @{}
    $ObjToConvert.psobject.properties | foreach { $obj[$_.Name] = $_.Value }
    return $obj
}

####
# 
# the function takes a PowerShell object and writes it out to a .json file
# 
#  Parameters:
#    - DataDirectory - the directory where the file should be saved
#    - UserObject    - the object to write to file, the EmployeeID value of the object is used as the file name
#
#  Return: N/A
#
####
function Write-UserObjectToFile
{
   param
    (
        [parameter(Mandatory=$true)]
        [string]$DataDirectory,
        [parameter(Mandatory=$true)]
        $UserObject
    )
    $OutputFile = "{0}\{1}.json" -f $DataDirectory, $UserObject.EmployeeID
    ConvertTo-Json -InputObject $UserObject | Out-File $OutputFile
}

####
# 
# the function reads all JSON files from the specified directory and returns them in an array of PowerShell objects
# 
#  Parameters:
#    - DataDirectory - the directory where the json files should be read from (e.g. C:\Scripts\MIM\MA\Mockaroo\Data)
#
#  Return: an array of PowerShell objects
#
#  Sample usage:
#    Get-AllMockarooUsersFromFile -DataDirectory "C:\Scripts\MIM\MA\Mockaroo\Data"
#
####
function Get-AllMockarooUsersFromFile
{
    param
    (
        [parameter(Mandatory=$true)]
        [string]$DataDirectory
    )
    
    $JsonFiles = Get-ChildItem -Path $DataDirectory -Filter "*.json"
    $Users = @()

    foreach ($JsonFile in $JsonFiles)
    {
        $UserObject = ConvertFrom-Json -InputObject (Get-Content $JsonFile.FullName -Raw)
        $Users +=  $UserObject
    }

    return $Users
}

####
# 
# the function reads all JSON files from the specified directory that have changed since the last import
# 
#  Parameters:
#    - DataDirectory - the directory where the json files should be read from (e.g. C:\Scripts\MIM\MA\Mockaroo\Data)
#
#  Return: an array of PowerShell objects
#
#  Sample usage:
#    Get-RecentlyUpdatedMockarooUsersFromFile -DataDirectory "C:\Scripts\MIM\MA\Mockaroo\Data"
#
####
function Get-RecentlyUpdatedMockarooUsersFromFile
{
    param
    (
        [parameter(Mandatory=$true)]
        [string]$DataDirectory
    )
    
    $JsonFiles = Get-ChildItem -Path $DataDirectory -Filter "*.json" | where { $_.LastWriteTime -gt (Get-LastRunTime) }
    $Users = @()

    foreach ($JsonFile in $JsonFiles)
    {
        $UserObject = ConvertFrom-Json -InputObject (Get-Content $JsonFile.FullName -Raw)
        $Users +=  $UserObject
    }

    return $Users
}

####
# 
# sets the last run timestamp in the LastRun.json file in the MA directory
# 
#  Parameters:
#    - DataDirectory - the directory where the LastRun.json file should be run from (e.g. C:\Scripts\MIM\MA\Mockaroo)
#
#
#  Sample usage:
#    Set-UpdateTimeStamp -DataDirectory "C:\Scripts\MIM\MA\Mockaroo"
#
####
function Set-UpdateTimeStamp
{
    param
    (
        [parameter(Mandatory=$false)]
        [string]$DataDirectory="C:\Scripts\MIM\MA\Mockaroo"
    )

    $UpdateFile = ("{0}\LastRun.json" -f $DataDirectory)

    $DateString = (Get-Date -format $TimeStampFormat)

    $obj = @{}
    $obj['LastRunTimestamp'] = $DateString

     ConvertTo-Json -InputObject $obj | Out-File $UpdateFile
}

####
# 
# the function reads the last run timestamp from the LastRun.json file in the MA directory
# 
#  Parameters:
#    - DataDirectory - the directory where the LastRun.json file should be run from (e.g. C:\Scripts\MIM\MA\Mockaroo)
#
#  Return: DateTime object representing the date and time the MA was last run for an import
#
#  Sample usage:
#    Get-RecentlyUpdatedMockarooUsersFromFile -DataDirectory "C:\Scripts\MIM\MA\Mockaroo"
#
####
function Get-LastRunTime
{
    param
    (
        [parameter(Mandatory=$false)]
        [string]$DataDirectory="C:\Scripts\MIM\MA\Mockaroo"
    )

    $UpdateFile = ("{0}\LastRun.json" -f $DataDirectory)

    $JsonObject = ConvertFrom-Json -InputObject (Get-Content $UpdateFile -Raw)

    return [datetime]::ParseExact($JsonObject.LastRunTimestamp, $TimeStampFormat, $null)
    
}