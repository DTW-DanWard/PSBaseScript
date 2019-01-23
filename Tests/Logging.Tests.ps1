Set-StrictMode -Version Latest

#region Dot-source Source file associated with this test file
# if no value returned just exit; specific error is already written in Get-SourceScriptFilePath call
. (Join-Path -Path $PSScriptRoot -ChildPath Get-SourceScriptFilePath.ps1)
$SourceScript = Get-SourceScriptFilePath
if ($null -eq $SourceScript) { exit }
Describe "Re/loading: $SourceScript" { }
. $SourceScript
#endregion



#region Test disable logging
Describe 'test disable logging' {
  Context 'test disable logging when logging not originally enabled' {
    BeforeAll { 
      Invoke-InitializeLogSettings
      Disable-XYZLogFile
    }

    It 'test indent level is 0' {
      $script:IndentLevel | Should Be 0
    }

    It 'test log file path is null' {
      Get-XYZLogFilePath | Should BeNullOrEmpty
    }
  }

  Context 'test disable logging when logging enabled - direct' {
    BeforeAll { 
      Invoke-InitializeLogSettings
      # because setting directly, this can be a file - or just anything not null
      $TestLogFilePath = Join-Path -Path $TestDrive -ChildPath TestLogFile.txt
      $script:LogFilePath = $TestLogFilePath
      $TestIndentLevel = 5
      $script:IndentLevel = $TestIndentLevel
      Disable-XYZLogFile
    }

    It 'test indent level is 0' {
      $script:IndentLevel | Should Be 0
    }

    It 'test log file path is null' {
      Get-XYZLogFilePath | Should BeNullOrEmpty
    }
  }

  Context 'test disable logging when logging enabled - API' {
    BeforeAll { 
      Invoke-InitializeLogSettings
      # because using API, this must be an actual folder that exists
      $TestLogFolderPath = Join-Path -Path $TestDrive -ChildPath TestLogFolder
      $null = New-Item -Path $TestLogFolderPath -ItemType Directory
      Disable-XYZLogFile
    }

    It 'test indent level is 0' {
      $script:IndentLevel | Should Be 0
    }

    It 'test log file path is null' {
      Get-XYZLogFilePath | Should BeNullOrEmpty
    }
  }
}
#endregion




#region Test get log file path
Describe 'get log file path' {
  It 'gets uninitialized log file path value of null' {
    $script:LogFilePath = $null
    Get-XYZLogFilePath | Should BeNullOrEmpty
  }

  It 'gets initialized log file path' {
    $TestLogFilePath = 'c:\Temp\LogFile.txt'
    $script:LogFilePath = $TestLogFilePath
    Get-XYZLogFilePath | Should Be $TestLogFilePath
  }
}
#endregion


#region Test add/remove indent level
Describe 'add and remove indent level' {
  It 'adds 1 and equals 1 with initial default value 0' {
    $TestIndentLevel = 0
    $script:IndentLevel = $TestIndentLevel
    Add-XYZLogIndentLevel
    $script:IndentLevel | Should Be ($TestIndentLevel + 1)
  }

  It 'adds 1 and equals n+1 with initial value n (non-zero)' {
    $TestIndentLevel = 5
    $script:IndentLevel = $TestIndentLevel
    Add-XYZLogIndentLevel
    $script:IndentLevel | Should Be ($TestIndentLevel + 1)
  }

  It 'removes 1 and equals n-1 with initial value n (greater than zero)' {
    $TestIndentLevel = 5
    $script:IndentLevel = $TestIndentLevel
    Remove-XYZLogIndentLevel
    $script:IndentLevel | Should Be ($TestIndentLevel - 1)
  }

  It 'does not remove 1 with initial value of 0' {
    $TestIndentLevel = 0
    $script:IndentLevel = $TestIndentLevel
    Remove-XYZLogIndentLevel
    $script:IndentLevel | Should Be ($TestIndentLevel)
  }
}
#endregion