# Test-GitIgnore.ps1
# Validates that .gitignore contains all SecureByDefault-required entries

$expectedEntries = @(
    ".vscode/",
    "*.log",
    "*.zip",
    "*.tmp",
    "*.bak",
    "*.DS_Store"
)

Describe ".gitignore structure" {
    Context "Required patterns" {
        $gitignore = Get-Content "../../.gitignore" -ErrorAction Stop
        foreach ($entry in $expectedEntries) {
            It "contains $entry" {
                $gitignore -contains $entry | Should -BeTrue
            }
        }
    }
}































