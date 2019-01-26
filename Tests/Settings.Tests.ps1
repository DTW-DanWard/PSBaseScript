Set-StrictMode -Version Latest

#region Dot-source Source file associated with this test file
# if no value returned just exit; specific error is already written in Get-SourceScriptFilePath call
. (Join-Path -Path $PSScriptRoot -ChildPath Get-SourceScriptFilePath.ps1)
$SourceScript = Get-SourceScriptFilePath
if ($null -eq $SourceScript) { exit }
Describe "Re/loading: $SourceScript" { }
. $SourceScript
#endregion


#region Test get settings - errors with SettingsFilePath
Describe 'get settings - errors with SettingsFilePath' {

  BeforeAll {
    $TestSettingsFolder = Join-Path -Path $TestDrive -ChildPath SettingsFolder
    $null = New-Item -ItemType Directory -Path $TestSettingsFolder
  }

  It 'get settings - settings file path invalid' {
    { Get-XYZSettings -SettingsFilePath 'z:\bad\folder' } | Should throw
  }

  It 'get settings - settings file path is a folder' {
    { Get-XYZSettings -SettingsFilePath $TestSettingsFolder } | Should throw
  }

  It 'get settings - settings file does not exist' {
    { Get-XYZSettings -SettingsFilePath (Join-Path -Path $TestSettingsFolder -ChildPath FileNotFound.json) } | Should throw
  }

  It 'get settings - settings file does not have json extension' {
    # create settings file
    $TestSettingsFile = Join-Path -Path $TestSettingsFolder -ChildPath SettingsFile.txt
    "junk text - not important for this test" > $TestSettingsFile
    { Get-XYZSettings -SettingsFilePath $TestSettingsFile } | Should throw
  }

  It 'get settings - settings file is empty' {
    # create settings file
    $TestSettingsFile = Join-Path -Path $TestSettingsFolder -ChildPath SettingsFile.json
    " " > $TestSettingsFile
    { Get-XYZSettings -SettingsFilePath $TestSettingsFile } | Should throw
  }

  It 'get settings - settings file does not contain json' {
    # create settings file
    $TestSettingsFile = Join-Path -Path $TestSettingsFolder -ChildPath SettingsFile.json
    "this is not json" > $TestSettingsFile
    { Get-XYZSettings -SettingsFilePath $TestSettingsFile } | Should throw
  }
}
#endregion
