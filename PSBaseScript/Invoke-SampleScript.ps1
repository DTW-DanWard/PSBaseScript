Set-StrictMode -Version Latest

. (Join-Path -Path $PSScriptRoot -ChildPath Encryption.ps1)
. (Join-Path -Path $PSScriptRoot -ChildPath Logging.ps1)
. (Join-Path -Path $PSScriptRoot -ChildPath Settings.ps1)
. (Join-Path -Path $PSScriptRoot -ChildPath Settings_Client.ps1)

Enable-XYZLogFile C:\temp\Logs
Write-XYZLogHeader

$Settings = Get-XYZSettings

if ($null -eq $Settings) {
  Write-XYZLog "No settings, exiting."
  Write-XYZLogFooter
  Disable-XYZLogFile
  return
} else {
  Write-XYZLog "Settings are:"
  Add-XYZLogIndentLevel
  ($Settings | Get-Member -MemberType NoteProperty).Name | ForEach-Object {
    Write-XYZLog ($_)
    Add-XYZLogIndentLevel
    # use string expansion so properties that are arrays (_EncryptedProperties) are properly displayed
    Write-XYZLog "$(($Settings.$_))"
    Remove-XYZLogIndentLevel
  }
  Remove-XYZLogIndentLevel
}

Write-XYZLogFooter
Disable-XYZLogFile
