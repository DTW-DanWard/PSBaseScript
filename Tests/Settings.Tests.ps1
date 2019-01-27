Set-StrictMode -Version Latest

#region Dot-source Source file associated with this test file
# if no value returned just exit; specific error is already written in Get-SourceScriptFilePath call
. (Join-Path -Path $PSScriptRoot -ChildPath Get-SourceScriptFilePath.ps1)
$SourceScript = Get-SourceScriptFilePath
if ($null -eq $SourceScript) { exit }
Describe "Re/loading: $SourceScript" { }
. $SourceScript
#endregion


#region Test get settings - specify Path parameter - invalid path value or bad file
Describe 'get settings - specify Path parameter - invalid path value or bad file' {

  BeforeAll {
    $TestSettingsFolder = Join-Path -Path $TestDrive -ChildPath SettingsFolder
    $null = New-Item -ItemType Directory -Path $TestSettingsFolder
  }

  It 'get settings - settings file path invalid' {
    { Get-XYZSettings -Path 'z:\bad\folder' } | Should throw
  }

  It 'get settings - settings file path is a folder' {
    { Get-XYZSettings -Path $TestSettingsFolder } | Should throw
  }

  It 'get settings - settings file does not exist' {
    { Get-XYZSettings -Path (Join-Path -Path $TestSettingsFolder -ChildPath FileNotFound.json) } | Should throw
  }

  It 'get settings - settings file does not have json extension' {
    # create settings file
    $TestSettingsFile = Join-Path -Path $TestSettingsFolder -ChildPath SettingsFile.txt
    "junk text - not important for this test" > $TestSettingsFile
    { Get-XYZSettings -Path $TestSettingsFile } | Should throw
  }

  It 'get settings - settings file is empty' {
    # create empty settings file
    $TestSettingsFile = Join-Path -Path $TestSettingsFolder -ChildPath SettingsFile.json
    " " > $TestSettingsFile
    { Get-XYZSettings -Path $TestSettingsFile } | Should throw
  }

  It 'get settings - settings file does not contain json' {
    # create settings file
    $TestSettingsFile = Join-Path -Path $TestSettingsFolder -ChildPath SettingsFile.json
    "this is not json" > $TestSettingsFile
    { Get-XYZSettings -Path $TestSettingsFile } | Should throw
  }
}
#endregion




# when testing preexisting file, need to make sure using THIS file name


#region Test get settings - file in default location - valid
Describe 'get settings - file in default location - valid' {

  It 'get settings - file in default location - valid' {
    Get-XYZSettings | Should BeOfType [PSCustomObject]
  }
}
#endregion


# asdf not done!
# need tests pa
