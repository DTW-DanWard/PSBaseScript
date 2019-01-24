
# Logging functionality

#region Function: Initialize-XYZLogSettings

<#
.SYNOPSIS
Initializes log settings
.DESCRIPTION
Initializes script-level log settings to default/null values.
.EXAMPLE
Initialize-XYZLogSettings
<resets log settings>
#>
function Initialize-XYZLogSettings {
  [CmdletBinding()]
  param()
  process {
    # initialize/reset private variables
    [string]$script:HostScriptName = ''

    # defaults for log file
    $script:LogFilePath = $null
    [hashtable]$script:OutFileSettings = @{ Encoding = 'utf8'; Force = $true; Append = $true }
    [string]$script:DefaultLogFileNameFormatString = '{0}_Log_{1:yyyyMMdd_HHmmss}.txt'
    [bool]$script:SuppressHostOutput = $false

    # start/end time
    $script:StartTime = $null
    $script:EndTime = $null

    # two spaces for an index
    [string]$script:IndentStep = '  '
    # start with no indent level
    [int]$script:IndentLevel = 0

    [int]$script:HeaderFooterCol1Width = 18
    [int]$script:HeaderFooterBarLength = 85
    [string]$script:HeaderFooterBarChar = '#'
  }
}
#endregion


Initialize-XYZLogSettings


#region Functions: Disable-XYZLogFile, Enable-XYZLogFile

<#
.SYNOPSIS
Turns off file logging
.DESCRIPTION
Turns off file logging.
.EXAMPLE
Disable-XYZLogFile
Disables file logging
#>
function Disable-XYZLogFile {
  #region Function parameters
  [CmdletBinding()]
  param()
  #endregion
  process {
    # make sure log level is reset
    $script:IndentLevel = 0

    # turn off file logging by setting path to null
    $script:LogFilePath = $null
  }
}


<#
.SYNOPSIS
Enables file logging, writing content to new file under specified folder
.DESCRIPTION
Enables file logging with a specific folder.  A new log file will be created under the
specified folder with the calling script name as the prefix and a date/time stamp as
the file suffix.
Folder MUST exist!
.PARAMETER LogFolderPath
Path of log folder for storing log files - folder MUST exist!
.PARAMETER NoHostOutput
Do not write information to console, just to log file.
.EXAMPLE
Enable-XYZLogFile c:\Temp\Logs
#>
function Enable-XYZLogFile {
  #region Function parameters
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateScript( {Test-Path -Path $_ -PathType Container})]
    $LogFolderPath,
    [switch]$NoHostOutput
  )
  #endregion
  process {
    # set start time
    $script:StartTime = Get-Date
    # get parent script name/path
    $script:HostScriptName = Split-Path ($MyInvocation.PSCommandPath) -Leaf

    # make sure log level is reset
    $script:IndentLevel = 0

    # set log file path
    $LogFileName = $script:DefaultLogFileNameFormatString -f $script:HostScriptName, $script:StartTime
    $script:LogFilePath = Join-Path -Path $LogFolderPath -ChildPath $LogFileName

    #region Set SuppressHostOutput
    $script:SuppressHostOutput = $NoHostOutput
    #endregion
  }
}
#endregion


#region Functions: Get-XYZLogFilePath

<#
.SYNOPSIS
Returns the path to the log file
.DESCRIPTION
Returns the path to the log file
.EXAMPLE
Get-XYZLogFilePath
Returns the log file path
#>
function Get-XYZLogFilePath {
  #region Function parameters
  [CmdletBinding()]
  param()
  #endregion
  process {
    $LogFilePath
  }
}
#endregion


#region Functions: Write-XYZLog

<#
.SYNOPSIS
Writes content to file and host
.DESCRIPTION
Writes content to file and host.  Hashtables and ordered dictionaries will be flattened to
a single string displaying all keys & values (not 'System.Collections.Hashtable')
.PARAMETER Content
Content to write
.EXAMPLE
Write-XYZLog 'hey now'
Writes 'hey now' to console and logs to file, if enabled
#>
function Write-XYZLog {
  #region Function parameters
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    $Content
  )
  #endregion
  process {
    # only process if logging properly enabled
    if ($null -eq $LogFilePath) { return }

    $ContentToWrite = $null
    if ($null -ne $_) { $ContentToWrite = $_; }
    elseif ($null -ne $Content) { $ContentToWrite = $Content; }
    # if nothing passed, return
    else { return }

    # add space prefix based on indent level
    $ContentToWrite = ($script:IndentStep * $script:IndentLevel) + $ContentToWrite.ToString()

    # write to console window - if not $SuppressHostOutput
    if ($script:SuppressHostOutput -eq $false) { Write-Host $ContentToWrite }

    # write to log file
    [hashtable]$Params = @{ InputObject = $ContentToWrite; FilePath = $LogFilePath } + $OutFileSettings
    Out-File @Params
  }
}
#endregion


