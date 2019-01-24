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

  Context 'test enable logging; SuppressHostOutput = false - API' {

    BeforeAll {
      [DateTime]$script:TimeBeforeTest = Get-Date
      Initialize-XYZLogSettings
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

    It 'log file name - date time stamp in file name matches StartTime' {
      # see definition of DefaultLogFileNameFormatString variable in Logging.ps1 for more info
      $null = (Get-XYZLogFilePath) -match '.*_Log_(?<Year>\d{4})(?<Month>\d{2})(?<Day>\d{2})_(?<Hour>\d{2})(?<Minute>\d{2})(?<Second>\d{2}).txt$'
      $DateInFileName = Get-Date -Year $Matches.Year -Month $Matches.Month -Day $Matches.Day -Hour $Matches.Hour -Minute $Matches.Minute -Second $Matches.Second
      # comparing as strings (which has date + hour:minue:seconds) so no issues with milliseconds not matching
      $DateInFileName.ToString() | Should Be $script:StartTime.ToString()
    }

    It 'SuppressHostOutput is false' {
      $script:SuppressHostOutput | Should Be $false
    }
  }

  Context 'test enable logging; SuppressHostOutput = true - API' {
    BeforeAll {
      Initialize-XYZLogSettings
      # because using API, this must be an actual folder that exists
      $TestLogFolderPath = Join-Path -Path $TestDrive -ChildPath TestLogFolder
      $null = New-Item -Path $TestLogFolderPath -ItemType Directory
      Enable-XYZLogFile -LogFolderPath $TestLogFolderPath -NoHostOutput
    }

    # not repeating all other tests from SuppressHostOutput = false above, code path is exact same

    It 'SuppressHostOutput is true' {
      $script:SuppressHostOutput | Should Be $true
    }
  }

  Context 'test enable logging with bad log folder path value - API' {

    It 'folder does not exist' {
      Initialize-XYZLogSettings
      $TestLogFolderPath = Join-Path -Path $TestDrive -ChildPath TestLogFolder
      # don't create this folder!
      { Enable-XYZLogFile -LogFolderPath $TestLogFolderPath } | Should throw
    }

    It 'drive does not exist' {
      Initialize-XYZLogSettings
      { Enable-XYZLogFile -LogFolderPath 'z:\bad\folder' } | Should throw
    }

    It 'path is real file, not a folder' {
      Initialize-XYZLogSettings
      # create file with some text
      $TestLogFolderPath = Join-Path -Path $TestDrive -ChildPath TestFile.txt
      "some text" > $TestLogFolderPath
      { Enable-XYZLogFile -LogFolderPath $TestLogFolderPath } | Should throw
    }
  }
}
#endregion


