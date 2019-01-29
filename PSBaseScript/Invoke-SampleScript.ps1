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
  return
} else {
  Write-XYZLog "Start: $(Get-Date)"
  Add-XYZLogIndentLevel
  Write-XYZLog "$(Get-XYZLogFilePath)"
  Add-XYZLogIndentLevel
  Write-XYZLog "Hey now!"
  Remove-XYZLogIndentLevel
  Remove-XYZLogIndentLevel
  Write-XYZLog "All done."
}

Write-XYZLogFooter
Disable-XYZLogFile
