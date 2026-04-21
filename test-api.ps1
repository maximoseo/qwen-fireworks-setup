<#
.SYNOPSIS
    Verify connectivity to the Fireworks AI API and confirm the Qwen3.6 Plus
    model is reachable.

.DESCRIPTION
    Sends a minimal chat completion request with reasoning_effort=none so the
    response is fast and cheap.  Reads the API key from the FIREWORKS_API_KEY
    environment variable or falls back to ~/.qwen/settings.json.

.EXAMPLE
    # Using env var (recommended)
    $env:FIREWORKS_API_KEY = "fw_..."
    .\test-api.ps1

    # Or let the script read from settings.json automatically
    .\test-api.ps1
#>

param(
    [string]$Model = "accounts/fireworks/models/qwen3p6-plus",
    [string]$BaseUrl = "https://api.fireworks.ai/inference/v1"
)

# ── Resolve API key ───────────────────────────────────────────────────────────
$apiKey = $env:FIREWORKS_API_KEY

if (-not $apiKey) {
    $settingsPath = "$env:USERPROFILE\.qwen\settings.json"
    if (Test-Path $settingsPath) {
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
        $apiKey = $settings.env.FIREWORKS_API_KEY
    }
}

if (-not $apiKey -or $apiKey -eq "YOUR_FIREWORKS_API_KEY_HERE") {
    Write-Error "No API key found. Set `$env:FIREWORKS_API_KEY or add it to ~/.qwen/settings.json"
    exit 1
}

# ── Build request ─────────────────────────────────────────────────────────────
$headers = @{
    "Authorization" = "Bearer $apiKey"
    "Content-Type"  = "application/json"
}

$body = @{
    model            = $Model
    messages         = @(@{ role = "user"; content = "Respond with exactly: API OK" })
    max_tokens       = 10
    reasoning_effort = "none"
} | ConvertTo-Json -Depth 3

# ── Send request ──────────────────────────────────────────────────────────────
Write-Host "`nTesting Fireworks AI API..." -ForegroundColor Cyan
Write-Host "  Endpoint : $BaseUrl/chat/completions"
Write-Host "  Model    : $Model`n"

try {
    $response = Invoke-RestMethod `
        -Uri "$BaseUrl/chat/completions" `
        -Method POST `
        -Headers $headers `
        -Body $body `
        -ErrorAction Stop

    $reply         = $response.choices[0].message.content
    $promptTokens  = $response.usage.prompt_tokens
    $outputTokens  = $response.usage.completion_tokens

    Write-Host "  Status   : " -NoNewline
    Write-Host "OK" -ForegroundColor Green
    Write-Host "  Reply    : $reply"
    Write-Host "  Tokens   : $promptTokens prompt / $outputTokens completion`n"
    exit 0
}
catch {
    Write-Host "  Status   : " -NoNewline
    Write-Host "FAILED" -ForegroundColor Red
    Write-Host "  Error    : $($_.Exception.Message)`n"
    if ($_.Exception.Response) {
        $reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        Write-Host "  Body     : $($reader.ReadToEnd())`n"
    }
    exit 1
}
