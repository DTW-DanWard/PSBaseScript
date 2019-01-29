Set-StrictMode -Version Latest

if ($false -eq (Test-Path -Path variable:Default)) {
  Set-Variable Default -Value 'DEFAULT' -Option ReadOnly -Scope Script
}


#region Function: Convert-XYZDecryptSettingsProperties

<#
.SYNOPSIS
For settings object decrypts any encrypted properties
.DESCRIPTION
For settings object decrypts any encrypted properties.  Finds list of encrypted
properties on property _EncryptedProperties.
.PARAMETER Settings
Settings object
.EXAMPLE
Convert-XYZDecryptSettingsProperties $Settings
<returns settings object with decrypted properties>
#>
function Convert-XYZDecryptSettingsProperties {
  #region Function parameters
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [PSCustomObject]$Settings
  )
  #endregion
  process {
    $Settings._EncryptedProperties | ForEach-Object {
      # explicitly try/catch so can throw terminating exception
      try { $Settings.$_ = Convert-XYZDecryptText -Text $Settings.$_ }
      catch { throw $_ }
    }
    $Settings
  }
}
#endregion


#region Function: Get-XYZSettings

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
      New-XYZSettingsObject | ConvertTo-Json -Depth 100 | Out-File -FilePath $SettingsFilePath
      Write-Host 'New settings file written to: ' -NoNewline
      Write-Host $SettingsFilePath -ForegroundColor Cyan
      Write-Host 'Edit this file, replacing every DEFAULT value with correct one.'
    } else {
      # settings file exists, validate it
      # ensure path is a file not a folder
      if ($false -eq (Test-Path -Path $SettingsFilePath -PathType Leaf)) { throw "Settings file Path is a folder, not a file: $SettingsFilePath" }
      # ensure file extension is .json
      if (((Get-Item -Path $SettingsFilePath).Extension) -ne $JsonExtension) { throw "Settings file Path should have .json extension: $SettingsFilePath" }
      # ensure file is not empty
      $SettingsContent = Get-Content -Path $SettingsFilePath -Raw
      if ($null -eq $SettingsContent -or ($SettingsContent.Trim()) -eq '') { throw "Settings file is empty: $SettingsFilePath" }
      # ensure converting from json to object does not throw exception; if file does not contain valid json convert will throw error
      $Settings = ConvertFrom-Json -InputObject $SettingsContent
      # ensure user has filled in correct values in settings (no DEFAULT values)
      Get-Member -InputObject $Settings -MemberType NoteProperty | Where-Object { $Settings.($_.Name) -eq $Default } | Select-Object Name | ForEach-Object {
        throw "Settings file property '$($_.Name)' is still set to $Default in: $SettingsFilePath"
      }
      # got this far with no errors? decrypt any encrypted properties on Settings and return
      Convert-XYZDecryptSettingsProperties -Settings $Settings
    }
  }
}
#endregion


#region Function: Get-XYZSettingsDefaultFilePath

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
    $CallingScriptPath -replace '\.ps1$', '.json'
  }
}
#endregion


#region Function: New-XYZSettingsObject

<#
.SYNOPSIS
Returns settings object with default value for each property value
.DESCRIPTION
Returns settings object with DEFAULT value for each property value.  Properties are created
for every item appearing in Get-XYZSettingsPropertiesPlaintext and Get-XYZSettingsPropertiesEncrypted.
Encrypted property names are also listed in a property named _EncryptedProperties.
Encrypted property values are NOT encrypted at this time; they are only encrypted when stored in
the file.
.EXAMPLE
New-XYZSettingsObject
<returns PSObject with properties>
#>
function New-XYZSettingsObject {
  #region Function parameters
  [CmdletBinding(supportsshouldprocess)]
  param()
  #endregion
  process {
    if ($PSCmdlet.ShouldProcess("This should process")) {
      $Settings = [ordered]@{}
      # create property for each property name with value of DEFAULT
      (Get-XYZSettingsPropertiesPlaintext) + (Get-XYZSettingsPropertiesEncrypted) | ForEach-Object {
        $Settings.$_ = $Default
      }
      # also add list of encrypted property names
      $Settings._EncryptedProperties = Get-XYZSettingsPropertiesEncrypted
      # convert hashtable to PSObject and return
      [PSCustomObject]$Settings
    }
  }
}
#endregion