#region Functions: Add-XYZLogIndentLevel, Remove-XYZLogIndentLevel

<#
.SYNOPSIS
Increases the default logging indent level by 1
.DESCRIPTION
Increases the default logging indent level by 1; max is 10
.EXAMPLE
Add-XYZLogIndentLevel
Increases indenting level by 1
#>
function Add-XYZLogIndentLevel {
  #region Function parameters
  [CmdletBinding()]
  param()
  #endregion
  process {
    if ($IndentLevel -lt 11) { $script:IndentLevel += 1 }
  }
}


<#
.SYNOPSIS
Decreases the default logging indent level by 1
.DESCRIPTION
Decreases the default logging indent level by 1; min is 0
.EXAMPLE
Remove-XYZLogIndentLevel
Decreases indenting level by 1
#>
function Remove-XYZLogIndentLevel {
  #region Function parameters
  [CmdletBinding(supportsshouldprocess)]
  param()
  #endregion
  process {
    if ($PSCmdlet.ShouldProcess("This should process")) {
      if ($IndentLevel -gt 0) { $script:IndentLevel -= 1 }
    }
  }
}
#endregion


#region Functions: Write-XYZLogHeader, Write-XYZLogFooter

<#
.SYNOPSIS
Writes script header information to Write-XYZLog
.DESCRIPTION
Writes script header informatino to Write-XYZLog including script
name and path, machine name, domain/user name and start time.
Additionally displays any information pass in via hashtable parameter.
Information is surrounded with 'bars' of # marks.
.EXAMPLE
Write-XYZLogHeader
Writes the log header with information
#>
function Write-XYZLogHeader {
  #region Function parameters
  [CmdletBinding()]
  param()
  #endregion
  process {
    #region Write header
    Write-XYZLog ' '
    [string]$FormatString = "{0,-$HeaderFooterCol1Width}{1}"
    Write-XYZLog $($HeaderFooterBarChar * $HeaderFooterBarLength)
    Write-XYZLog $($FormatString -f "Script name", $HostScriptName)
    Write-XYZLog $($FormatString -f "Log file", $LogFilePath)
    Write-XYZLog $($FormatString -f "Machine", $env:COMPUTERNAME)
    Write-XYZLog $($FormatString -f "User", ($env:USERDOMAIN + "\" + $env:USERNAME))
    Write-XYZLog $($FormatString -f "Start time", $StartTime)

    Write-XYZLog $($HeaderFooterBarChar * $HeaderFooterBarLength)
    #endregion
    #endregion
  }
}


<#
.SYNOPSIS
Writes script footer information to Write-XYZLog
.DESCRIPTION
Writes script footer informatino to Write-XYZLog including script
name and path and end time.
Information is surrounded with 'bars' of # marks.
.EXAMPLE
Write-XYZLogFooter
Writes the log footer with information
#>
function Write-XYZLogFooter {
  #region Function parameters
  [CmdletBinding()]
  param()
  #endregion
  process {
    [string]$FormatString = "{0,-$HeaderFooterCol1Width}{1}"
    Write-XYZLog $($HeaderFooterBarChar * $HeaderFooterBarLength)
    Write-XYZLog $($FormatString -f "Script name", $HostScriptName)
    Write-XYZLog $($FormatString -f "Log file", $LogFilePath)

    $script:EndTime = Get-Date
    Write-XYZLog $($FormatString -f "End time", $EndTime)
    # determine duration and display
    $Duration = $EndTime - $StartTime
    [string]$DurationDisplay = ''
    if ($Duration.Days -gt 0) { $DurationDisplay += $Duration.Days.ToString() + " days, " }
    if ($Duration.Hours -gt 0) { $DurationDisplay += $Duration.Hours.ToString() + " hours, " }
    if ($Duration.Minutes -gt 0) { $DurationDisplay += $Duration.Minutes.ToString() + " minutes, " }
    if ($Duration.Seconds -gt 0) { $DurationDisplay += $Duration.Seconds.ToString() + " seconds" }
    Write-XYZLog $($FormatString -f "Duration", $DurationDisplay)
    Write-XYZLog $($HeaderFooterBarChar * $HeaderFooterBarLength)
    Write-XYZLog ' '
  }
}
#endregion
