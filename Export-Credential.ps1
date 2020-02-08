function Export-Credential {

    <#
    .SYNOPSIS
    Puts a credential into a file.
    .DESCRIPTION
    Stores a credential in an XML file.
    .PARAMETER Path
    Location of the XML file with the stored credential
    .PARAMETER Credential
    The PsCredential object to store in a file
    .PARAMETER Force
    Overwrites the file if it exists
    .PARAMETER PassThru
    Outputs a FileInfo object to the pipeline representing the new file
    .EXAMPLE
    Get-Credential | Export-Credential
    Prompts the user for a credential and stores it under the default location.
    #>
    
    [CmdletBinding()]
    param (

        # Location of the XML file with the stored credential
        [Parameter(Position=0,
            ValueFromPipelineByPropertyName=$true)]
        [ValidatePattern('.*\.xml$')]
        [string]
        $Path=(Resolve-CredFilePath),

        # The PsCredential object to store in a file
        [Parameter(Mandatory=$true,
            Position=1,
            ValueFromPipelineByPropertyName=$true,
            ValueFromPipeline=$true)]
        [System.Management.Automation.PSCredential]
        [Alias('PSCredential')]
        $Credential,
        
        # Overwrites the file if it exists
        [Parameter()]
        [switch]
        $Force,
        
        # Outputs a FileInfo object to the pipeline representing the new file
        [Parameter()]
        [switch]
        $PassThru

    )
    
    begin {}

    process {

        Foreach ($Cred in $Credential) {

            # Before we attempt to create a file, we check for an existing one with the same name
            if (Test-Path $Path -ErrorAction SilentlyContinue) {
                
                if ($Force) {
                    
                    # The file already exists, remove it
                    $Path | Remove-Item -Force
                    Write-Verbose "Existing file deleted."
                    
                } else {
                    
                    # This should prompt the user for confirmation before deleting the file.
                    $Path | Remove-Item
                    if (Test-Path $Path) {
                        
                        $thisFile = Split-Path $Path -Leaf
                        $thisPath = Split-Path $Path -Parent
                        Write-Warning "The file '$thisFile' already exists under folder '$thisPath'." 
                        Write-Verbose "Please re-run this command with the '-Force' parameter or chose a different file."

                    }

                }#END if ($Force)

            }#END if ($FileExists -and $isXmlFile)


            # Now we create the file
            Try {
            
                $Cred | Export-Clixml -Path $Path -ErrorAction Stop
            
            } Catch {
        
                throw "The credential could not be exported: $($_.Exception.Message)"
        
            }


            if ($PassThru) {
        
                Get-Item $Path
        
            }

        }#END Foreach ($Cred in $Credential)
    
    }

    end {}

}#END function Export-Credential {
