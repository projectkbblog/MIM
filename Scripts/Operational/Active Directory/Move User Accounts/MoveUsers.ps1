#####
#
# Script that will move users in Active Directory to a new OU based on data in the input file, the script will generate two output files:
#  1 - an actions file outlining what actions were taken, also logging scenarios where user accounts were not moved or errors encountered
#  2 - a rollback file - that logs all users moved and what their original OU was.  This can be used as a rollback to move users back to their original OU if needed.
#
# The script undertakes the following actions:
#   1 - locate the user in AD to get their current OU
#   2 - checks if the new OU is the same as the current OU - if they are the same no action is taken
#   3 - if the user needs to be moved, their account is moved and entries are added to the Actions and Rollback files.
#
# Sample Usage:
#     - MoveUsers.ps1 -InputFile C:\Scripts\UsersToMove.csv
#
#  The script expects a CSV file with the following headers "Username","NewOU".  The Username field should contain sAMAccountName and NewOU should contain the OU the user should be moved to in DN format (e.g. OU=Users,DC=domain,DC=local)
#
# Author: Andrew Silcock
# Date Created: 6-Jun-2018
# Version: 1.0
#
#####
param
(
    [parameter(Mandatory=$true)]
    [string] $InputFile
)

try
{
    $csv = Import-CSV $InputFile
}
catch 
{
    Write-Error $_
    exit -1
}

$counter = 1
"Moving AD users based on data in the input file {0}" -f $InputFile
$WorkingDirectory = Convert-Path .

# Generate the file names for the actions and rollback files
$ActionFile = "{0}\{1}_Actions.csv" -f $WorkingDirectory, (Get-Date -Format "yyyyMMddHHmmss")
$RollbackFile = "{0}\{1}_Rollback.csv" -f $WorkingDirectory, (Get-Date -Format "yyyyMMddHHmmss")

# write the header rows for the action and rollback files
"`"Username`",`"Original OU`",`"Target OU`",`"Move Status`"" | Out-File $ActionFile
"`"Username`",`"NewOU`"" | Out-File $RollbackFile

foreach ($u in $csv)
{
    
    try
    {
        # get the user so we can get their Current OU to put in the rollback file
        $User = Get-ADUser $u.username -ErrorAction SilentlyContinue
        $CurrentOU = $User.DistinguishedName.Substring($User.DistinguishedName.IndexOf(',')+1)
        
        try
        {
            # the user doesnt need to be moved as they are already in the new OU
            if ($CurrentOU.ToLower() -eq $u.NewOU.ToLower())
            {
                "`n{0} of {1} - the user '{2}' is already in the OU '{3}'" -f $counter, $csv.Length, $u.Username, $u.NewOU

                # Write to the action file
                "`"{0}`",`"{1}`",`"{2}`",`"no action`"" -f $u.Username, $CurrentOU, $u.NewOU | Out-File $ActionFile -Append
            }
            else
            {
                # the user needs to be moved.

                "`n{0} of {1} - Moving user '{2}'`n`tfrom:'{3}'`n`tto:  '{4}'" -f $counter, $csv.Length, $u.Username, $CurrentOU, $u.NewOU
                Move-ADObject -Identity $User -TargetPath $u.NewOU -Confirm:$false
        
                # Write to the action file
                "`"{0}`",`"{1}`",`"{2}`",`"success`"" -f $u.Username, $CurrentOU, $u.NewOU | Out-File $ActionFile -Append

                # Write to the rollback file
                "`"{0}`",`"{1}`"" -f $u.Username, $CurrentOU | Out-File $RollbackFile -Append
            }
        }
        catch
        {
            # failed - but write to the actions file
            "`"{0}`",`"{1}`",`"{2}`",`"failed`"" -f $u.Username, $CurrentOU, $u.NewOU | Out-File $ActionFile -Append
            Write-Warning "An error occurred moving the user {0}" -f $_.Exception.Message
        }
    }
    catch
    {
        "`n{0} of {1} - the user '{2}' was not found in AD" -f $counter, $csv.Length, $u.Username

        # Write to the action file
        "`"{0}`",`"{1}`",`"{2}`",`"failed - not found in AD`"" -f $u.Username, "", $u.NewOU | Out-File $ActionFile -Append
    }
    $counter++
}