<#
.SYNOPSIS
 Script that checks if a server is online, has logins allowed, but has no users. If this is found, the script sets the Logon mode to ProhibitLogonsUntilServerRestart
.DESCRIPTION
 Script that checks if a server is online, has logins allowed, but has no users. If this is found, the script sets the Logon mode to ProhibitLogonsUntilServerRestart. It is recommended that this script be run as a Citrix admin. In addition, the Citrix Powershell modules should be installed 
.PARAMETER DeliveryControllers
 Required parameter. Which Citrix Delivery Controller(s) (farm) to query.
.EXAMPLE
 PS C:\PSScript> .\cleanup-reboot.ps1
 
 Will use all default values.
 Will query servers in the default Farm and find servers that are not servicing users.
.EXAMPLE
 PS C:\PSScript> .\cleanup-reboot.ps1 -DeliveryController YOURDDC.DOMAIN.LOCAL 
 
 Will use YOURDDC.DOMAIN.LOCAL for the delivery controller address.
 Will query servers in the YOURDDC.DOMAIN.LOCAL Farm and find servers that are not servicing users.
.OUTPUTS
 None. The script will generate an report via email of any servers that are not servicing users.
.NOTES
 NAME: cleanup-reboot.ps1
 VERSION: 1.02
 CHANGE LOG - Version - When - What - Who
 1.00 - 12/12/2016 - Initial script - Alain Assaf
 1.01 - 1/03/2017 - Added test to check RDP, ICA, and Session Reliability ports before setting LogOnMode to reboot - Alain Assaf
 1.02 - 1/04/2017 - Added lines to check server load. If server has no users and a load higher than 3500, then change LogOnMode to reboot - Alain Assaf
 AUTHOR: Alain Assaf
 LASTEDIT: January 04, 2017
.LINK
 http://www.linkedin.com/in/alainassaf/
 http://wagthereal.com
 http://carlwebster.com/finding-offline-servers-using-powershell-part-1-of-4/
 http://blog.itvce.com/?p=79 Created by Dane Young
#>


Param(
 [parameter(Position = 0, Mandatory=$False )]
 [ValidateNotNullOrEmpty()]
 $DeliveryControllers="YOURDDC.DOMAIN.LOCAL" # Change to hardcode a default value for your Delivery Controller. Can be a list separated by commas
)
 
#Constants
#$ErrorActionPreference= 'silentlycontinue'
$PSSnapins = ("Citrix*")
$PSModules = ("Citrix*")
$WORKERGROUPS = "Zone Data Collectors,Productivity Apps" #Define which worker groups should be processed. Comma seperated list, spaces acceptable, case insensitive (for example "Zone Data Collectors,Productivity Apps"). Leaving blank will process all servers in the farm as in previous revisions
$EXCLUDESERVERS = "CORPCTX01,CORPCTX02,CORPCTX05" #Define which servers should be excluded from processing. Comma seperated list, short names only, case insensitive (for example "CORPCTX01,CORPCTX02,CORPCTX05")
 

### START FUNCTION: get-mymodule #####################################################
Function Get-MyModule {
    Param([string]$modules)
    $ErrorActionPreference= 'silentlycontinue'
        foreach ($mod in $modules.Split(",")) {
            if(-not(Get-Module -name $mod)) {
                if(Get-Module -ListAvailable | Where-Object { $_.name -like $mod }) {
                    Import-Module -Name $mod
                } else {
                    write-warning "$mod PowerShell Module not available."
                    write-warning "Please run this script from a system with the $mod PowerShell Module is installed."
                    exit 1
                }
            }
        }
}
### END FUNCTION: get-mymodule #####################################################
 
### START FUNCTION: get-mysnapin ###################################################
Function Get-MySnapin {
    Param([string]$snapins)
        $ErrorActionPreference= 'silentlycontinue'
        foreach ($snap in $snapins.Split(",")) {
            if(-not(Get-PSSnapin -name $snap)) {
                if(Get-PSSnapin -Registered | Where-Object { $_.name -like $snap }) {
                    add-PSSnapin -Name $snap
                    $true
                }                                                                           
                else {
                    write-warning "$snap PowerShell Cmdlet not available."
                    write-warning "Please run this script from a system with the $snap PowerShell Cmdlet installed."
                    exit 1
                }                                                                           
            }                                                                                                                                                                  
        }
}
### END FUNCTION: get-mysnapin #####################################################
 

### START FUNCTION: test-port ######################################################
# Function to test RDP availability
# Written by Aaron Wurthmann (aaron (AT) wurthmann (DOT) com)
function Test-Port{
    Param([string]$srv=$strhost,$port=3389,$timeout=300)
    $ErrorActionPreference = "SilentlyContinue"
    $tcpclient = new-Object system.Net.Sockets.TcpClient
    $iar = $tcpclient.BeginConnect($srv,$port,$null,$null)
    $wait = $iar.AsyncWaitHandle.WaitOne($timeout,$false)
    if(!$wait) {
        $tcpclient.Close()
        Return $false
    } else {
        $error.Clear()
        $tcpclient.EndConnect($iar) | out-Null
        Return $true
        $tcpclient.Close()
    }
}
### END FUNCTION: test-port ########################################################

