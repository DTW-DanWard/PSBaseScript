Set-StrictMode -Version Latest

#region Dot-source Source file associated with this test file
# if no value returned just exit; specific error is already written in Get-SourceScriptFilePath call
. (Join-Path -Path $PSScriptRoot -ChildPath Get-SourceScriptFilePath.ps1)
$SourceScript = Get-SourceScriptFilePath
if ($null -eq $SourceScript) { exit }
Describe "Re/loading: $SourceScript" { }
. $SourceScript
#endregion



#region Test get settings default file path
Describe 'get settings default file path' {

  It 'invalid path - no .ps1 extension' {
    { Get-XYZSettingsDefaultFilePath -CallingScriptPath (Join-Path -Path $TestDrive -ChildPath File.txt) } | Should throw
  }

  It 'valid path' {
    Get-XYZSettingsDefaultFilePath -CallingScriptPath (Join-Path -Path $TestDrive -ChildPath File.ps1) | Should BeOfType [string]
  }
}
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


#region Test get settings - do NOT specify Path parameter - invalid path value or bad file
Describe 'get settings - do NOT specify Path parameter - invalid path value or bad file' {

  BeforeAll {
    $TestSettingsFolder = Join-Path -Path $TestDrive -ChildPath SettingsFolder
    $null = New-Item -ItemType Directory -Path $TestSettingsFolder
  }

  # # asdf - reenable this once create default file attempts to run
  # It 'get settings - settings file path invalid' {
  #   Mock -CommandName 'Get-XYZSettingsDefaultFilePath' -MockWith { 'z:\bad\folder' }
  #   { Get-XYZSettings } | Should throw
  # }

  It 'get settings - settings file path is a folder' {
    Mock -CommandName 'Get-XYZSettingsDefaultFilePath' -MockWith { $TestSettingsFolder }
    { Get-XYZSettings } | Should throw
  }

  # can't test 'settings file does not exist' copied from test section 'specify Path parameter' and expect error
  # that is an OK situation; create a file in that case

  It 'get settings - settings file does not have json extension' {
    # create settings file
    $TestSettingsFile = Join-Path -Path $TestSettingsFolder -ChildPath SettingsFile.txt
    "junk text - not important for this test" > $TestSettingsFile
    Mock -CommandName 'Get-XYZSettingsDefaultFilePath' -MockWith { $TestSettingsFile }
    { Get-XYZSettings } | Should throw
  }

  It 'get settings - settings file is empty' {
    # create empty settings file
    $TestSettingsFile = Join-Path -Path $TestSettingsFolder -ChildPath SettingsFile.json
    " " > $TestSettingsFile
    Mock -CommandName 'Get-XYZSettingsDefaultFilePath' -MockWith { $TestSettingsFile }
    { Get-XYZSettings } | Should throw
  }

  It 'get settings - settings file does not contain json' {
    # create settings file
    $TestSettingsFile = Join-Path -Path $TestSettingsFolder -ChildPath SettingsFile.json
    "this is not json" > $TestSettingsFile
    Mock -CommandName 'Get-XYZSettingsDefaultFilePath' -MockWith { $TestSettingsFile }
    { Get-XYZSettings } | Should throw
  }
}
#endregion








# #region Test get settings - do not specify Path parameter - invalid path value or bad file
# Describe 'get settings - do not specify Path parameter - invalid path value or bad file' {

#   BeforeAll {
#     $TestSettingsFolder = Join-Path -Path $TestDrive -ChildPath SettingsFolder
#     $null = New-Item -ItemType Directory -Path $TestSettingsFolder
#   }

#   It 'get settings - settings file path invalid' {
#     { Get-XYZSettings -Path 'z:\bad\folder' } | Should throw
#   }
# }
# #endregion



# when testing preexisting file, need to make sure using THIS file name


# asdf FIX THIS ONCE CAN MOCK!
# throw "Settings file Path is a folder, not a file: $SettingsFilePath"
# test case: there is a folder with name of setting file (including json file) in that preexisting location


#region Test get settings - file in default location - valid
Describe 'get settings - file in default location - valid' {

  It 'get settings - file in default location - valid' {
    Get-XYZSettings | Should BeOfType [PSCustomObject]
  }
}
#endregion


# asdf not done!
# need tests pa
