#####
#
# Script that update a user's EmployeeEndDate and EmployeeStatus within the MIM Service.  The script will generate a rollback file containing the previous values of the object in the MIM Service, and whether the operation was successful or not.
#
# The script must be run by a user with write access to the EmployeeendDate and EmployeeStatus attributes on user accounts in the MIM Portal, such as a Service Desk user or MIM administrator
#
# Sample Usage:
#    1 - Run the script, taking data from the input file C:\Scripts\UsersToTerminate.csv, making updates to the MIM Service using the localhost
#         Terminate-Externals.ps1 -File C:\Scripts\UsersToTerminate.csv -PerformUpdates
#
#    2 - Run the script, taking data from the input file C:\Scripts\UsersToTerminate.csv, making updates to the MIM Service running on a different server
#         Terminate-Externals.ps1 -File C:\Scripts\UsersToTerminate.csv -PerformUpdates -MIMServiceHost mimservice.contoso.com
#
#    3 - Run the script, taking data from the input file C:\Scripts\UsersToTerminate.csv but not making changes to the user objects in the MIM Service
#         Terminate-Externals.ps1 -File C:\Scripts\UsersToTerminate.csv
#
#  The script expects a CSV file with the following headers "AccountName","EmployeeEndDate","EmployeeStatus". The End date should be in the format yyyy-MM-ddThh:mm:ss.000 (e.g. 2020-04-27T00:00:00.000)
#  Refer to sampleinputdata.csv for sample data
#
# Author: Andrew Silcock
# Date Created: 5-May-2020
# Version: 1.0
#
#####

param (
    [Parameter(Mandatory=$false)]
    [string]$MIMServiceHost,
    [Parameter(Mandatory=$true)]
    [string]$Filename,
    [switch] $PerformUpdates
)

if (-not ($MIMServiceHost))
{
	$MIMServiceHost = "localhost"
}

$Users = Import-CSV -Path $Filename

$OldvaluesFiles = ("{0}.backup-{1}" -f $Filename, (Get-Date -format "yyyy-MM-dd_HH-mm-ss"))
("""AccountName"",""EmployeeEndDate"",""EmployeeStatus"",""Status""") | Out-File $OldvaluesFiles

Import-Module LithnetRMA
Set-ResourceManagementClient -BaseAddress $MIMServiceHost

$counter = 1
foreach($User in $Users)
{
    ("`n({0} of {1}) - {2},{3},{4}" -f $counter, $Users.count, $User.AccountName, $User.EmployeeEndDate, $User.EmployeeStatus)
    
    $MimUser = $null
    $MimUserUpdated=$false
    try
    {
        $MimUser = Get-Resource -ObjectType Person -AttributeName AccountName -AttributeValue $User.AccountName -AttributesToGet @("AccountName","DisplayName","EmployeeStatus","EmployeeEndDate")
        ("`tExisting values End Date: {0} Status: {1}" -f $MimUser.EmployeeEndDate, $MimUser.EmployeeStatus)
        
    }
    catch
    {
        ("""{0}"",""{1}"",""{2}"",""{3}""" -f $User.AccountName,"","","Failure - user not found in the MIM Portal") | Out-File $OldvaluesFiles -Append
        Write-Warning "User not found in the MIM Portal"
    }

    if ($MimUser)
    {
        $MimUser.EmployeeEndDate = $User.EmployeeEndDate
        $MimUser.EmployeeStatus = $User.EmployeeStatus
        $MimUserUpdated=$true

        if ($MimUserUpdated -and $PerformUpdates)
        {
            try
            {
                "`tSaving user update"
                Save-Resource $MimUser
                ("""{0}"",""{1}"",""{2}"",""{3}""" -f $User.AccountName, $MimUser.EmployeeEndDate, $MimUser.EmployeeStatus, "Success") | Out-File $OldvaluesFiles -Append
            }
            catch
            {
                ("""{0}"",""{1}"",""{2}"",""{3}""" -f $User.AccountName, $MimUser.EmployeeEndDate, $MimUser.EmployeeStatus, "Failure - error occurred updating the user") | Out-File $OldvaluesFiles -Append
            }
        }
        else
        {
            ("""{0}"",""{1}"",""{2}"",""{3}""" -f $User.AccountName, $MimUser.EmployeeEndDate, $MimUser.EmployeeStatus, "Skipped - no update required or PerformUpdates is disabled") | Out-File $OldvaluesFiles -Append
        }
    }
    $counter++
}


Write-Warning ("Rollback file written to '{0}'" -f $OldvaluesFiles)