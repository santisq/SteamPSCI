# I may've totally stolen this from jborean93 :D
[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('Debug', 'Release')]
    [string]
    $Configuration = 'Debug',

    [Parameter()]
    [ValidateSet('Build', 'Test')]
    [string[]]
    $Task = 'Build'
)

begin {
    Import-Module BuildHelpers
    Set-BuildEnvironment
}

end {
    if ($PSEdition -eq 'Desktop') {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 'Tls12'
    }

    if (Test-Path (Join-Path $PSScriptRoot src)) {
        $dotnetTools = @(dotnet tool list --global) -join "`n"
        if (-not $dotnetTools.Contains('coverlet.console')) {
            Write-Host 'Installing dotnet tool coverlet.console'
            dotnet tool install --global coverlet.console
        }
    }

    $invokeBuildSplat = @{
        Task          = $Task
        File          = (Get-Item ([IO.Path]::Combine($PSScriptRoot, '*.build.ps1'))).FullName
        Configuration = $Configuration
    }
    Invoke-Build @invokeBuildSplat
}
