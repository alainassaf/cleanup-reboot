# cleanup-reboot
Checks if a server is online, has logins allowed, but has no users. If this is found, the script sets the Logon mode to ProhibitLogonsUntilServerRestart

#Contributions to this script
I'd like to highlight the posts that helped me write this scrip below.
* http://carlwebster.com/finding-offline-servers-using-powershell-part-1-of-4/
* http://blog.itvce.com/?p=79 Created by Dane Young

# $ get-help .\cleanup-reboot.ps1 -full

NAME<br>
    cleanup-reboot.ps1
    
SYNOPSIS<br>
    Script that checks if a server is online, has logins allowed, but has no users. If this is found, the script sets the Logon mode to ProhibitLogonsUntilServerRestart
    
SYNTAX<br>
    PS> cleanup-reboot.ps1 [[-DeliveryControllers] <Object>] [<CommonParameters>]
    
DESCRIPTION<br>
    Script that checks if a server is online, has logins allowed, but has no users. If this is found, the script sets the Logon mode to     ProhibitLogonsUntilServerRestart. It is recommended that this script be run as a Citrix admin. In addition, the Citrix Powershell modules should be installed

PARAMETERS
    -DeliveryControllers <Object>
        Required parameter. Which Citrix Delivery Controller(s) (farm) to query.
        
        Required?                    false
        Position?                    1
        Default value                YOURDDC.DOMAIN.LOCAL
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS<br>
    None.
    
OUTPUTS<br>
    None. (Optional - The script will generate an report via email of any servers that are not servicing users.)
    
NOTES<pre>
    NAME: cleanup-reboot.ps1
    VERSION: 1.02
    CHANGE LOG - Version - When - What - Who
    1.00 - 12/12/2016 - Initial script - Alain Assaf
    1.01 - 1/03/2017 - Added test to check RDP, ICA, and Session Reliability ports before setting LogOnMode to reboot - Alain Assaf
    1.02 - 1/04/2017 - Added lines to check server load. If server has no users and a load higher than 3500, then change LogOnMode                              to reboot - Alain Assaf
    AUTHOR: Alain Assaf
    LASTEDIT: January 04, 2017</pre>
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\PSScript>.\cleanup-reboot.ps1
    
    Will use all default values.
    Will query servers in the default Farm and find servers that are not servicing users.
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\PSScript>.\cleanup-reboot.ps1 -DeliveryController YOURDDC.DOMAIN.LOCAL
    
    Will use YOURDDC.DOMAIN.LOCAL for the delivery controller address.
    Will query servers in the YOURDDC.DOMAIN.LOCAL Farm and find servers that are not servicing users.
    
# Legal and Licensing
The cleanup-reboot.ps1 script is licensed under the [MIT license][].

[MIT license]: LICENSE

# Want to connect?
* LinkedIn - https://www.linkedin.com/in/alainassaf
* Twitter - http://twitter.com/alainassaf
* Wag the Real - my blog - https://wagthereal.com
* Edgesightunderthehood - my other - blog https://edgesightunderthehood.com

# Help
I welcome any feedback, ideas or contributors.
