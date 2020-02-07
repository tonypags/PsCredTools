function Get-CredFilePath {

    <#
    .SYNOPSIS
    Gets the folder where credentials are kept.
    .DESCRIPTION
    Returns the path to the folder where a previously exported credential is stored.
    .EXAMPLE
    Get-CredFilePath
    .NOTES
    The purpose of this function is to maintain consistancy across solutions. 
    We define this arbitrarily, however we choose a location realted to PowerShell's $profile value in the user scope.
    #>

    Join-Path (Split-Path $profile -Parent) 'Credentials'

}
