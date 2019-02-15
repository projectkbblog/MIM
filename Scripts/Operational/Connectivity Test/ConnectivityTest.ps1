#####
#
#  Script that can be used to test connectivity from one server to another on specified ports, using the Test-NetConnection cmdlet.  
#   This connectivity tests are read from file (see SampleRules.csv which includes examples) and copied to each source server and executed.  
#   
#   A CSV report is generated with each of the tests performed logged.  The output file is placed in the output directory (specified by parameter), and named
#   in the format $OutputDirectory\HOSTNAME_timestamp.csv
#
#  Note: Testing Connectivity to SQL Server is not possible (i.e. Port 1433), as SQL Server does not respond unless the traffic is valid SQL traffic.
#
#  Sample usage:
#     - ConnectivityTest.ps1 -InputFile SampleRules.csv -OutputDir C:\Scripts\ConnectivityTest\
#
#
# Author: Andrew Silcock
# Date Created: 19-Oct-2017
# Date Modified: 19-Oct-2017
# Version: 1.0
#
# Changes
#   Version 1.0 - 18-May-2018 - Initial Version
#
#####
param
(
    [parameter(Mandatory=$true)]
    [string]$InputFile,
    [parameter(Mandatory=$true)]
    [string]$OutputDir
)

# Get the host name
$hostname = hostname

# Output file (e.g. C:\ConnTest\MYSERVER_20180518_122215.csv)
$OutputFile = ("{0}\{1}_{2}.csv" -f $OutputDir, $hostname, (Get-Date -Format "yyyyMMdd_hhmmss"))

# Output the header row for the file
"{0},{1},{2},{3},{4},{5}" -f "Source Host", "Target Host", "Resolved Address", "Port", "Ping Succeeded", "Tcp Test Succeeded" | Out-File -FilePath $OutputFile

# Read in the connectivity rules
$Rules = Import-Csv $InputFile

$counter = 1;

# track the previous host to improve efficiency
$PreviousTargetHost = ""

# Test the rules
foreach ($r in $Rules)
{
    # only process if the hostname of the server where the script is being run matches the hostname criteria (or *)
    if (($hostname -like $r.SourceHost))
    {
        try
        {
            # If the same as the previous host dont do the ping test
            if ($PreviousTargetHost -ne $r.TargetHost)
            {
                # Ping test  (this is required as ping results from TCP connectivity test are inconsistent, in particular with DCs)
                $PingResult = Test-NetConnection $r.TargetHost
            }

            # TPC connectivity test
            $TcpResult = Test-NetConnection $r.TargetHost -Port $r.Port
        } 
        catch { }

        "{0},{1},{2},{3},{4},{5}" -f $r.SourceHost, $r.TargetHost, $r.Port, $PingResult.RemoteAddress, $PingResult.PingSucceeded, $TcpResult.TcpTestSucceeded | Out-File -FilePath $OutputFile -Append
        "Test {0} of {1} - {2}:{3} - {4}" -f $counter, $Rules.Length, $r.TargetHost, $r.Port, $TcpResult.TcpTestSucceeded
    }
    else
    {
         "Test {0} of {1} - {2}:{3} - Skipped"-f $counter, $Rules.Length, $r.TargetHost, $r.Port
    }
    $counter++
    
    $PreviousTargetHost = $r.TargetHost
}