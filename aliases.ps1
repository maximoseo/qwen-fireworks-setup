# =============================================================
# Qwen CLI — PowerShell Aliases
# Source this file from your $PROFILE:
#   . "$env:USERPROFILE\qwen-fireworks-setup\aliases.ps1"
# Or copy the contents directly into your profile.
# =============================================================

# q — launch an interactive Qwen session
Set-Alias -Name q -Value qwen

# qa — quick one-shot ask (non-interactive)
#   Usage: qa "What does git rebase -i do?"
function qa {
    param(
        [Parameter(Mandatory, Position = 0, ValueFromRemainingArguments)]
        [string[]]$Prompt
    )
    qwen -p "$Prompt"
}

# qc — coding task with expert software engineer context
#   Usage: qc "Write a binary search in TypeScript with type hints."
function qc {
    param(
        [Parameter(Mandatory, Position = 0, ValueFromRemainingArguments)]
        [string[]]$Prompt
    )
    qwen -p "You are an expert software engineer. $Prompt"
}
