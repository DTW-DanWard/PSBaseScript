Set-StrictMode -Version Latest

#region Dot-source Source file associated with this test file
# if no value returned just exit; specific error is already written in Get-SourceScriptFilePath call
. (Join-Path -Path $PSScriptRoot -ChildPath Get-SourceScriptFilePath.ps1)
$SourceScript = Get-SourceScriptFilePath
if ($null -eq $SourceScript) { exit }
Describe "Re/loading: $SourceScript" { }
. $SourceScript
#endregion


#region Test enable logging
Describe 'test enable logging' {
  Context 'test enable logging when logging enabled (quiet = false) - API' {
    BeforeAll {
      [DateTime]$TimeBeforeTest = Get-Date
      Invoke-InitializeLogSettings
      # because using API, this must be an actual folder that exists
      $TestLogFolderPath = Join-Path -Path $TestDrive -ChildPath TestLogFolder
      $null = New-Item -Path $TestLogFolderPath -ItemType Directory
      Enable-XYZLogFile -LogFolderPath $TestLogFolderPath
    }

    It 'StartTime is not null' {
      $script:StartTime | Should Not BeNullOrEmpty
    }

    It 'StartTime is a DateTime object' {
      $script:StartTime | Should BeOfType [DateTime]
    }

    It 'StartTime more recent than time at beginning of test' {
      $script:StartTime | Should BeGreaterThan $TimeBeforeTest
    }

    It 'HostScriptName is name of test script' {
      $script:HostScriptName | Should Be (Split-Path -Path $PSCommandPath -Leaf)
    }

    It 'indent level is 0' {
      $script:IndentLevel | Should Be 0
    }

    It 'log file path - not null' {
      Get-XYZLogFilePath | Should Not BeNullOrEmpty
    }

    It 'log file path - parent folder matches parameter value' {
      Split-Path -Path (Get-XYZLogFilePath) -Parent | Should Be $TestLogFolderPath
    }

    It 'log file name - file name matches pattern' {
      # see definition of DefaultLogFileNameFormatString variable in Logging.ps1 for more info
      $Regex = (Split-Path -Path $PSCommandPath -Leaf) + '_Log_\d{8}_\d{6}.txt'
      Split-Path -Path (Get-XYZLogFilePath) -Leaf | Should Match $Regex
    }

    It 'log file name - date time stamp in file name is more recent than time at beginning of test' {
      # see definition of DefaultLogFileNameFormatString variable in Logging.ps1 for more info
      $Match = (Get-XYZLogFilePath) -match '.*_Log_(?<Year>\d{4})(?<Month>\d{2})(?<Day>\d{2})_(?<Hour>\d{2})(?<Minute>\d{2})(?<Second>\d{2}).txt$'
      $DateInFileName = Get-Date -Year $Matches.Year -Month $Matches.Month -Day $Matches.Day -Hour $Matches.Hour -Minute $Matches.Minute -Second $Matches.Second
      $script:StartTime | Should BeGreaterThan $TimeBeforeTest
    }

    It 'OutSilent is false' {
      $script:OutSilent | Should Be $false
    }
  }
}
#endregion



