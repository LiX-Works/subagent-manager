#requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Executable,
    [Parameter(Mandatory)][string]$ProxyUri,
    [string[]]$CliArgs = @(),
    [string]$NoProxy = 'localhost,127.0.0.1,::1',
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$parsedProxy = $null
if (-not [Uri]::TryCreate($ProxyUri, [UriKind]::Absolute, [ref]$parsedProxy) -or
    $parsedProxy.Scheme -notin @('http', 'https') -or
    [string]::IsNullOrWhiteSpace($parsedProxy.Host) -or
    $parsedProxy.UserInfo) {
    throw 'Use an absolute HTTP(S) proxy URL without embedded credentials; replace PORT with the actual local port number.'
}

$command = Get-Command -Name $Executable -CommandType Application -ErrorAction Stop |
    Select-Object -First 1
if (-not $command) { throw 'Executable not found.' }

if ($DryRun) {
    [pscustomobject]@{
        executable = $command.Source
        proxy = $parsedProxy.AbsoluteUri
        no_proxy = $NoProxy
        arguments = $CliArgs
        executed = $false
    } | ConvertTo-Json -Depth 4
    return
}

$names = @('HTTP_PROXY', 'HTTPS_PROXY', 'NO_PROXY', 'ALL_PROXY')
$previous = @{}
foreach ($name in $names) {
    $previous[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
}

$exitCode = 0
try {
    [Environment]::SetEnvironmentVariable('HTTP_PROXY', $parsedProxy.AbsoluteUri, 'Process')
    [Environment]::SetEnvironmentVariable('HTTPS_PROXY', $parsedProxy.AbsoluteUri, 'Process')
    [Environment]::SetEnvironmentVariable('NO_PROXY', $NoProxy, 'Process')
    [Environment]::SetEnvironmentVariable('ALL_PROXY', $null, 'Process')
    & $command.Source @CliArgs
    if ($LASTEXITCODE -is [int]) { $exitCode = $LASTEXITCODE }
} finally {
    foreach ($name in $names) {
        [Environment]::SetEnvironmentVariable($name, $previous[$name], 'Process')
    }
}

$global:LASTEXITCODE = $exitCode
if ($exitCode -ne 0) {
    throw "CLI exited with code $exitCode."
}
