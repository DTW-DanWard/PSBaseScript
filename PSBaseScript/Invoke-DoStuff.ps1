

. (Join-Path -Path $PSScriptRoot -ChildPath Logging.ps1)

Enable-XYZLogFile C:\temp\Logs
Write-XYZLogHeader

Write-Log "Start: $(Get-Date)"
Add-XYZLogIndentLevel

Write-Log "$(Get-XYZLogFilePath)"

Start-Sleep -sec 5

Add-XYZLogIndentLevel
Write-Log "Hey now!"
Remove-XYZLogIndentLevel
Remove-XYZLogIndentLevel

Write-Log "All done."
Write-XYZLogFooter
Disable-XYZLogFile


# ###############################################

<#

Start Unit testing

Migrate LoggingUtils.psm1

Change -Silent to -Quiet ?

#
In Write-Log, enable Write-PSFSpecialTypeToHost

Write-Log: split up Write-LogToFile  Write-LogToScreen


#>
