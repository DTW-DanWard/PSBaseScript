Set-StrictMode -Version Latest

#region Functions: Get-XYZSettings

<#
.SYNOPSIS
Returns settings object, initializes object and creates file if doesn't exist
.DESCRIPTION
Returns settings object, initializes object and creates file if doesn't exist.
.PARAMETER Path
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
    # if path passed, some initial validation here; much more below
    [ValidateScript( {if ($null -ne $_) {Test-Path -Path $_ -PathType Leaf}} )]
    $Path
  )
  #endregion
  process {
    $JsonExtension = '.json'
    $Settings = $null

    # need separte variable for $SettingsFilePath as validation on $Path parameter impacts create default path value
    $SettingsFilePath = $Path

    # if file path passed we use that; if no file path passed check if file exists in the
    # default location (same folder as invoking script - not this one, which might be in a
    # library folder - and the file name is name of script with .json extension, not .ps1)
    if ($null -eq $SettingsFilePath) {
      $SettingsFilePath = Join-Path -Path $MyInvocation.PSScriptRoot -ChildPath ((Get-Item -Path $MyInvocation.PSCommandPath).BaseName + $JsonExtension)
    }

    if ($false -eq (Test-Path -Path $SettingsFilePath)) {
      Write-Host "Create settings file, display user message, return null settings: $SettingsFilePath"
      $Settings
      return
    }

    #region If settings file already exists, validate it
    #region Validation rules:
    # - path is a file not a folder;
    # - file extension is .json;
    # - file is not empty;
    # - converting from json to object does not throw exception.
    #endregion
    if ($null -ne $SettingsFilePath) {
      if ($false -eq (Test-Path -Path $SettingsFilePath -PathType Leaf)) { throw "Settings file Path is a folder, not a file: $SettingsFilePath" }
      if (((Get-Item -Path $SettingsFilePath).Extension) -ne $JsonExtension) { throw "Settings file Path should have .json extension: $SettingsFilePath" }
      $SettingsContent = Get-Content -Path $SettingsFilePath -Raw
      if ($null -eq $SettingsContent -or ($SettingsContent.Trim()) -eq '') { throw "Settings file is empty: $SettingsFilePath" }
      # if file does not contain valid json convert will throw error
      ConvertFrom-Json -InputObject $SettingsContent
      return
    }
    #endregion



    # at this point, either valid settings file passed or no file specified in parameter
    # so if no file passed,


  }
}
#endregion

