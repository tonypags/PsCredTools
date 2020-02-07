Describe 'Credential Tests' {
    # Define plain text resource with sample data
    $SampleFile = "$PSScriptRoot\SampleData.txt"
    $SampleUser,$strSamplePass = Get-Content $SampleFile
    $SamplePass = $strSamplePass | ConvertTo-SecureString -AsPlainText -Force

    # Create a PSCRED obj from plain text sample data (mimics Get-PsCredential)
    $credential = New-Object System.Management.Automation.PSCredential ($SampleUser, $SamplePass)

    # Define the stored filename
    $SampleXML = "$PSScriptRoot\SampleData.xml"

    # Ensure the sample file doesn't yet exist
    if (Test-Path $SampleXML) {Remove-Item $SampleXML -Force}

    Context 'Export Functions' {

        It 'Export the cred when file does not yet exist' {
            { $credential | Export-Credential -Path $SampleXML } | Should -Not -Throw
        }

        # Capture the datestamp for later
        $Date1 = (Get-Item $SampleXML).LastWriteTime

        It 'Ensure the file was created' {
            Test-Path $SampleXML | Should -Be $true
        }

        It 'Export when file does exist using force param' {
            { $credential | Export-Credential -Path $SampleXML -Force } | Should -Not -Throw
        }
        
        # Capture the datestamp for later
        $Date2 = (Get-Item $SampleXML).LastWriteTime

        It 'Ensure the file was updated' {
            $Date2 -gt $Date1 | Should -Be $true
        }
        
        It 'Ensure the file is valid XML' {
            { [xml](Get-Content $SampleXML) } | Should -Not -Throw
        }
    }

    Context 'Import Functions' {

        $ImportedCred = Import-Credential -Path $SampleXML

        It 'Ensure file can be imported' {
            { $ImportedCred } | Should -Not -Be $null
        }
    
        It 'Ensure the imported Username matches' {
            $ImportedCred.username | Should -Be $SampleUser
        }

        It 'Ensure the imported Password matches' {
            $ImportedCred.GetNetworkCredential().Password | Should -Be $strSamplePass
        }
    }

    Context 'Test Functions' {

        # Define the stored filename for Case of domain user
        $DomainUserXML = "$env:USERPROFILE\Documents\WindowsPowerShell\Credentials\user@domain.local.xml"
        
        It 'Resolve-CredFilePath Function' {

            # Case of domain user
            $splat=@{
                Username = 'user'
                Tag = 'domain.local'
                Delimiter = '@'
            }
            Resolve-CredFilePath @splat | Should -Be $DomainUserXML
        }
        
        It 'File is Viable via LiteralPath' {
            # The previously made XML file will be used
            $splat=@{
                CredFilePath = $SampleXML
                Quiet = $true
            }

            Repair-CredFilePath @splat | Should -Be $true
        }

    }

    Context 'Test Module Variables' {
        # We require a test that will create a task using stored prod creds
        #  this test can be located under another file or module,
        #  figure out what makes sense. 
    }

    # Cannot test aggrigate without human UI
    Write-Warning "Cannot test some repair functionality without Human UI."

    Context 'Test Module Variables' {

        It 'Credentials Folder Location Default Value' {
            $Valid = Join-Path (Split-Path $Profile -Parent) 'Credentials'
            Get-CredFilePath | Should -Be $Valid
        }

    }
    # Unsure how to test this with automation in a domain env, without manually maintaining active creds.
    Write-Warning 'No Automated test for "Test-Credential" function.'
}
