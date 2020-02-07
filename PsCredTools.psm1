$Functions = Get-ChildItem $PSScriptRoot\*.ps1
Foreach ($File in $Functions) {
    . $File.FullName
}
Export-ModuleMember -Function * -Alias * -Variable *

$Private = Get-ChildItem $PSScriptRoot\Private\*.ps1 -ea 0
Foreach ($File in $Private) {
    . $File.FullName
}