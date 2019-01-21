
# Core logging functionality; functions that use or modify any logging internal variables
# should be located in this script.  Put helper/output functions in Logging-Utils.psm1.

function Initialize {
  [CmdletBinding()]
  param()
  process {
    # initialize/reset private variables
    [string]$script:HostScriptName = ''

    # defaults for log file
    [string]$script:LogFilePath = $null
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


Initialize



#region Functions: Disable-XYZLogFile, Enable-XYZLogFile, Get-XYZLogFilePath

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

    # if not currently logging, then just return
    if ((Get-XYZLogFilePath) -eq '') { return }

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

    # set log file path
    $LogFileName = $script:DefaultLogFileNameFormatString -f $script:HostScriptName, $script:StartTime
    $script:LogFilePath = Join-Path -Path $LogFolderPath -ChildPath $LogFileName

    #region Set OutSilent
    $script:OutSilent = $Silent
    #endregion
  }
}


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
    [Parameter(Mandatory = $false,ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $false,Position = 1)]
    $Object,
    [Parameter(Mandatory = $false,ValueFromPipeline = $false)]
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

    if ($false) { # (Confirm-XYZLogSpecialType $ObjectToWrite) {
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
        $Cmd = Get-Command -Name "Write-Host" -CommandType Cmdlet
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
  [CmdletBinding()]
  param()
  #endregion
  process {
    if ($IndentLevel -gt 0) { $script:IndentLevel -= 1 }
  }
}
#endregion
