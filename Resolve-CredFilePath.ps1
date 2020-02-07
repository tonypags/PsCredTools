function Resolve-CredFilePath {

    <#
    .SYNOPSIS
    Standarizes a path location to store a credential to disk. 
    .DESCRIPTION
    Calculates the precise, case-insensitive filename based on user name and cred purpose.
    .PARAMETER Username
    Username-part of file name
    .PARAMETER Tag
    Tag (string) that will uniquely ID the file by name of cred (to pair with name of user)
    .PARAMETER Delimiter
    Separater Character (string) comes after username and before Tag
    .PARAMETER Filename
    Filename, must end in ".xml" (no full paths, hard-coded location in profile folder)
    .PARAMETER Leaf
    Result will be the filename only.
    .EXAMPLE
    Resolve-CredFilePath
    C:\Users\myUserName\Documents\WindowsPowerShell\Credentials\myUserName.xml

    The default result is your username as the filename.
    .EXAMPLE
    Resolve-CredFilePath -Username username -CredTag mysql1 -Delimiter '_'
    C:\Users\myUserName\Documents\WindowsPowerShell\Credentials\username_mysql1.xml

    The simple parameters were used to create a predictable, repeatable filename. 
    .EXAMPLE
    Resolve-CredFilePath -Username $env:USERNAME -CredTag 'FtpServer' -Delimiter '_'
    C:\Users\myUserName\Documents\WindowsPowerShell\Credentials\myUserName_FtpServer.xml

    The env variable is used to run the same command on different users 
    #>

    [CmdletBinding(DefaultParameterSetName='Aggregated')]
    param (

        # Username-part of file name
        [Parameter()]
        [string]
        $Username=$env:USERNAME,

        # Tag (string) that will uniquely ID the file by name of cred (to pair with name of user)
        [Parameter(ParameterSetName='Aggregated')]
        [string]
        $Tag,

        # Separater Character (string) comes after username and before Tag
        [Parameter(ParameterSetName='Aggregated')]
        [string]
        $Delimiter,

        # Filename, must end in ".xml" (no full paths, hard-coded location in profile folder)
        [Parameter(Mandatory=$true,
                    ParameterSetName='FileName')]
        [ValidatePattern('^[\w\d-_]+?\.xml$')]
        [string]
        $FileName,

        # Result will be the filename only.
        [Parameter()]
        [switch]
        $Leaf

    )

    # Resolve Parameter Set
    if ($PSCmdlet.ParameterSetName -eq 'Aggregated') {
        $FileName = "$($Username)$($Delimiter)$($Tag).xml"
    }

    # Define the creds path variables
    $StoredCredParent = Get-CredFilePath
    $StoredCredPath = Join-Path $StoredCredParent $Filename

    # Return result
    if ($Leaf) {$StoredCredPath = Split-Path $StoredCredPath -Leaf}
    Write-Output $StoredCredPath

}
