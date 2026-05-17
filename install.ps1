param(
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$marketplaceName = "discord-publisher"
$pluginName = "discord-publisher@discord-publisher"
$repoUrl = "https://github.com/Ryanabcraft/discord-publisher-marketplace.git"
$codexDir = Join-Path $env:USERPROFILE ".codex"
$configPath = Join-Path $codexDir "config.toml"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = "$configPath.bak-$timestamp"

function Add-BlockIfMissing {
  param(
    [string]$Content,
    [string]$Header,
    [string]$Block
  )

  if ($Content -match [regex]::Escape($Header)) {
    return $Content
  }

  if ([string]::IsNullOrWhiteSpace($Content)) {
    return $Block.Trim() + [Environment]::NewLine
  }

  return $Content.TrimEnd() + [Environment]::NewLine + [Environment]::NewLine + $Block.Trim() + [Environment]::NewLine
}

Write-Host ""
Write-Host "Discord Publisher installer" -ForegroundColor Cyan
Write-Host "---------------------------" -ForegroundColor Cyan

if (!(Test-Path -Path $codexDir)) {
  Write-Host "Criando pasta: $codexDir"
  if (!$DryRun) {
    New-Item -ItemType Directory -Force -Path $codexDir | Out-Null
  }
}

$current = ""
if (Test-Path -Path $configPath) {
  $current = Get-Content -Raw -Path $configPath
  Write-Host "Config encontrado: $configPath"
} else {
  Write-Host "Config ainda nao existe, vou criar: $configPath"
}

if ($current -match '(?ms)^\[plugins\."discord-publisher@[^"]+"\]\s*enabled\s*=\s*true\s*$') {
  Write-Host "Discord Publisher ja esta instalado e ativado." -ForegroundColor Green
  $updated = $current
} else {
  $marketplaceBlock = @"
[marketplaces.$marketplaceName]
source_type = "git"
source = "$repoUrl"
"@

  $pluginBlock = @"
[plugins."$pluginName"]
enabled = true
"@

  $updated = Add-BlockIfMissing -Content $current -Header "[marketplaces.$marketplaceName]" -Block $marketplaceBlock
  $updated = Add-BlockIfMissing -Content $updated -Header "[plugins.`"$pluginName`"]" -Block $pluginBlock
}

if ($updated -eq $current -and (Test-Path -Path $configPath)) {
  Write-Host "Nenhuma alteracao necessaria." -ForegroundColor Green
} else {
  if (Test-Path -Path $configPath) {
    Write-Host "Backup: $backupPath"
    if (!$DryRun) {
      Copy-Item -Force -Path $configPath -Destination $backupPath
    }
  }

  Write-Host "Atualizando config.toml..."
  if (!$DryRun) {
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($configPath, $updated, $utf8NoBom)
  }
}

Write-Host ""
Write-Host "Instalacao concluida." -ForegroundColor Green
Write-Host "Reinicie o Codex e procure por Discord Publisher em Plugins."
Write-Host ""
