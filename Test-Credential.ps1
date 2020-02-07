Function Test-Credential 
{
    <#
    .SYNOPSIS
    Confirms a Windows account's password is valid.
    .DESCRIPTION
    Uses the Run As Different User windows feature to test the given credential by attempting to open a process as the local or domain user.
    .PARAMETER Credential
    A PsCredential object
    .EXAMPLE
    Import-Credential | Test-Credential
    Uses your default stored credential and checks its validity.
    .EXAMPLE
    Get-Credential | Test-Credential
    Asks the user for a set of credentials and tests them.
    #>

    [cmdletbinding()]
	param (

        # A PsCredential object
        [parameter(ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
		[System.Management.Automation.PSCredential]
        $Credential

    )

    $Valid = $false

    Try {

        Write-Verbose "Attempting to open a shell as user $($Credential.username)."
        Start-Process cmd.exe /c -Credential $Credential -ea Stop
        $Valid = $true
    
    } Catch {
    
        If ( $_ -notlike '*Logon failure:*') {

            $Valid = $true
            
        }
    
    }

    $Valid

}
