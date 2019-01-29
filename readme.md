
# PSBase Script

PowerShell base script with dependencies and Pester unit testing.  Provides:
* logging;
* settings (with optional encryption on specific properties);
* project scaffolding (script analyzer and pester unit testing).

See Invoke-SampleScript.ps1 for example.  To use configuration need to get settings, then fill in values in file created.  If property should be encrypted, fill in encrypted value in .json property and add property name to _EncryptedProperties.  (To encrypt text use Convert-XYZEncryptText - may need to dot-source file).
