# Instala a orquestracao de agentes como padrao global do Claude Code (Windows).
# Uso: powershell -ExecutionPolicy Bypass -File install.ps1
$ErrorActionPreference = 'Stop'

$Src  = $PSScriptRoot
$Dest = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE '.claude' }
$Stamp  = Get-Date -Format 'yyyyMMdd-HHmmss'
$Backup = Join-Path $Dest "backups\orquestracao-$Stamp"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

New-Item -ItemType Directory -Force -Path (Join-Path $Dest 'agents'), $Backup | Out-Null

# 1) Agents: backup dos que existem com o mesmo nome e copia os novos
Get-ChildItem (Join-Path $Src 'agents\*.md') | ForEach-Object {
    $target = Join-Path $Dest "agents\$($_.Name)"
    if (Test-Path $target) { Copy-Item $target (Join-Path $Backup $_.Name) }
    $text = [IO.File]::ReadAllText($_.FullName, $Utf8NoBom) -replace "`r`n", "`n"
    [IO.File]::WriteAllText($target, $text, $Utf8NoBom)
    Write-Host "agent instalado: $($_.Name)"
}

# 2) CLAUDE.md global: troca so o bloco entre os marcadores, preserva o resto
$ClaudeMd = Join-Path $Dest 'CLAUDE.md'
$existing = ''
if (Test-Path $ClaudeMd) {
    Copy-Item $ClaudeMd (Join-Path $Backup 'CLAUDE.md')
    $existing = [IO.File]::ReadAllText($ClaudeMd, $Utf8NoBom)
}
$existing = [regex]::Replace($existing, '(?s)\r?\n?<!-- orquestracao:inicio -->.*?<!-- orquestracao:fim -->\r?\n?', '').TrimEnd()
$block = ([IO.File]::ReadAllText((Join-Path $Src 'CLAUDE.md'), $Utf8NoBom) -replace "`r`n", "`n").TrimEnd()
$final = if ($existing) { "$existing`n`n$block`n" } else { "$block`n" }
[IO.File]::WriteAllText($ClaudeMd, $final, $Utf8NoBom)
Write-Host "CLAUDE.md atualizado: $ClaudeMd"

# 3) settings.json: modelo padrao da sessao principal = Sonnet 5.5
$Settings = Join-Path $Dest 'settings.json'
$json = $null
if (Test-Path $Settings) {
    Copy-Item $Settings (Join-Path $Backup 'settings.json')
    $raw = [IO.File]::ReadAllText($Settings, $Utf8NoBom).Trim()
    if ($raw) { $json = $raw | ConvertFrom-Json }
}
if (-not $json) { $json = New-Object PSObject }
$json | Add-Member -NotePropertyName 'model' -NotePropertyValue 'claude-sonnet-5-5' -Force
[IO.File]::WriteAllText($Settings, ($json | ConvertTo-Json -Depth 50), $Utf8NoBom)
Write-Host "settings.json: model = claude-sonnet-5-5"

Write-Host "Backup do que existia antes: $Backup"
Write-Host "Pronto. Abra uma nova sessao do Claude Code e rode /agents para conferir."
