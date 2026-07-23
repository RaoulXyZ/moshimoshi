<#
.SYNOPSIS
  Incrementa la versione SemVer in pubspec.yaml (campo `version: X.Y.Z+N`)
  e il build number Android.

.DESCRIPTION
  Usato dalla skill `release`. Legge la versione attuale, applica il bump della
  parte richiesta (major/minor/patch) azzerando le parti inferiori come da SemVer,
  e incrementa SEMPRE il build number (parte dopo `+`). Se il build number manca,
  parte da 1.

.PARAMETER Part
  Quale parte incrementare: major | minor | patch. Default: patch.

.PARAMETER PubspecPath
  Percorso a pubspec.yaml. Default: ./pubspec.yaml

.EXAMPLE
  pwsh .claude/skills/release/bump_version.ps1 -Part minor
#>
param(
    [ValidateSet('major', 'minor', 'patch')]
    [string]$Part = 'patch',
    [string]$PubspecPath = 'pubspec.yaml'
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $PubspecPath)) {
    Write-Error "pubspec.yaml non trovato in '$PubspecPath'. Esegui dalla root del progetto."
}

$lines = Get-Content -Path $PubspecPath -Encoding UTF8
$versionLineIndex = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^version:\s*(.+?)\s*$') {
        $versionLineIndex = $i
        $currentVersion = $Matches[1]
        break
    }
}

if ($versionLineIndex -lt 0) {
    Write-Error "Nessun campo 'version:' trovato in $PubspecPath."
}

# Parse X.Y.Z(+N)
if ($currentVersion -notmatch '^(\d+)\.(\d+)\.(\d+)(?:\+(\d+))?$') {
    Write-Error "Formato versione non riconosciuto: '$currentVersion'. Atteso X.Y.Z oppure X.Y.Z+N."
}

$major = [int]$Matches[1]
$minor = [int]$Matches[2]
$patch = [int]$Matches[3]
$build = if ($Matches[4]) { [int]$Matches[4] } else { 0 }

switch ($Part) {
    'major' { $major++; $minor = 0; $patch = 0 }
    'minor' { $minor++; $patch = 0 }
    'patch' { $patch++ }
}
$build++  # il build number cresce sempre

$newVersion = "$major.$minor.$patch+$build"
$lines[$versionLineIndex] = "version: $newVersion"

# Scrive UTF-8 SENZA BOM (Windows PowerShell 5.1 aggiungerebbe un BOM con -Encoding UTF8,
# che può corrompere il parsing di pubspec.yaml). Preserva le newline stile LF.
$content = ($lines -join "`n") + "`n"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$fullPath = (Resolve-Path $PubspecPath).Path
[System.IO.File]::WriteAllText($fullPath, $content, $utf8NoBom)

Write-Host "Versione: $currentVersion  ->  $newVersion"
Write-Host "  versionName (Android): $major.$minor.$patch"
Write-Host "  versionCode (Android): $build"