#region Test disable logging
Describe 'test disable logging' {
  Context 'test disable logging when logging not originally enabled' {
    BeforeAll {
      Invoke-InitializeLogSettings
      Disable-XYZLogFile
    }

    It 'indent level is 0' {
      $script:IndentLevel | Should Be 0
    }

    It 'log file path is null' {
      Get-XYZLogFilePath | Should BeNullOrEmpty
    }
  }

  Context 'test disable logging when logging enabled - direct' {
    BeforeAll {
      Invoke-InitializeLogSettings
      # because setting directly, this can be a file - or any value not null - but doesn't need to exist
      $TestLogFilePath = Join-Path -Path $TestDrive -ChildPath TestLogFile.txt
      $script:LogFilePath = $TestLogFilePath
      $TestIndentLevel = 5
      $script:IndentLevel = $TestIndentLevel
      Disable-XYZLogFile
    }

    It 'indent level is 0' {
      $script:IndentLevel | Should Be 0
    }

    It 'log file path is null' {
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

    It 'indent level is 0' {
      $script:IndentLevel | Should Be 0
    }

    It 'log file path is null' {
      Get-XYZLogFilePath | Should BeNullOrEmpty
    }
  }
}
#endregion


#region Test get log file path
Describe 'get log file path' {
  It 'gets uninitialized log file path value of null - direct' {
    $script:LogFilePath = $null
    Get-XYZLogFilePath | Should BeNullOrEmpty
  }

  It 'gets uninitialized log file path value of null - API' {
    Invoke-InitializeLogSettings
    Get-XYZLogFilePath | Should BeNullOrEmpty
  }

  It 'gets initialized log file path - direct' {
    $TestLogFilePath = 'c:\Temp\LogFile.txt'
    $script:LogFilePath = $TestLogFilePath
    Get-XYZLogFilePath | Should Be $TestLogFilePath
  }

  Context 'gets initialized log file path - API' {
    BeforeAll {
      Invoke-InitializeLogSettings
      # because using API, this must be an actual folder that exists
      $TestLogFolderPath = Join-Path -Path $TestDrive -ChildPath TestLogFolder
      $null = New-Item -Path $TestLogFolderPath -ItemType Directory
      Enable-XYZLogFile -LogFolderPath $TestLogFolderPath
    }

    It 'gets log file path - not null' {
      Get-XYZLogFilePath | Should Not BeNullOrEmpty
    }

    It 'gets log file path - file name matches exactly' {
      # fetch directly
      $TestLogFilePath = $script:LogFilePath
      Get-XYZLogFilePath | Should Be $TestLogFilePath
    }
    # for additional log file path tests see the test enable logging section
  }
}
#endregion


#region Test add/remove indent level
Describe 'add and remove indent level' {
  It 'adds 1 and equals 1 with initial default value 0 - direct' {
    $TestIndentLevel = 0
    $script:IndentLevel = $TestIndentLevel
    Add-XYZLogIndentLevel
    $script:IndentLevel | Should Be ($TestIndentLevel + 1)
  }

  It 'adds 1 and equals 1 with initial default value 0 - API' {
    Invoke-InitializeLogSettings
    Add-XYZLogIndentLevel
    $script:IndentLevel | Should Be 1
  }

  It 'adds 1 and equals n+1 with initial value n (non-zero) - direct' {
    $TestIndentLevel = 5
    $script:IndentLevel = $TestIndentLevel
    Add-XYZLogIndentLevel
    $script:IndentLevel | Should Be ($TestIndentLevel + 1)
  }

  It 'adds 1 and equals n+1 with initial value n (non-zero) - API' {
    $TestIndentLevel = 5
    Invoke-InitializeLogSettings
    # get indent level set to non-zero value
    for ($i = 1; $i -le $TestIndentLevel; $i++) { Add-XYZLogIndentLevel }
    # now run a single increment, should be 1 higher
    Add-XYZLogIndentLevel
    $script:IndentLevel | Should Be ($TestIndentLevel + 1)
  }

  It 'removes 1 and equals n-1 with initial value n (greater than zero) - direct' {
    $TestIndentLevel = 5
    $script:IndentLevel = $TestIndentLevel
    Remove-XYZLogIndentLevel
    $script:IndentLevel | Should Be ($TestIndentLevel - 1)
  }

  It 'removes 1 and equals n-1 with initial value n (greater than zero) - API' {
    $TestIndentLevel = 5
    Invoke-InitializeLogSettings
    # get indent level set to non-zero value
    for ($i = 1; $i -le $TestIndentLevel; $i++) { Add-XYZLogIndentLevel }
    # now run a single decrement, should be 1 lower
    Remove-XYZLogIndentLevel
    $script:IndentLevel | Should Be ($TestIndentLevel - 1)
  }

  It 'does not remove 1 with initial value of 0 - direct' {
    $TestIndentLevel = 0
    $script:IndentLevel = $TestIndentLevel
    Remove-XYZLogIndentLevel
    $script:IndentLevel | Should Be ($TestIndentLevel)
  }

  It 'does not remove 1 with initial value of 0 - API' {
    Invoke-InitializeLogSettings
    Remove-XYZLogIndentLevel
    $script:IndentLevel | Should Be 0
  }
}
#endregion