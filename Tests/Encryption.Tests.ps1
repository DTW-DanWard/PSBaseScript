Set-StrictMode -Version Latest

#region Dot-source Source file associated with this test file
# if no value returned just exit; specific error is already written in Get-SourceScriptFilePath call
. (Join-Path -Path $PSScriptRoot -ChildPath Get-SourceScriptFilePath.ps1)
$SourceScript = Get-SourceScriptFilePath
if ($null -eq $SourceScript) { exit }
Describe "Re/loading: $SourceScript" { }
. $SourceScript
#endregion



#region Encryption - encrypt and decrypt (integration: Dan's machine for consistent encrypt/decrypt values)
Describe -Tag 'Integration' 'encrypt and decrypt tests (native Windows functionality)' {

  BeforeAll {
    $script:SkipTest = @{}
    if (($PSVersionTable.PSVersion.Major -ge 6) -and ($false -eq $IsWindows)) {
      $script:SkipTest = @{ Skip = $true}
    }
  }

  It 'encrypting without text input is error' {
    { Convert-XYZEncryptText } | Should throw
  }

  # note: this will not work on non-Windows machines
  It @SkipTest 'encrypted text is different than text input' {
    $TestPlainText = 'ThisIsSampleText'
    Convert-XYZEncryptText -Text $TestPlainText | Should Not Be $TestPlainText
  }

  It 'decrypting without text input is error' {
    { Convert-XYZDecryptText } | Should throw
  }

  It 'encrypting then decrypting text produces same text' {
    $TestPlainText = 'ThisIsSampleText'
    Convert-XYZDecryptText -Text (Convert-XYZEncryptText -Text $TestPlainText) | Should Be $TestPlainText
  }
}
#endregion


#region Encode and decode
Describe 'encode and decode' {

  It 'encoding without text input is error' {
    { Convert-XYZEncodeText } | Should throw
  }

  It 'encoded text is different than text input' {
    $TestPlainText = 'ThisIsSampleText'
    Convert-XYZEncodeText -Text $TestPlainText | Should Not Be $TestPlainText
  }

  It 'encoding produces expected text' {
    $TestPlainText = 'ThisIsSampleText'
    $TestEncodedText = 'VABoAGkAcwBJAHMAUwBhAG0AcABsAGUAVABlAHgAdAA='
    Convert-XYZEncodeText -Text $TestPlainText | Should Be $TestEncodedText
  }

  It 'decoding without text input is error' {
    { Convert-XYZEncodeText } | Should throw
  }

  It 'encoding then decoding text produces same text' {
    $TestPlainText = 'ThisIsSampleText'
    Convert-XYZDecodeText -Text (Convert-XYZEncodeText -Text $TestPlainText) | Should Be $TestPlainText
  }
}
#endregion
