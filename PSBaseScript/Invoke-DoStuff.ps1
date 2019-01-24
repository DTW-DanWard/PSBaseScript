

. (Join-Path -Path $PSScriptRoot -ChildPath Logging.ps1)

Enable-XYZLogFile C:\temp\Logs
Write-XYZLogHeader

Write-XYZLog "Start: $(Get-Date)"
Add-XYZLogIndentLevel

Write-XYZLog "$(Get-XYZLogFilePath)"

Start-Sleep -sec 5

Add-XYZLogIndentLevel
Write-XYZLog "Hey now!"
Remove-XYZLogIndentLevel
Remove-XYZLogIndentLevel

Write-XYZLog "All done."
Write-XYZLogFooter
Disable-XYZLogFile


