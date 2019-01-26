Set-StrictMode -Version Latest

#region Dot-source Source file associated with this test file
# if no value returned just exit; specific error is already written in Get-SourceScriptFilePath call
. (Join-Path -Path $PSScriptRoot -ChildPath Get-SourceScriptFilePath.ps1)
$SourceScript = Get-SourceScriptFilePath
if ($null -eq $SourceScript) { exit }
Describe "Re/loading: $SourceScript" { }
. $SourceScript
#endregion


#region Test default settings properties values
Describe 'settings properties values' {

  It 'plaintext properties exist' {
    Get-XYZSettingsPropertiesPlaintext | Should Not BeNullOrEmpty
  }

  It 'encrypted properties might exist' {
    (Get-XYZSettingsPropertiesEncrypted).Count | Should BeGreaterThan -1
  }
}
#endregion
