Set-StrictMode -Version Latest

#region Functions: Get-XYZSettings

<#
.SYNOPSIS
Returns settings object, initializes object and creates file if doesn't exist
.DESCRIPTION
Returns settings object, initializes object and creates file if doesn't exist.
.PARAMETER SettingsFilePath
Full path to settings file - including file name itself
.EXAMPLE
Get-XYZSettings
<PSObject with properties>
#>
function Get-XYZSettings {
  #region Function parameters
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $false)]
    [ValidateScript( {if ($null -ne $_) {Test-Path -Path $_ -PathType Leaf}} )]
    $SettingsFilePath
  )
  #endregion
  process {
    #region Additional parameter validation
    # if settings file passed, ensure:
    #  - file extension is .json
    #  - file is not empty
    #  - converting from json to object does not throw exception
    if ($null -ne $SettingsFilePath) {
      if (((Get-Item -Path $SettingsFilePath).Extension) -ne '.json') { throw "JSON settings file should have .json extension: $SettingsFilePath" }
      if (((Get-Content -Path $SettingsFilePath -Raw).Trim()) -eq '') { throw "Settings file is empty: $SettingsFilePath" }
      # dispose of result, if file does not contain json will throw error
      $null = ConvertFrom-Json -InputObject (Get-Content -Path $SettingsFilePath -Raw)
    }
    #endregion



  }
}
#endregion

