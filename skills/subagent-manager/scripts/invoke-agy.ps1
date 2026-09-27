#requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$PromptFile,
    [Parameter(Mandatory)][string]$Workspace,
    [Parameter(Mandatory)][string]$OutputDirectory,
    [string]$Executable = 'agy',
    [string]$Model = 'gemini-3.8-flash-high',
    [ValidateSet('low','medium','high')][string]$Effort = 'high',
    [ValidateSet('plan','accept-edits')][string]$Mode = 'plan',
    [ValidateRange(1,7200)][int]$TimeoutSeconds = 180,
    [AllowEmptyString()][string]$ProxyUri = '',
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
$agentCommand = Get-Command -Name $Executable -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
if (!$agentCommand) { throw 'AGY executable not found; use -Executable or add it to PATH. No installation or login attempted.' }
$agentExe = $agentCommand.Source
$inputPath = (Resolve-Path -LiteralPath $PromptFile).Path
$workPath = (Resolve-Path -LiteralPath $Workspace).Path
if (!(Test-Path -LiteralPath $workPath -PathType Container)) { throw 'Workspace must be an existing task directory.' }
$outputPath = [IO.Path]::GetFullPath($OutputDirectory)
if ((Test-Path -LiteralPath $outputPath) -and (!(Test-Path -LiteralPath $outputPath -PathType Container) -or @(Get-ChildItem -LiteralPath $outputPath -Force).Count -gt 0)) { throw 'Output directory must be new or empty. Existing results will not be overwritten.' }
$promptText = [IO.File]::ReadAllText($inputPath,[Text.Encoding]::UTF8)
if ([string]::IsNullOrWhiteSpace($promptText)) { throw 'Empty prompt.' }
# A named variant must agree with the explicit effort; avoid ambiguous backend precedence.
if ($Model -match '-(low|medium|high)$' -and $Matches[1] -ne $Effort) { throw 'Model suffix and Effort disagree.' }
if ($promptText.Length -gt 22000) { throw 'Prompt exceeds conservative Windows argument budget. Use a concise prompt pointing to authorized files in the workspace.' }
if ($ProxyUri) {
    $parsedProxy = [Uri]$ProxyUri
    if ($parsedProxy.Scheme -notin @('http','https') -or $parsedProxy.UserInfo) { throw 'Use an HTTP(S) proxy URL without credentials.' }
}
$summary = [ordered]@{requested_model=$Model;requested_effort=$Effort;mode=$Mode;workspace=$workPath;output_directory=$outputPath;timeout_seconds=$TimeoutSeconds;explicit_proxy=[bool]$ProxyUri}
if ($DryRun) { $summary | ConvertTo-Json; return }
New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
$psi = [Diagnostics.ProcessStartInfo]::new()
$psi.FileName=$agentExe; $psi.WorkingDirectory=$workPath
$psi.UseShellExecute=$false; $psi.CreateNoWindow=$true
$psi.RedirectStandardOutput=$true; $psi.RedirectStandardError=$true
$psi.StandardOutputEncoding=[Text.Encoding]::UTF8; $psi.StandardErrorEncoding=[Text.Encoding]::UTF8
foreach($argValue in @('--model',$Model,'--effort',$Effort,'--mode',$Mode,'--sandbox','--disable-slash-commands','--output-format','json','--print-timeout',"${TimeoutSeconds}s",'-p',$promptText)) { $psi.ArgumentList.Add($argValue) }
# Reuse native OAuth. Do not forward optional API-key environment overrides.
foreach($keyName in @('GEMINI_API_KEY','GOOGLE_API_KEY')) { [void]$psi.Environment.Remove($keyName) }
if($ProxyUri){
    foreach($keyName in @('HTTP_PROXY','HTTPS_PROXY','http_proxy','https_proxy','ALL_PROXY','all_proxy')) { [void]$psi.Environment.Remove($keyName) }
    $psi.Environment['HTTP_PROXY']=$ProxyUri;$psi.Environment['HTTPS_PROXY']=$ProxyUri
    $psi.Environment['NO_PROXY']='localhost,127.0.0.1,::1'
}
$timer=[Diagnostics.Stopwatch]::StartNew()
$proc=[Diagnostics.Process]::new();$proc.StartInfo=$psi
$didTimeout=$false;$exitCode=$null;$response=$null;$usage=$null;$providerStatus=$null;$parseOk=$false;$stderrChars=0
try {
    [void]$proc.Start()
    $stdoutTask=$proc.StandardOutput.ReadToEndAsync();$stderrTask=$proc.StandardError.ReadToEndAsync()
    if(!$proc.WaitForExit(($TimeoutSeconds+10)*1000)){$didTimeout=$true;$proc.Kill($true);[void]$proc.WaitForExit(5000)}
    if(!$proc.HasExited){throw 'Owned process did not exit after timeout termination.'}
    $exitCode=$proc.ExitCode
    # Bounded drain: descendant processes can otherwise keep redirected pipes open.
    $drained=[Threading.Tasks.Task]::WaitAll([Threading.Tasks.Task[]]@($stdoutTask,$stderrTask),5000)
    if($drained){
        $raw=$stdoutTask.Result;$stderrChars=$stderrTask.Result.Length
        try {
            $obj=ConvertFrom-Json -InputObject $raw -ErrorAction Stop
            $response=$obj.response;$usage=$obj.usage;$providerStatus=$obj.status
            $parseOk=$response -is [string]
        } catch { $parseOk=$false }
    }
} finally { $proc.Dispose() }
$summary.wall_seconds=[Math]::Round($timer.Elapsed.TotalSeconds,2)
$summary.exit_code=$exitCode;$summary.timed_out=$didTimeout;$summary.provider_status=$providerStatus
$summary.parsed_response=$parseOk;$summary.stderr_characters=$stderrChars;$summary.usage=$usage
$summary.success=(!$didTimeout -and $exitCode -eq 0 -and $parseOk -and $providerStatus -eq 'SUCCESS')
$summary | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath (Join-Path $outputPath 'result.json') -Encoding utf8
if($parseOk){[IO.File]::WriteAllText((Join-Path $outputPath 'answer.txt'),$response,[Text.UTF8Encoding]::new($false))}
$summary | ConvertTo-Json -Depth 12
if(!$summary.success){throw 'AGY task did not pass execution checks; inspect non-sensitive result.json. No automatic retry or account switch was attempted.'}
