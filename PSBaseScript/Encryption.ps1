Set-StrictMode -Version Latest

#region Function: Convert-XYZDecryptText

<#
.SYNOPSIS
Decrypts encrypted value - Windows machines only
.DESCRIPTION
Decrypts encrypted value - Windows machines only
.PARAMETER Text
Value to decrypt
.EXAMPLE
Convert-XYZDecryptText <encrypted text value>
<plain text value>
#>
function Convert-XYZDecryptText {
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [ValidateNotNullOrEmpty()]
    [string]$Text = $(throw "$($MyInvocation.MyCommand) : missing parameter Text")
  )
  process {
    # Decrypt ONLY if this IsWindows; PS versions 5 and below are only Windows, 6 has explicit variable
    if (($PSVersionTable.PSVersion.Major -le 5) -or ($true -eq $IsWindows)) {
      Write-Verbose "$($MyInvocation.MyCommand) : Decrypting Text"
      $Text = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR( ($Text | ConvertTo-SecureString) ))
    }
    $Text
  }
}
#endregion


#region Function: Convert-XYZEncryptText

<#
.SYNOPSIS
Encrypts plain text value - Windows machines only
.DESCRIPTION
Encrypts plain text value - Windows machines only
The API used only works on Windows machines (as of PowerShell 6.1)
.PARAMETER Text
Text to encrypt
.EXAMPLE
Convert-XYZEncryptText <plain text value>
<encrypted text value>
#>
function Convert-XYZEncryptText {
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [ValidateNotNullOrEmpty()]
    [string]$Text = $(throw "$($MyInvocation.MyCommand) : missing parameter Text")
  )
  process {
    # Decrypt ONLY if this IsWindows; PS versions 5 and below are only Windows, 6 has explicit variable
    if (($PSVersionTable.PSVersion.Major -le 5) -or ($true -eq $IsWindows)) {
      Write-Verbose "$($MyInvocation.MyCommand) : Encrypting Text"
      $Text = ConvertTo-SecureString -String $Text -AsPlainText -Force | ConvertFrom-SecureString
    }
    $Text
  }
}
#endregion


#region Function: Convert-XYZDecodeText

<#
.SYNOPSIS
Decodes Base64 encoded text
.DESCRIPTION
Decodes Base64 encoded text
.PARAMETER Text
Text to decode
.EXAMPLE
Convert-XYZDecodeText <encoded text value>
<plain text value>
#>
function Convert-XYZDecodeText {
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [ValidateNotNullOrEmpty()]
    [string]$Text = $(throw "$($MyInvocation.MyCommand) : missing parameter Text")
  )
  process {
    [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Text))
  }
}
#endregion


#region Function: Convert-XYZEncodeText

<#
.SYNOPSIS
Encodes plain text value - Base64
.DESCRIPTION
Encodes plain text value - Base64
.PARAMETER Text
Text to encode
.EXAMPLE
Convert-XYZEncodeText <plain text value>
<encoded text value>
#>
function Convert-XYZEncodeText {
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [ValidateNotNullOrEmpty()]
    [string]$Text = $(throw "$($MyInvocation.MyCommand) : missing parameter Text")
  )
  process {
    [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($Text))
  }
}
#endregion
