@{
    RootModule = 'SecureBootstrap.psm1'
    ModuleVersion = '0.1.0'
    GUID = 'a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d'
    Author = 'Anderson Arlotta'
    CompanyName = 'BAX IT SERVICES INC'
    Copyright = '(c) 2025 BAX IT SERVICES INC. All rights reserved.'
    Description = 'A PowerShell module for bootstrapping environments'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        "Write-CursorPromptLog"
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('bootstrap', 'automation', 'powershell')
            ProjectUri = 'https://github.com/your/repo'
            LicenseUri = 'https://opensource.org/licenses/MIT'
            ReleaseNotes = 'Initial commit with basic functionality.'
            Disclaimer = 'This module is part of a commercial automation project. Use at your own risk. Redistribution prohibited without license.'
        }
    }
} 