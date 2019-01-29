Set-StrictMode -Version Latest

#region Get source file path - don't run
# if no value returned just exit; specific error is already written in Get-SourceScriptFilePath call
. (Join-Path -Path $PSScriptRoot -ChildPath Get-SourceScriptFilePath.ps1)
$SourceScript = Get-SourceScriptFilePath
if ($null -eq $SourceScript) { exit }
#endregion


#region Call basic script - use default settings file found
Describe 'call basic script' {

  It 'basic script - default settings file' {
    # capture/suppress the console output so it doesn't clutter the host
    $null = . $SourceScript 6>&1
  }
}
#endregion


#region Call basic script - no settings file
Describe 'call basic script - no settings file' {

  BeforeAll {
    # rename settings file if exists
    $SettingsFile = $SourceScript -replace '\.ps1$', '.json'
    $SettingsFileBackup = $SettingsFile + '.backup'
    if ($true -eq (Test-Path -Path $SourceScript)) {
      Rename-Item -Path $SettingsFile -NewName $SettingsFileBackup
    }
    Write-Host "FILE RENAMED!" -ForegroundColor Cyan
    Start-Sleep -Seconds 4
  }

  AfterAll {
    # after done, rename back to normal setting
    $SettingsFile = $SourceScript -replace '\.ps1$', '.json'
    $SettingsFileBackup = $SettingsFile + '.backup'
    if ($true -eq (Test-Path -Path $SettingsFileBackup)) {
      Remove-Item -Path $SettingsFile
      Rename-Item -Path $SettingsFileBackup -NewName $SettingsFile
    }
  }

  It 'basic script - no settings file' {
    # capture/suppress the console output so it doesn't clutter the host
    $null = . $SourceScript 6>&1
  }
}
#endregion
