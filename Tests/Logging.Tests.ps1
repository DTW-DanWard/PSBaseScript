Set-StrictMode -Version Latest

#region Dot-source Source file associated with this test file
# if no value returned just exit; specific error is already written in Get-SourceScriptFilePath call
. (Join-Path -Path $PSScriptRoot -ChildPath Get-SourceScriptFilePath.ps1)
$SourceScript = Get-SourceScriptFilePath
if ($null -eq $SourceScript) { exit }
Describe "Re/loading: $SourceScript" { }
. $SourceScript
#endregion


#region Tests add/remove indent level
Describe 'add and remove indent level' {
  It 'adds 1 and equals 1 with initial default value 0' {
    $InitialValue = 0
    $script:IndentLevel = $InitialValue
    Add-XYZLogIndentLevel
    $script:IndentLevel | Should Be ($InitialValue + 1)
  }

  It 'adds 1 and equals n+1 with initial value n (non-zero)' {
    $InitialValue = 5
    $script:IndentLevel = $InitialValue
    Add-XYZLogIndentLevel
    $script:IndentLevel | Should Be ($InitialValue + 1)
  }

  It 'removes 1 and equals n-1 with initial value n (greater than zero)' {
    $InitialValue = 5
    $script:IndentLevel = $InitialValue
    Remove-XYZLogIndentLevel
    $script:IndentLevel | Should Be ($InitialValue - 1)
  }

  It 'does not remove 1 when starting with value of 0' {
    $InitialValue = 0
    $script:IndentLevel = $InitialValue
    Remove-XYZLogIndentLevel
    $script:IndentLevel | Should Be ($InitialValue)
  }
}
#endregion