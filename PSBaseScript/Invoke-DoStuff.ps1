

. (Join-Path -Path $PSScriptRoot -ChildPath Logging.ps1)

Enable-XYZLogFile C:\temp\Logs

# asdf enable
# Write-XYZLogHeader


Write-Log "Start: $(Get-Date)"
Add-XYZLogIndentLevel

Write-Log "$(Get-XYZLogFilePath)"

Add-XYZLogIndentLevel
Write-Log "Hey now!"
Remove-XYZLogIndentLevel
Remove-XYZLogIndentLevel

Write-Log "All done."

# asdf enable
# Write-XYZLogFooter
# Disable-XYZLogFile


# ###############################################

<#

Start Unit testing

Migrate LoggingUtils.psm1

# 
In Write-Log, enable Write-PSFSpecialTypeToHost

Write-Log: split up Write-LogToFile  Write-LogToScreen


#>
