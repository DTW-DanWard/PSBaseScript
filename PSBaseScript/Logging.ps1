
# Core logging functionality; functions that use or modify any logging internal variables
# should be located in this script.  Put helper/output functions in Logging-Utils.psm1.

#region Function:
function Invoke-InitializeLogSettings {
  [CmdletBinding()]
  param()
  process {
    # initialize/reset private variables
    [string]$script:HostScriptName = ''

    # defaults for log file
    $script:LogFilePath = $null
    [hashtable]$script:OutFileSettings = @{ Encoding = 'utf8'; Force = $true; Append = $true }
    [string]$script:DefaultLogFileNameFormatString = '{0}_Log_{1:yyyyMMdd_HHmmss}.txt'
    [bool]$script:OutSilent = $false

    # time script started, needed for duration
    $script:StartTime = $null

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


Invoke-InitializeLogSettings


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
.PARAMETER Silent
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
    [switch]$Silent
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

    #region Set OutSilent
    $script:OutSilent = $Silent
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


#region Functions: Write-Log

<#
.SYNOPSIS
Writes content to file and host
.DESCRIPTION
Writes content to file and host.  Special object types (see help for
Confirm-XYZLogSpecialType) will be output in a way that shows the content
as opposed to the Type name.
.PARAMETER Object
Object to write
.PARAMETER NoNewline
Don't write a new line after writing
.EXAMPLE
Write-Log 'hey now'
Writes 'hey now' to console and logs to file, if enabled
.EXAMPLE
Write-Log @{ A=1; B=2 }
Writes this to console (and log, if enabled)
A    1
B    2
#>
function Write-Log {
  #region Function parameters
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $false, ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $false, Position = 1)]
    $Object,
    [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
    [switch]$NoNewline
  )
  #endregion
  process {
    $ObjectToWrite = $null
    if ($null -ne $_) { $ObjectToWrite = $_; }
    elseif ($null -ne $Object) { $ObjectToWrite = $Object; }
    # if nothing passed, return
    else { return }

    # asdf fix

    if ($false) {
      # (Confirm-XYZLogSpecialType $ObjectToWrite) {
      # Write-XYZSpecialTypeToHost @PSBoundParameters
    } else {
      # add space prefix based on indent level
      $ObjectToWrite = ($script:IndentStep * $script:IndentLevel) + $ObjectToWrite.ToString()
      $PSBoundParameters.Object = $ObjectToWrite
      # write to log file in enabled (log file path set to value)
      if ($null -ne $LogFilePath -and $LogFilePath.Trim() -ne '') {
        [hashtable]$Params = @{ InputObject = $ObjectToWrite; FilePath = $LogFilePath } + $OutFileSettings
        $Err = $null
        Out-File @Params -ErrorVariable Err
        if ($? -eq $false) {
          Write-Error -Message "$($MyInvocation.MyCommand.Name):: error occurred in Out-File with parameters: $(Convert-XYZFlattenHashtable $Params) :: $("$Err")"
          return
        }
      }
      #region Write to console window using actual Write-Host cmdlet - if not $OutSilent
      # only write content to console if $OutSilent -eq $false
      if ($script:OutSilent -eq $false) {
        # get reference to the actual cmdlet Write-Host, not our function
        $Cmd = Get-Command -Name 'Write-Host' -CommandType Cmdlet
        & $Cmd @PSBoundParameters
      }
      #endregion
    }
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
Writes script header information to Write-Log
.DESCRIPTION
Writes script header informatino to Write-Log including script
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
    Write-Log ' '
    [string]$FormatString = "{0,-$HeaderFooterCol1Width}{1}"
    Write-Log $($HeaderFooterBarChar * $HeaderFooterBarLength)
    Write-Log $($FormatString -f "Script Name", $HostScriptName)
    Write-Log $($FormatString -f "Log file", $LogFilePath)
    Write-Log $($FormatString -f "Machine", $env:COMPUTERNAME)
    Write-Log $($FormatString -f "User", ($env:USERDOMAIN + "\" + $env:USERNAME))
    Write-Log $($FormatString -f "Start time", $StartTime)

    Write-Log $($HeaderFooterBarChar * $HeaderFooterBarLength)
    #endregion
    #endregion
  }
}


<#
.SYNOPSIS
Writes script footer information to Write-Log
.DESCRIPTION
Writes script footer informatino to Write-Log including script
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
    Write-Log $($HeaderFooterBarChar * $HeaderFooterBarLength)
    Write-Log $($FormatString -f "Script Name", $HostScriptName)
    Write-Log $($FormatString -f "Log file", $LogFilePath)

    $EndTime = Get-Date
    Write-Log $($FormatString -f "End time", $EndTime)
    # determine duration and display
    $Duration = $EndTime - $StartTime
    [string]$DurationDisplay = ''
    if ($Duration.Days -gt 0) { $DurationDisplay += $Duration.Days.ToString() + " days, " }
    if ($Duration.Hours -gt 0) { $DurationDisplay += $Duration.Hours.ToString() + " hours, " }
    if ($Duration.Minutes -gt 0) { $DurationDisplay += $Duration.Minutes.ToString() + " minutes, " }
    if ($Duration.Seconds -gt 0) { $DurationDisplay += $Duration.Seconds.ToString() + " seconds" }
    Write-Log $($FormatString -f "Duration", $DurationDisplay)
    Write-Log $($HeaderFooterBarChar * $HeaderFooterBarLength)
    Write-Log ' '
  }
}
#endregion
