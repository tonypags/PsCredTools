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
    .PARAMETER Quiet
    Suppresses any errors or warning messages
    .PARAMETER ShowConfirm

    .EXAMPLE

    #>
    
    [CmdletBinding(DefaultParameterSetName='ShowConfirm')]
    param (

        [Parameter(Position=0,
            ValueFromPipelineByPropertyName=$true)]
        [string]
        $Path=(Resolve-CredFilePath),

        [Parameter(Mandatory=$true,
            Position=1,
            ValueFromPipelineByPropertyName=$true,
            ValueFromPipeline=$true)]
        [System.Management.Automation.PSCredential]
        [Alias('PSCredential')]
        $Credential,
        
        [Parameter(ParameterSetName='Quiet')]
        [switch]
        $Quiet,
        
        # Default set has no logic but will require user interaction in many cases
        [Parameter(ParameterSetName='ShowConfirm')]
        [switch]
        $ShowConfirm,
        
        [Parameter()]
        [switch]
        $Force,
        
        [Parameter()]
        [switch]
        $PassThru

    )
    
    begin {}

    process {
        
        $FileExists = Test-Path $Path -ErrorAction SilentlyContinue
        $isXmlFile = Test-Path $Path -Include *.xml

        if ($isXmlFile) {
            if ($Force) {
                $Path | Remove-Item -Force
                Write-Verbose "Existing file deleted."
            } elseif ($Quiet) {
                throw "The supplied Path already exists."
            } else { #This is the ShowConfirm section
                $Path | Remove-Item -Confirm:$true
                if (Test-Path $Path -Include *.xml) {
                    throw "The file '$(
                        Split-Path $Path -Leaf
                    )' already exists under folder '$(
                        Split-Path $Path -Parent
                    )'. Please re-run this command with the '-Force' $(
                    )parameter or chose a different file."
                }#if (Test-Path $Path -Include *.xml)
            }#if ($Force)
        } elseif ($FileExists) {
            if ($Force) {
                throw "The file '$(
                    Split-Path $Path -Leaf
                )' already exists under folder '$(
                    Split-Path $Path -Parent
                )' but it is not an XML file! $(
                )Choose a different file."
            }#if ($Force)
        } else {
            # No File exists then we can create one OK
        }#if ($FileExists -and $isXmlFile)


        Try {
        
            $ExportSplat = @{
                Path = $Path
                ErrorAction = 'Stop'
            }
            $Credential |
                Export-Clixml @ExportSplat
        
        } Catch {
    
            if ($Quiet) {
                throw "The supplied Credential object could not be exported."
            } else {
                throw $_
            }#if ($Quiet)
    
        }#Try{Import-Clixml -Path $Path


        if ($PassThru) {
    
            Get-Item $Path
    
        }
    
    }

    end {}

}
