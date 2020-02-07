function Repair-CredFilePath {
    <#
    .SYNOPSIS
    Ensure user has viable creds saved on local disk as XML, and attempts to repair if needed.
    .DESCRIPTION
    If ok or successful return is TRUE, or will prompt for creds and create file then return TRUE, or FALSE if errors.
    .EXAMPLE
    Resolve-CredFilePath | Repair-CredFilePath
    True

    The default file was confirmed to be an exported credential object.
    If not, the user is prompted to enter their password.
    .EXAMPLE
    Resolve-CredFilePath | Repair-CredFilePath -Quiet
    False

    The default file was confirmed to NOT be an exported credential object.
    A False boolean is returned.
    .Example
    #>
    [CmdletBinding(DefaultParameterSetName='CredFilePath',
                    SupportsShouldProcess=$true)]
    param (
        # File LiteralPath to check, must end in ".xml"
        [Parameter(ParameterSetName='CredFilePath',
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    Position=0)]
        [Alias('Path')]
        [string]
        $CredFilePath,

        # File name to check, must end in ".xml" (no full paths, hard-coded location in profile folder)
        [Parameter(Mandatory=$true,
                    Position=0,
                    ParameterSetName='FileName')]
        [ValidatePattern('\.xml$')]
        [string]
        $FileName,

        # Optional message to display to user if Get-Credential is called
        [Parameter()]
        [string]
        $PromptMsg = "Please re-enter your credentials:",

        # Will throw an error instead of attempting to ask user for creds when none are found
        [Parameter()]
        [switch]
        $Quiet
    )

    # Define the creds path variables
    $StoredCredParent = Get-CredFilePath
    
    # Resolve Parameter Set
    if ($PSCmdlet.ParameterSetName -eq 'CredFilePath') {
        
        $StoredCredPath = $CredFilePath
    
    } elseif ($PSCmdlet.ParameterSetName -eq 'Filename') {
        
        $StoredCredPath = Join-Path $StoredCredParent $Filename

    } else {
        throw "Unhandled Parameter Set"
    }

    # Check if the parent folder exists
    $requiresUI = $true
    if (Test-Path $StoredCredParent) {

        # Check if file exists
        if (Test-Path $StoredCredPath) {
            # Continue if found
            $requiresUI = $false
        }

    } else {

        # Create folder if not found
        if ($pscmdlet.ShouldProcess($StoredCredParent, "Create folder"))
        {
            New-Item -Path $StoredCredParent -ItemType Directory -Force
            Write-Verbose "Folder created: $StoredCredParent"
        }

    }

    # Prompt user if required and allowed
    if ($requiresUI -and -not $Quiet) {

        # Guess the username is the XML file BaseName
        $Username = "$((Split-Path $StoredCredPath -Leaf) -replace '\.xml')"

        # Build the params
        $CredSplat = @{UserName=$Username}
        if($PromptMsg){$CredSplat.Add('Message',$PromptMsg)}
        
        # Prompt user for creds
        if (
            $pscmdlet.ShouldProcess(
                $StoredCredPath,
                "Prompt user for Credentials and Create $($StoredCredPath)"
            )
        ) {
            Get-Credential @CredSplat | Export-Credential -Path $StoredCredPath 
        }
    }

    Try {
        # Return true if we can import a true credential object
        (Import-Credential -Path $StoredCredPath -ea Stop) -is [PsCredential]
    }
    Catch {
        # Return false if any errors
        Write-Output $false
    }
}
