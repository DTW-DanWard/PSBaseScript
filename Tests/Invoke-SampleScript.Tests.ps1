
Set-StrictMode -Version Latest

#region Get source file path - don't run
# if no value returned just exit; specific error is already written in Get-SourceScriptFilePath call
. (Join-Path -Path $PSScriptRoot -ChildPath Get-SourceScriptFilePath.ps1)
$SourceScript = Get-SourceScriptFilePath
if ($null -eq $SourceScript) { exit }
#endregion


#region Test flatten hash table utility
Describe 'call basic script' {

  It 'basic script' {
    # capture/suppress the console output so it doesn't clutter the host
    $null = . $SourceScript 6>&1
  }
}
#endregion
