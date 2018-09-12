#####
#
# Script that utlises the MIM PAM Powershell cmdlets to retrieve any escalation requests that are approved by the current user and prompts them for an action (Approve, Deny or Ignore).
# 
# Pre-requisites:
#   - the script must be run on a server or desktop with the MIM PAM PowerShell cmdlets installed
#   - it is assumed the user running the script is an approver for escalation requests.
#
# Sample Usage:
#     View pending approvals and be prompted for the action to take
#     - .\Get-PAMApprovals.ps1
#
# Author: Andrew Silcock
# Date Created: 10-Nov-2017
# Version: 0.1
#
#####

function Get-ApprovalAction
{
    ##########
    # Function: Get-ApprovalAction 
    #
    # Presents a menu to the user running the scrip as to whether they want to Approve, Deny or Ignore the request
    #
    ##########

    $title = "Approve the request"
    $message = "Do you want to approve this request?"

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Approve", `
        "Approves the request"

    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&Deny", `
        "Denies the request"

    $ignore = New-Object System.Management.Automation.Host.ChoiceDescription "&No Action", `
        "Takes no action with request"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $ignore)

    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 

    switch ($result)
        {
            0 {return "approve"}
            1 {return "deny"}
            2 {return "ignore"}
        }
    return "ignore"
}

# Gets PAM Approvals requiring action
$Requests = Get-PAMRequestToApprove
"There are {0} requests to approve" -f $Requests.Length
""

$counter = 1
foreach ($r in $Requests)
{
    "Request {0} - Details" -f $counter
    "`tRole:`t{0}" -f $r.RoleName
    
    # Get the requestor's display name from the Active Directory account
    $RequestorDisplayName = ""
    $RequestorDisplayName = (Get-ADUSer $r.Requestor).Name
    
    # Display the details of the request
    "`tRequestor:`t{0} ({1})" -f $r.Requestor, $RequestorDisplayName
    "`tJustification:`t{0})" -f $r.Justification
    "`tStart Time:`t{0})" -f $r.RequestedTime
    "`tLength of time requested:`t{0} hours" -f ($r.RequestedTTL/60/60)

   # Get the approval action from the owner
   $ApprovalAction = Get-ApprovalAction

   switch ($ApprovalAction)
   {
       "approve" 
       { 
           "`n`tApproving";  
           try
           {
               Set-PAMRequestToApprove -Request $r -Approve
               "`n`tApproval Completed";  
           }
           catch 
           {
               Write-Warning "An error has occurred approving the request"
           }
       }
       "deny" 
       { 
           "`n`tDenying" 
            try
            {
                Set-PAMRequestToApprove -Request $r -Reject
                "`n`tRejection completed";  
            }
            catch 
            {
                Write-Warning "An error has occurred rejecting the request"
            }
        }
        "ignore" 
        { 
            "`n`tNo Action has been taken, the request can be rejected or approved at a later time"  
        }
    }
}
