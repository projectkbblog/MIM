#####
#
# Script to create administrative groups for MIM from a file - see Groups.csv as a sample input file
# 
# Author: Andrew Silcock
# Date Created: 16-Apr-2018
# Version: 0.1
#
#####

param
(
    [Parameter(Mandatory=$false)]
    [string]$File
)


$Groups = Import-CSV $File


foreach ($g in $Groups)
{
    New-ADGroup -Name $g.Name -SamAccountName $g.sAMAccountName -Description $g.Description -Path $g.OU -GroupScope DomainLocal -GroupCategory Security
    "Group '{0}' - created" -f $g.sAMAccountName
}