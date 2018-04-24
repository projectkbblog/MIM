PARAM
(
  $Username,
  $Password,
  $Credentials,
  $OperationType,
  $UsePagedImport,
  $PageSize
)

BEGIN
{
    ##
    # Import the functions file 
    #
    $Invocation = (Get-Variable MyInvocation).Value
    $DirPath = Split-Path $Invocation.MyCommand.Path
    
    $DataDirectory = ("{0}\Data\" -f $DirPath)
    $FunctionsFile = ("{0}\Functions.ps1" -f $DirPath)
    . $FunctionsFile
    #
    ##
    
    $VerbosePreference = 'Continue'
    
    # Make sure that the Mockaroo connection details are available (they are stored in the username and password values passed to the script
    if ($Username -and $Password)
    {
        $MockarooURL = ("{0}?key={1}" -f $Username, $Password)
        $MockarooURL | Out-File C:\Scripts\MIM\MA\Mockaroo\Logging.txt -Append
    }
    else
    {
        $MockarooURL = ""
        Write-Error "The username and password have not been set with the API URL and Key"
        exit -1
    }
}

PROCESS
{
    switch ($OperationType)
    {
        "Full" 
        {   
            # Read all Mockaroo data files from the local file system
            $UserData = Get-AllMockarooUsersFromFile -DataDirectory $DataDirectory
        }
            
        "Delta" 
        {   
            # check if any of the JSON files have been updated recently - if so read them in as updates
            $UserData = RecentlyUpdatedMockarooUsersFromFile -DataDirectory $DataDirectory 
            
            # if there were no file changes, then get more users from the webservice
            if ($UserData.Count -eq 0)
            {
                $UserData =  Get-MoreMockarooUsers -MockarooURL $MockarooURL
            }
        }
    }

    # Process the user data
    foreach ($User in $UserData)
    {
        # if the import is a Delta also drop the user data to a file 
        # to allow all user data to be read in again on a full import
        if ($OperationType -eq "Delta")
        {
            Write-UserObjectToFile -DataDirectory $DataDirectory -UserObject $User
        }

        # Convert the PowerShell object to hashtable object to be provided to the MIM connector space
        $CsObject = Convert-PSObjectToHashTable -ObjToConvert $User
        $CsObject
    }

    # Update the last run timestamp in file
    Set-UpdateTimeStamp
}

END
{

}