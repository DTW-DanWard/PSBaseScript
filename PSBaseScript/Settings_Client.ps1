Set-StrictMode -Version Latest

#region Functions: Get-XYZSettingsPropertiesPlaintext

<#
.SYNOPSIS
Returns list of settings properties stored in plaintext (not encrypted).
.DESCRIPTION
Returns list of settings properties stored in plaintext (not encrypted).
.EXAMPLE
Get-XYZSettingsPropertiesPlaintext
Url, UserName
#>
function Get-XYZSettingsPropertiesPlaintext {
  #region Function parameters
  [CmdletBinding()]
  [OutputType([System.Array])]
  param()
  #endregion
  process {
    @('Url','UserName')
  }
}
#endregion


#region Functions: Get-XYZSettingsPropertiesEncrypted

<#
.SYNOPSIS
Returns list of settings properties that are stored encrypted
.DESCRIPTION
Returns list of settings properties that are stored encrypted.
.EXAMPLE
Get-XYZSettingsPropertiesEncrypted
Password
#>
function Get-XYZSettingsPropertiesEncrypted {
  #region Function parameters
  [CmdletBinding()]
  [OutputType([System.Array])]
  param()
  #endregion
  process {
    #ensure an array is return - preceed with ,
    ,@('Password')
  }
}
#endregion