#region Test disable logging
Describe 'test disable logging' {

  Context 'test disable logging when logging not originally enabled' {

    BeforeAll {
      Initialize-XYZLogSettings
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
      Initialize-XYZLogSettings
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
      Initialize-XYZLogSettings
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
    Initialize-XYZLogSettings
    Get-XYZLogFilePath | Should BeNullOrEmpty
  }

  It 'gets initialized log file path - direct' {
    $TestLogFilePath = 'c:\Temp\LogFile.txt'
    $script:LogFilePath = $TestLogFilePath
    Get-XYZLogFilePath | Should Be $TestLogFilePath
  }

  Context 'gets initialized log file path - API' {
    BeforeAll {
      Initialize-XYZLogSettings
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


#region Test write log entries
Describe 'test write log entries' {

  BeforeAll {
    Initialize-XYZLogSettings
    # because using API, this must be an actual folder that exists
    $TestLogFolderPath = Join-Path -Path $TestDrive -ChildPath TestLogFolder
    $null = New-Item -Path $TestLogFolderPath -ItemType Directory
  }

  Context 'test single log file with one log - API' {

    BeforeAll {
      # this is the first log file to be created
      Enable-XYZLogFile $TestLogFolderPath
      $LogFileContent = "sample text"
      # when writing logs without specifying NoHostOutput we'll capture/suppress the console output so it doesn't clutter the host
      $null = Write-XYZLog -Content $LogFileContent 6>&1
      Disable-XYZLogFile
    }

    It 'test only 1 file exists' {
      (Get-ChildItem -Path $TestLogFolderPath -Recurse | Measure-Object).Count | Should Be 1
    }

    It 'test log file has correct content' {
      # only 1 file should exist
      (Get-ChildItem -Path $TestLogFolderPath).FullName | Should FileContentMatch $LogFileContent
    }
  }

  Context 'test single log file with one log, pipeline input - API' {

    BeforeAll {
      # this is the first log file to be created
      Enable-XYZLogFile $TestLogFolderPath
      $LogFileContent = "sample text"
      # when writing logs without specifying NoHostOutput we'll capture/suppress the console output so it doesn't clutter the host
      $null = $LogFileContent | Write-XYZLog 6>&1
      Disable-XYZLogFile
    }

    It 'test only 1 file exists' {
      (Get-ChildItem -Path $TestLogFolderPath -Recurse | Measure-Object).Count | Should Be 1
    }

    It 'test log file has correct content' {
      # only 1 file should exist
      (Get-ChildItem -Path $TestLogFolderPath).FullName | Should FileContentMatch $LogFileContent
    }
  }

  Context 'test single log file with one log, NoHostOutput - API' {

    BeforeAll {
      # this is the first log file to be created
      Enable-XYZLogFile $TestLogFolderPath -NoHostOutput
      $LogFileContent = "sample text"
      # because we specified NoHostOutput we'll capture the console output BUT there shouldn't be any
      $script:ConsoleOutput = Write-XYZLog -Content $LogFileContent 6>&1
      Disable-XYZLogFile
    }

    It 'test no console output' {
      # only 1 file should exist
      $ConsoleOutput | Should BeNullOrEmpty
    }
  }

  Context 'test error thrown by bad Out-File parameters - API/direct' {

    It 'test bad log folder path' {
      # in order to force this error, we have to hack a bit, in this case we'll override
      # the $script:LogFilePath value to something bad after it's been set via Enable-XYZLogFile
      # in order to bypass the validation in Enable; we'll set it back at the end of the test

      # capture correct log folder path before tests
      $Temp = $TestLogFolderPath
      # enable with valid value
      Enable-XYZLogFile $TestLogFolderPath
      # now set bad log folder path
      $script:LogFilePath = 'z:\bad\folder'
      $LogFileContent = "sample text"
      # attempting to Write-XYZLog should throw error
      { Write-XYZLog -Content $LogFileContent 6>&1 } | Should throw
      Disable-XYZLogFile
      # reset value back
      $script:LogFilePath = $Temp
    }
  }
}
#endregion


#region Test write log header & footer
Describe 'test write log header & footer' {

  BeforeAll {
    Initialize-XYZLogSettings
    $TestLogFolderPath = Join-Path -Path $TestDrive -ChildPath TestLogFolder
    $null = New-Item -Path $TestLogFolderPath -ItemType Directory
  }

  Context 'test write log header - API' {

    BeforeAll {
      Enable-XYZLogFile $TestLogFolderPath -NoHostOutput
      Write-XYZLogHeader
      Disable-XYZLogFile
    }

    It 'test Script name present in header' {
      (Get-ChildItem -Path $TestLogFolderPath).FullName | Should FileContentMatch ('Script name +' + (Split-Path -Path $PSCommandPath -Leaf))
    }

    It 'test Log file present in header' {
      (Get-ChildItem -Path $TestLogFolderPath).FullName | Should FileContentMatch ('Log file +' + (Get-XYZLogFilePath))
    }

    It 'test Machine present in header' {
      (Get-ChildItem -Path $TestLogFolderPath).FullName | Should FileContentMatch ('Machine +' + $env:COMPUTERNAME)
    }

    It 'test User present in header' {
      (Get-ChildItem -Path $TestLogFolderPath).FullName | Should FileContentMatch ('User +' + ($env:USERDOMAIN + "\\" + $env:USERNAME))
    }

    It 'test Start time present in header' {
      (Get-ChildItem -Path $TestLogFolderPath).FullName | Should FileContentMatch ('Start time +' + ($script:StartTime.ToString()))
    }
  }

  Context 'test write log footer, normal duration - API' {

    BeforeAll {
      Enable-XYZLogFile $TestLogFolderPath -NoHostOutput
      # need slight delay so Duration value exists
      $SecondsDelay = 2
      Start-Sleep -Seconds $SecondsDelay
      Write-XYZLogFooter
      Disable-XYZLogFile
    }

    It 'test Script name present in footer' {
      (Get-ChildItem -Path $TestLogFolderPath).FullName | Should FileContentMatch ('Script name +' + (Split-Path -Path $PSCommandPath -Leaf))
    }

    It 'test Log file present in footer' {
      (Get-ChildItem -Path $TestLogFolderPath).FullName | Should FileContentMatch ('Log file +' + (Get-XYZLogFilePath))
    }

    It 'test End time present in footer' {
      (Get-ChildItem -Path $TestLogFolderPath).FullName | Should FileContentMatch ('End time +' + ($script:EndTime.ToString()))
    }

    It 'test Duration present in footer' {
      (Get-ChildItem -Path $TestLogFolderPath).FullName | Should FileContentMatch ('Duration +' + $SecondsDelay + ' seconds')
    }
  }

  Context 'test write log footer, long duration - direct' {

    BeforeAll {
      Enable-XYZLogFile $TestLogFolderPath -NoHostOutput
      # we want to test the logic that puts together the duration text in the footer; this text
      # specifies durations as:  W days, X hours, Y minutes, Z seconds
      # but of course we won't put in a delay that is days long so we'll override the start time

      # would be better to have larger values below but if so there's a chance the start time
      # subtractions will affect the next unit up (-10 minutes affects the hours, etc.)
      $DaysDelay = 1
      $HoursDelay = 1
      $MinutesDelay = 1
      $SecondsDelay = 1

      $NewStartTime = $script:StartTime
      $script:StartTime = $NewStartTime.AddDays(-$DaysDelay).AddHours(-$HoursDelay).AddMinutes(-$MinutesDelay).AddSeconds(-$SecondsDelay)
      Write-XYZLogFooter
      Disable-XYZLogFile
    }

    It 'test Duration present in footer' {
      (Get-ChildItem -Path $TestLogFolderPath).FullName | Should FileContentMatch ("Duration + $DaysDelay days, $HoursDelay hours, $MinutesDelay minutes, $SecondsDelay seconds")
    }
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
    Initialize-XYZLogSettings
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
    Initialize-XYZLogSettings
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
    Initialize-XYZLogSettings
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
    Initialize-XYZLogSettings
    Remove-XYZLogIndentLevel
    $script:IndentLevel | Should Be 0
  }
}
#endregion


#region Test flatten hash table utility
Describe 'flatten hashtable' {

  # note the spacing differences and key sorting between the hashtable definition and the output
  It 'flattens simple hashtable - parameter' {
    Convert-XYZFlattenHashtable -HT @{A=1; B=2} | Should Be '@{ A = 1 ; B = 2 }'
  }

  It 'flattens simple hashtable - pipeline' {
    @{A=1; B=2} | Convert-XYZFlattenHashtable | Should Be '@{ A = 1 ; B = 2 }'
  }

  It 'flattens nested hashtable' {
    # C and D should be sorted alphabetically
    Convert-XYZFlattenHashtable -HT @{A=1;B=@{D=4;C=3}} | Should Be '@{ A = 1 ; B = @{ C = 3 ; D = 4 } }'
  }

  It 'flattens ordered dictionary, keeping initial key order' {
    # C and D should be sorted alphabetically
    Convert-XYZFlattenHashtable -HT ([ordered]@{C=1;B=2;D=3;A=4}) | Should Be '@{ C = 1 ; B = 2 ; D = 3 ; A = 4 }'
  }
}
#endregion
