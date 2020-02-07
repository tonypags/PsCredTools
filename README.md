# Introduction 
This PowerShell Module will allow a user to work with (test, store, and retreive, etc.) windows credentials in an XML file. By Default the file will be located under the user's profile. The credential XML file exports will only work for the user who created the file, and only on the computer where the file was created. 

# Getting Started
TODO: Guide users through getting your code up and running on their own system. In this section you can talk about:
1.	Installation process
    Clone git master branch. Y'all just need to wait until I get this bad boy published in NuGet. 

2.	Software dependencies
    This module has no dependancies other than a supported Windows OS. This module is designed to be used as a dependancy for other modules.

3.	Version History
	- v0.1.0.0 - Basic funcitons for Import and Export.
	- v0.1.1.0 - Added function to Test a cred.
	- v0.1.5.2 - Added functions and Pester Tests.
	- v0.2.5.3 - Functions to files in prep for CI/CD. Renamed Functions in repair family.
	- v0.3.0.4 - Some function parameters renamed. Cleaned up code for public. 


# Build, Test, and Publish
1.  Get next version number v#.#.#.# and a comment [string] for the change log.
2.  Create a new Package folder as .\Package\v#.#.#.#\
3.  Copy the PSD1 files in as-is.
    Update the version number and copyright date if required.
	Update the Exported Function Name array with the basenames of the files under the .\ folder only.
4.  Create a new, blank PSM1 file in here. Populate it with all of the PS1 files' content from the .\ and .\Private folders.
5.  Create a NUSPEC file and update the version and change log.
6.  Build the NuGet package.
7.  Push to private repo.

# Contribute
1.  Add your changes to a new feature branch.
2.  Add Pester tests for your changes.
3.  Push your branch to origin.
4.  Submit a PR with description of changes.
5.  Follow up in 2 business days.
