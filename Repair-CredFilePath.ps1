function Repair-CredFilePath {

    <#
    .SYNOPSIS
    Ensure user has viable creds saved on local disk as XML, and attempts to repair if needed.
    .DESCRIPTION
    If ok or successful return is TRUE, or will prompt for creds and create file then return TRUE, or FALSE if errors.
    .PARAMETER Path
    File LiteralPath to check, must end in ".xml"
    .PARAMETER Username
    The username that should be associated with the credential object found in the $Path file.
    .PARAMETER PromptMsg
    Optional message to display to user if Get-Credential is called
    .PARAMETER NoUI
    Will throw an error instead of attempting to ask user for creds when none are found
    .EXAMPLE
    Resolve-CredFilePath | Repair-CredFilePath
    True

    The default file was confirmed to be an exported credential object.
    If not, the user is prompted to enter their password.
    .EXAMPLE
    Resolve-CredFilePath | Repair-CredFilePath -NoUI
    False

    The default file was confirmed to NOT be an exported credential object.
    No attempt is made to repair the file and a false boolean is returned.
    .Example
    #>

    [CmdletBinding(SupportsShouldProcess=$true)]
    param (

        # File Path to check, must end in ".xml"
        [Parameter(ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        [ValidatePattern('\.xml$')]
        [string[]]
        $Path,

        # The username that should be associated with the credential object found in the $Path file.
        [Parameter()]
        [string]
        $Username,

        # Optional message to display to user if Get-Credential is called
        [Parameter()]
        [string]
        $PromptMsg = "Please re-enter your credentials:",

        # Will throw an error instead of attempting to ask user for creds when none are found
        [Parameter()]
        [switch]
        $NoUI

    )


    Begin {}

    Process {

        Foreach ($item in $Path) {

            $Parent = Split-Path $item -Parent
            
            # Make sure the parent folder exists
            if (-not (Test-Path $Parent)) {

                if ($Force) {
                    
                    $CreateFolder = $true
                    
                } elseif ($pscmdlet.ShouldProcess($Parent, "Create folder")) {
                    
                    $CreateFolder = $true
                    
                } else {
                    
                    $CreateFolder = $false
                    
                }
                
                if ($CreateFolder) {
                
                    New-Item -Path $Parent -ItemType Directory -Force
                    Write-Verbose "Folder created: $Parent"
                
                } else {

                    Write-Warning "The parent folder for the XML file does not exist: $Parent"
                    break

                }

            }#END if (-not (Test-Path $Parent))
            
        
            # Prompt user if required and allowed
            if (-not $NoUI) {

                if (!$Username) {

                    # Guess the username is the XML file BaseName
                    $Username = "$((Split-Path $item -Leaf) -replace '\.xml')"
                    
                }

                # Build the params
                $CredSplat = @{UserName=$Username}
                if($PromptMsg){$CredSplat.Add('Message',$PromptMsg)}
                
                # Prompt user for creds
                if (
                    
                    $pscmdlet.ShouldProcess(
                        $item,
                        "Prompt user for Credentials and Create $($item)"
                    )

                ) {

                    Get-Credential @CredSplat | Export-Credential -Path $item 
                
                }
            }

            Try {
            
                # Return true if we can import a true credential object
                (Import-Credential -Path $item -ea Stop) -is [PsCredential]
            
            } Catch {
            
                # Return false if any errors
                Write-Output $false
            
            }

        }#END Foreach ($item in $Path)

    }#End Process

    End {}
    
}
