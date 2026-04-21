# Qwen CLI + Fireworks AI — Setup & Usage Guide

> **Model:** `qwen3p6-plus` (Qwen3.6 Plus) via Fireworks AI  
> **Shell:** PowerShell 7 on Windows  
> **CLI version:** `qwen-code` v0.14.5

---

## Overview

[Qwen Code](https://github.com/QwenLM/qwen-code) is an open-source AI agent that runs in your terminal. This guide configures it to use **Fireworks AI** as the inference backend with **Qwen3.6 Plus** as the default model — a hybrid thinking model capable of chain-of-thought reasoning and direct answers.

---

## Prerequisites

- Node.js 18+ (for `npm`)
- PowerShell 7+
- A [Fireworks AI](https://fireworks.ai) account and API key

---

## Installation

### 1. Install Qwen CLI

```powershell
npm install -g @qwen-code/qwen-code
qwen --version   # should print 0.14.5 or later
```

### 2. Configure the Provider

Create (or edit) `~/.qwen/settings.json`:

```json
{
  "modelProviders": {
    "openai": [
      {
        "id": "accounts/fireworks/models/qwen3p6-plus",
        "name": "Qwen3.6 Plus (Fireworks AI)",
        "baseUrl": "https://api.fireworks.ai/inference/v1",
        "description": "Qwen3.6 Pro via Fireworks AI",
        "envKey": "FIREWORKS_API_KEY"
      }
    ]
  },
  "env": {
    "FIREWORKS_API_KEY": "<your-fireworks-api-key>"
  },
  "security": {
    "auth": {
      "selectedType": "openai"
    }
  },
  "model": {
    "name": "accounts/fireworks/models/qwen3p6-plus"
  }
}
```

> ⚠️ Replace `<your-fireworks-api-key>` with your key from [fireworks.ai/account/api-keys](https://fireworks.ai/account/api-keys).  
> The key is stored in plaintext — do not commit `settings.json` to version control.

---

## Shell Aliases

Add the following to your PowerShell profile (`$PROFILE` → `Documents\PowerShell\Microsoft.PowerShell_profile.ps1`):

```powershell
# Qwen CLI (Fireworks AI - qwen3p6-plus)
# q   → launch interactive Qwen session
# qa  → quick one-shot ask (non-interactive)
# qc  → quick coding task with reasoning enabled
Set-Alias -Name q -Value qwen

function qa {
    param(
        [Parameter(Mandatory, Position=0, ValueFromRemainingArguments)]
        [string[]]$Prompt
    )
    qwen -p "$Prompt"
}

function qc {
    param(
        [Parameter(Mandatory, Position=0, ValueFromRemainingArguments)]
        [string[]]$Prompt
    )
    qwen -p "You are an expert software engineer. $Prompt"
}
```

Reload your profile to activate:

```powershell
. $PROFILE
```

---

## Usage

### Interactive mode

```powershell
q        # or: qwen
```

Opens a full interactive session. Use `/model` to switch models and `/help` for all slash commands.

### Quick ask (non-interactive)

```powershell
qa "What does git rebase -i do?"
qa "Explain the CAP theorem in two sentences."
```

### Coding task with reasoning

```powershell
qc "Write a binary search implementation in TypeScript with type hints."
qc "Implement a thread-safe LRU cache in Python."
qc "Explain the difference between TCP and UDP with a code example."
```

### Direct `qwen` flags

```powershell
qwen -p "Your prompt"          # non-interactive, print output
qwen --model <model-id>        # override model for this run
```

---

## About Qwen3.6 Plus (Thinking Model)

Qwen3.6 Plus is a **hybrid thinking model**. It has two modes:

| Mode | Behaviour | Best for |
|---|---|---|
| **Thinking** (default) | Generates internal chain-of-thought before answering | Complex reasoning, math, coding architecture |
| **No-think** | Skips reasoning, answers directly | Simple lookups, fast responses |

When calling the API directly, control the mode via `reasoning_effort`:

```powershell
# Thinking mode (default) — more accurate, uses more tokens
$body = @{ ...; reasoning_effort = "high" }

# No-think mode — faster and cheaper
$body = @{ ...; reasoning_effort = "none" }
```

> The Qwen CLI manages token budgets automatically — thinking mode works out of the box in interactive and `-p` usage.

---

## API Verification

Quick PowerShell test to verify connectivity without the CLI:

```powershell
$headers = @{
    "Authorization" = "Bearer $env:FIREWORKS_API_KEY"
    "Content-Type"  = "application/json"
}
$body = @{
    model            = "accounts/fireworks/models/qwen3p6-plus"
    messages         = @(@{ role = "user"; content = "Ping!" })
    max_tokens       = 10
    reasoning_effort = "none"
} | ConvertTo-Json -Depth 3

$r = Invoke-RestMethod -Uri "https://api.fireworks.ai/inference/v1/chat/completions" `
     -Method POST -Headers $headers -Body $body
Write-Host "Model: $($r.model)"
Write-Host "Reply: $($r.choices[0].message.content)"
```

---

## Available Fireworks Models

Other Qwen models available on Fireworks (add to `modelProviders` as needed):

| Model ID | Description |
|---|---|
| `accounts/fireworks/models/qwen3p6-plus` | **Qwen3.6 Plus** — default, hybrid thinking |
| `accounts/fireworks/models/qwen3-coder-480b-a35b-instruct` | Qwen3 Coder 480B — large coding model |
| `accounts/fireworks/models/qwen3-235b-a22b` | Qwen3 235B MoE — frontier-scale |
| `accounts/fireworks/models/qwen2p5-coder-32b-instruct` | Qwen2.5 Coder 32B — fast coding |

Browse the full list at [fireworks.ai/models](https://fireworks.ai/models?providers=Qwen).

---

## Troubleshooting

### Empty reply from model
Qwen3.6 Plus uses tokens for internal reasoning first. If `max_tokens` is too small, content will be `null`. Either increase `max_tokens` or set `reasoning_effort = "none"` for simple tasks. The CLI handles this automatically.

### `qwen` not found
Ensure npm global bin is on your `PATH`:
```powershell
npm config get prefix   # e.g. C:\Users\seoadmin\AppData\Roaming\npm
```
Add the result to your `$env:PATH` in `$PROFILE` if missing.

### API key errors
Confirm the key is valid at [fireworks.ai/account/api-keys](https://fireworks.ai/account/api-keys) and matches the value in `~/.qwen/settings.json`.

---

## File Locations

| File | Purpose |
|---|---|
| `~/.qwen/settings.json` | Provider config, API key, default model |
| `$PROFILE` | PowerShell aliases (`q`, `qa`, `qc`) |
