Set-StrictMode -Version Latest

. (Join-Path -Path $PSScriptRoot -ChildPath Logging.ps1)
. (Join-Path -Path $PSScriptRoot -ChildPath Settings.ps1)

Get-XYZSettings C:\code\GitHub\PSBaseScript\PSBaseScript\Invoke-SampleScript.json

Enable-XYZLogFile C:\temp\Logs
Write-XYZLogHeader

Write-XYZLog "Start: $(Get-Date)"
Add-XYZLogIndentLevel
Write-XYZLog "$(Get-XYZLogFilePath)"
Add-XYZLogIndentLevel
Write-XYZLog "Hey now!"
Remove-XYZLogIndentLevel
Remove-XYZLogIndentLevel
Write-XYZLog "All done."

Write-XYZLogFooter
Disable-XYZLogFile