#Import Module(s) and Snapin(s)
get-mymodule $PSModules
get-MySnapin $PSSnapins


#Find an XML Broker that is up
$test = $DeliveryControllers.Split(",")
foreach ($broker in $test) {
    if (Test-Port $broker) {
        $DeliveryController = $broker
        break
    }
}

#Initialize array
$finalout = @()
 
$AllXAServers = Get-XAServer -ComputerName $DeliveryController | Sort-Object ServerName
$XAServers = @()
ForEach( $XAServer in $AllXAServers )
#ForEach( $XAServer in $ctxservers )
{
   $XAServers += $XAServer.ServerName
}

$OnlineXAServers = Get-XAzone -ComputerName $DeliveryController | Get-XAServer -ComputerName $DeliveryController -OnlineOnly | Sort-Object ServerName
$OnlineServers = @()
ForEach( $OnlineServer in $OnlineXAServers )
{
   $OnlineServers += $OnlineServer.ServerName
}

$workergroups = $WORKERGROUPS.Split(',') # Split the WORKERGROUPS variable defined above
$excludedservers = $EXCLUDESERVERS.Split(',') # Split the EXCLUDESERVERS variable defined above
$XAsessions = @(get-xasession -ComputerName $DeliveryController | Where {$_.State -ne "Listening"} | Where {$_.SessionName -ne "Console"}) # Create a query against server passed through as first variable where protocol is Ica. Disregard listening sessions
foreach ($workergroup in $workergroups){        # Iterate through workergroups
    $checkworkergroup = @(get-xaworkergroup -ComputerName $DeliveryController | where-object {$_.WorkerGroupName -eq $workergroup})
    if ($checkworkergroup.count -eq 0){
        $finalout += "$workergroup is invalid. Confirm names in worker group list and try again.<br>"
        write-verbose "$workergroup is invalid. Confirm names in worker group list and try again."
    } else {
        $workergroupservers = @(get-xaworkergroupserver -ComputerName $DeliveryController -workergroupname $workergroup | sort-object -property ServerName) # Create a query to pull the Worker Group membership
        $finalout += "Checking servers in Worker Group: $WORKERGROUP<br>"
        write-verbose "Checking servers in Worker Group: $WORKERGROUP"
        foreach ($workergroupserver in $workergroupservers){ # Iterate through workergroup servers
            $server = $workergroupserver.ServerName
                if (($excludedservers -notcontains $server) -and ($OnlineServers -contains $server)) { # Check that server is not excluded and is online
                    if ("$server" -eq "$env:COMPUTERNAME") { # Bypass local server
                    } else {
                        $sessions = $xasessions | Where {$_.ServerName -eq $server} # Create a query against server passed through as first variable where protocol is Ica. Disregard listening sessions
                        if ($sessions.count -eq 0) { #Server has no users. 
                            $wgServerLoad = Get-XAServerLoad -computername $DeliveryController -servername $server #Check server load
                            if ($wgServerLoad.Load -ge 3500) {
                                set-XAServerLogOnMode -ServerName $server -LogOnMode ProhibitNewLogOnsUntilRestart #Set ProhibitNewLogOnsUntilRestart
                                $finalout += "$server is online, but is hosting no users with load of $wgServerLoad. LogOnMode set to ProhibitNewLogOnsUntilRestart.<br>"
                                write-verbose "$server is online, but is hosting no users with load of $wgServerLoad. LogOnMode set to ProhibitNewLogOnsUntilRestart."
                            }
                        }
                    }
                }
        }
    }
}

### Un-comment lines below to allow of an emailed report ###
#Assign e-mail(s) to $sendto variable and SMTP server to $SMTPsrv
#$sendto = "first.last@domain.com#Can add additional emails separated by commas
#$from = "" #Set appropriate from address
#$SMTPsrv = "" #Set appropriate SMTP server

#$title = "Online servers with zero users"
 
#foreach ($email in $sendto) {
#    $smtpTo = $email
#    $smtpServer = $SMTPsrv
#    $smtpFrom = $from
#    $messageSubject = "Report: Online servers with zero users"
#    $date = get-date -UFormat "%d.%m.%y - %H.%M.%S"
#    $relayServer = (test-connection $smtpServer -count 1).IPV4Address.tostring()
    
#    $message = New-Object System.Net.Mail.MailMessage $smtpfrom, $smtpto
#    $message.Subject = $messageSubject
#    $message.IsBodyHTML = $true
        
#    $message.Body = $finalout

#    $smtp = New-Object Net.Mail.SmtpClient($smtpServer)
#    $smtp.Send($message) 

#}