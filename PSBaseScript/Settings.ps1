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

    # need separte variable for $SettingsFilePath as validation on $Path parameter impacts create default path value
    $SettingsFilePath = $Path

    # if file path passed we use that; if no file path passed check if file exists in the
    # default location (same folder as invoking script - not this one, which might be in a
    # library folder - and the file name is name of script with .json extension, not .ps1)
    if ($null -eq $SettingsFilePath) {
      $SettingsFilePath = Get-XYZSettingsDefaultFilePath -CallingScriptPath $MyInvocation.PSCommandPath
    }

    # if settings file doesn't exist, create default file and display message to user
    if ($false -eq (Test-Path -Path $SettingsFilePath)) {
      # asdf update
      Write-Host "Create settings file, display user message, return null settings: $SettingsFilePath"
    } else {

      # settings file exists, validate it
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
      }
    }

  }
}
#endregion


#region Functions: Get-XYZSettingsDefaultFilePath

<#
.SYNOPSIS
Returns default file path for settings file
.DESCRIPTION
Returns default file path for settings file.  Replaces $CallingScriptPath .ps1 extension
with .json.  $CallingScriptPath should be passed $MyInvocation.PSCommandPath
.PARAMETER CallingScriptPath
Full path to calling script, i.e. $MyInvocation.PSCommandPath
.EXAMPLE
Get-XYZSettingsDefaultFilePath $MyInvocation.PSCommandPath
C:\Code\GitHub\PSBaseScript\PSBaseScript\Invoke-SampleScript.json
#>
function Get-XYZSettingsDefaultFilePath {
  #region Function parameters
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateScript( {$_ -match '\.ps1$'} )]
    [string]$CallingScriptPath
  )
  #endregion
  process {
    $CallingScriptPath -replace '\.ps1$','.json'
  }
}
#endregion
