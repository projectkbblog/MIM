param 
(
    [Parameter(Mandatory=$true)]
    [string] $RoleName,
    [Parameter(Mandatory=$true)]
    [string] $Justification,
    [Parameter(Mandatory=$false)]
    [TimeSpan] $TimeSpan,
    [Parameter(Mandatory=$false)]
    [Datetime] $RequestedTime
)
#####
#
# Script that utlises the MIM PAM Powershell cmdlets to create a PAM Request
# 
# Pre-requisites:
#   - the script must be run on a server or desktop with the MIM PAM PowerShell cmdlets installed
#   - it is assumed the user running the script is eligible for escalation in the specified role
#
# Sample Usage:
#
#  - Request access to the MIM Operators role for 2 hours, starting in 2 hours time
#      .\Create-PAMRequest -RoleName "MIM Operators" -Justification "Access required to administer the system" -TimeSpan (New-TimeSpan -Hours 2) -RequestedTime (Get-Date).AddHours(2)
#
#  - Request access to the MIM Operators role for 2 hours, starting as as soon as the request is approved
#     .\Create-PAMRequest -RoleName "MIM Operators" -Justification "Access required to administer the system" -TimeSpan (New-TimeSpan -Hours 2)
#
#  - Request access to the MIM Operators role for the default period of time, starting as as soon as the request is approved
#      .\Create-PAMRequest -RoleName "MIM Operators" -Justification "Access required to administer the system" 
#
#  - Request access to the MIM Operators role for the default period of time, starting in 2 days time
#      .\Create-PAMRequest -RoleName "MIM Operators" -Justification "Access required to administer the system" -RequestedTime (Get-Date).AddDays(2)#
#
#
# Author: Andrew Silcock
# Date Created: 10-Nov-2017
# Version: 0.1
#
#####

function Get-PAMRole
{
    param 
    (
        [Parameter(Mandatory=$true)]
        [string] $Role 
    )

    try
    {
        $PAMRole = Get-PAMRoleForRequest -DisplayName $Role 
    }
    catch { return $null }

    return $PAMRole
}
$RoleForApproval = Get-PAMRole -Role $RoleName

if ($TimeSpan -and $TimeSpan -gt (New-TimeSpan -seconds $RoleForApproval.TTL))
{
    Write-Warning ("The requested time span '{0}' is greate than the maximum allowable '{1}'" -f $TimeSpan,  (New-TimeSpan -seconds $RoleForApproval.TTL))
    exit 0
}

if ($RoleForApproval)
{
    if ($TimeSpan -and $RequestedTime)
    {
        "Creating Role Request`n`tRole:`t{0}`n`tJustification:`t{1}`n`tRequested Time Span:`t{2}`n`tRequested Start Time:`t{3}" -f $RoleName, $Justification, $TimeSpan, $RequestedTime
        New-PAMRequest -Role $RoleForApproval -Justification $Justification -RequestedTTL $TimeSpan -RequestedTime $RequestedTime
    }
    elseif ($TimeSpan)
    {
        "Creating Role Request`n`tRole:`t{0}`n`tJustification:`t{1}`n`tRequested Time Span:`{2} (mins)`n`tRequested Start Time:`t{2}" -f $RoleName, $Justification, $TimeSpan, (Get-Date)
        New-PAMRequest -Role $RoleForApproval -Justification $Justification -RequestedTTL $TimeSpan
    }
    elseif ($RequestedTime)
    {
        "Creating Role Request`n`tRole:`t{0}`n`tJustification:`t{1}`n`tRequested Time Span:`t{2} (default)`n`tRequested Start Time:`t{3}" -f $RoleName, $Justification, $RoleForApproval.TTL, $RequestedTime
        New-PAMRequest -Role $RoleForApproval -Justification $Justification -RequestedTime $RequestedTime
    }
    else
    {
        "Creating Role Request`n`tRole:`t{0}`n`tJustification:`t{1}`n`tRequested Time Span:`t{2} (default)`n`tRequested Start Time:`t{3}" -f $RoleName, $Justification, $RoleForApproval.TTL, (Get-Date)
        New-PAMRequest -Role $RoleForApproval -Justification $Justification
    }
}
else
{
    Write-Warning "Role '{0}' not found" -f $RoleName

}