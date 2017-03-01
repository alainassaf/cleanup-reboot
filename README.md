# run-delprof2
Runs delprof2.exe on servers in the selected Worker Group

#Contributions to this script
I'd like to highlight the posts that helped me write this scrip below.
* https://helgeklein.com/free-tools/delprof2-user-profile-deletion-tool/
* https://mcpmag.com/articles/2015/01/08/powershell-scripts-talk-back.aspx
* https://blogs.msdn.microsoft.com/powershell/2006/10/14/windows-powershell-exit-codes/
* https://blogs.msdn.microsoft.com/kebab/2013/06/09/an-introduction-to-error-handling-in-powershell/
* https://technet.microsoft.com/en-us/library/ff730949.aspx
* https://msdn.microsoft.com/en-us/powershell/scripting/getting-started/cookbooks/selecting-items-from-a-list-box
* http://stackoverflow.com/questions/25187048/run-executable-from-powershell-script-with-parameters
* http://windowssecrets.com/forums/showthread.php/156384-Powershell-Forms-Which-Button

# get-help .\run-delprof2.ps1 -full

NAME
    run-delprof2.ps1
    
SYNOPSIS
    Runs delprof2.exe on servers in the selected Worker Group
    
SYNTAX
    run-delprof2.ps1 [[-XMLBrokers] <Object>] [[-Delproflocation] <Object>] [<CommonParameters>]
    
    
DESCRIPTION
    Runs delprof2.exe on servers in the selected Worker Group
    This script has a dependency on delprof2.exe written by Helge Klein. It can be downloaded from https://helgeklein.com/free-tools/delprof2-user-profile-deletion-tool/. It is recommended that this script be run as a Citrix admin.
    
PARAMETERS
    -XMLBrokers <Object>
        Optional parameter. Which Citrix XMLBroker(s) (farm) to query. Can be a list separated by commas.
        
        Required?                    false
        Position?                    1
        Default value                CITRIXXMLBROKER
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Delproflocation <Object>
        Optional parameter. Location of Delprof2.exe.
        
        Required?                    false
        Position?                    2
        Default value                C:\Delprof2 1.6.0\delprof2.exe
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    None
    
OUTPUTS
    None
    
NOTES
    
        NAME        :  run-delprof2
        VERSION     :  1.04
        LAST UPDATED:  2/6/2017
        AUTHOR      :  Alain Assaf
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\PSScript >.\run-delprof2.ps1
   
    Will use all default values.
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\PSScript >.\run-delprof2.ps1 -XMLBrokers "XMLBROKER"
    
    Will use "XMLBROKER" to query XenApp farm.
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>.\run-delprof2.ps1 -XMLBrokers "XMLBROKER" -Delproflocation "C:\delprof2.exe"
    
    Will use "XMLBROKER" to query XenApp farm and "c:\delprof2.exe" as location for delprof2.exe.
    
# Legal and Licensing
The run-delprof2.ps1 script is licensed under the [MIT license][].

[MIT license]: LICENSE

# Want to connect?
* LinkedIn - https://www.linkedin.com/in/alainassaf
* Twitter - http://twitter.com/alainassaf
* Wag the Real - my blog - https://wagthereal.com
* Edgesightunderthehood - my other - blog https://edgesightunderthehood.com

# Help
I welcome any feedback, ideas or contributors.
