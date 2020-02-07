function Import-Credential {

    <#
    .SYNOPSIS
    Get a credential from a file.
    .DESCRIPTION
    Retrieves a stored credential from a previously exported XML file.
    .PARAMETER Path
    Location of the XML file with the stored credential
    .PARAMETER Quiet
    Suppresses any errors or warning messages
    #>

    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCredential])]
    
    param (
        
        # Location of the XML file with the stored credential
        [Parameter(Position=1,
            ValueFromPipelineByPropertyName=$true)]
        [string]
        $Path=(Resolve-CredFilePath),

        # Suppresses any errors or warning messages
        [Parameter()]
        [switch]
        $Quiet
    )
    
    Begin {}

    Process {

        $TestSplat = @{

            Path = $Path
            Include = '*.xml'
            ErrorAction = 'SilentlyContinue'

        }

        if (Test-Path @TestSplat) {

            Try {

                [System.Management.Automation.PSCredential] (

                    $Cred = Import-Clixml -Path $Path -ErrorAction Stop

                )

            } Catch {

                if (-not $Quiet) {
                    
                    $thisFile = Split-Path $Path -Leaf
                    $thisPath = Split-Path $Path -Parent
                    throw "The file '$thisFile' under folder '$thisPath'cannot be imported as the datatype [System.Management.Automation.PSCredential]."

                }#if (-not $Quiet)

            }#Try{Import-Clixml -Path $Path

        } else {

            if (-not $Quiet) {
            
                $thisFile = Split-Path $Path -Leaf
                $thisPath = Split-Path $Path -Parent
                throw "The file '$thisFile' under folder '$thisPath' does not exist!"
            
            }

        }#if (Test-Path @TestSplat)

    }

    end {

        if ($null -eq $Cred -and -not $Quiet) {

            Write-Warning "The Imported Credential has no data!"

        }

    }
}
