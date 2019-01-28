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

  It 'get settings - settings file path invalid' {
    Mock -CommandName 'Get-XYZSettingsDefaultFilePath' -MockWith { 'z:\bad\folder' }
    { Get-XYZSettings } | Should throw
  }

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


#region Test get settings - no file exists in default location - create correctly
Describe 'get settings - no file exists in default location - create correctly' {

  BeforeAll {
    $TestSettingsFolder = Join-Path -Path $TestDrive -ChildPath SettingsFolder
    $null = New-Item -ItemType Directory -Path $TestSettingsFolder
    $TestSettingsFile = (Split-Path ($MyInvocation.PSCommandPath) -Leaf) -replace '\.ps1$','.json'
    $TestSettingsFile = Join-Path -Path $TestSettingsFolder -ChildPath $TestSettingsFile
    Mock -CommandName 'Get-XYZSettingsDefaultFilePath' -MockWith { $TestSettingsFile }

    # 'mock'ing these but not using Mock - throws exception CommandNotFoundException: Could not find Command
    # as they are in a different file
    function Get-XYZSettingsPropertiesPlaintext { @('Url','UserName') }
    function Get-XYZSettingsPropertiesEncrypted { ,@('Password') }
  }

  AfterEach {
    # settings file does not exist before any tests; it is created within each test so
    # delete AFTER EACH test to ensure tests OK, (or could do this with separate Contexts so
    # Pester cleans TestDrive: automatically, but that leads to a lot of duplication of setup code)
    if (Test-Path -Path $TestSettingsFile) { Remove-Item -Path $TestSettingsFile -Force }
  }

  It 'file does not exist before' {
    Test-Path -Path $TestSettingsFile | Should Be $false
  }

  It 'file gets created after' {
    Mock -CommandName 'Get-XYZSettingsPropertiesPlaintext' -MockWith { @('Url','UserName') }
    $null = Get-XYZSettings 6>&1
    Test-Path -Path $TestSettingsFile | Should Be $true
  }

  It 'information about new settings file is output to host' {
    [object[]]$Output = Get-XYZSettings 6>&1
    $Output.Count | Should Be 3
  }

  It 'output information includes path to settings file' {
    [object[]]$Output = Get-XYZSettings 6>&1
    $Output[1] | Should Be $TestSettingsFile
  }

  It 'new settings file has DEFAULT values' {
    # first time calling this works - creates file with default values
    # second time calling throws error because default values have not been edited
    $null = Get-XYZSettings 6>&1
    { Get-XYZSettings } | Should throw
  }
}
#endregion


#region Test get settings - file exists in default location - valid
Describe 'get settings - file exists in default location - valid' {

  BeforeAll {
    $TestValue = 'TESTTEST'
    $TestSettingsFolder = Join-Path -Path $TestDrive -ChildPath SettingsFolder
    $null = New-Item -ItemType Directory -Path $TestSettingsFolder
    $Settings = [PSCustomObject]@{
      Prop1 = $TestValue
      Prop2 = $TestValue
    }
    $TestSettingsFile = (Split-Path ($MyInvocation.PSCommandPath) -Leaf) -replace '\.ps1$','.json'
    $TestSettingsFile = Join-Path -Path $TestSettingsFolder -ChildPath $TestSettingsFile
    $Settings | ConvertTo-Json -Depth 100 | Out-File -FilePath $TestSettingsFile
    Mock -CommandName 'Get-XYZSettingsDefaultFilePath' -MockWith { $TestSettingsFile }
  }

  It 'returns settings object' {
    Get-XYZSettings | Should BeOfType [PSCustomObject]
  }

  It 'settings object property has test value' {
    (Get-XYZSettings).Prop1 | Should Be $TestValue
  }

  It 'get settings object does not produce Write-Host output because file exists' {
    # if file didn't exist would produce multiple lines of content and first test for
    # PSCustomObject would fail as object produced would be an array with 3 items
    ([object[]](Get-XYZSettings 6>&1)).Count | Should Be 1
  }
}
#endregion
