#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Builds the release manifest for the on-device model repository.

.DESCRIPTION
    The manifest is the single document that ties each model's download URL to its
    digest. It must be produced from the actual files that will be uploaded — never
    edited by hand, because a hand-copied digest that disagrees with the upload by
    one character turns every download into an integrity failure.

    Run this AFTER placing the .gguf files next to it, and upload both the files and
    the generated manifest.json to the same release tag.

.PARAMETER ModelDir
    Directory holding the .gguf files and this script's models.json input.

.PARAMETER Tag
    Release tag the files will live under. Must match `ModelRelease.tag` in the app.

.PARAMETER Repository
    GitHub owner/repo. Must match `ModelRelease.repository` in the app.
#>
param(
    [Parameter(Mandatory = $true)][string]$ModelDir,
    [Parameter(Mandatory = $true)][string]$Tag,
    [Parameter(Mandatory = $true)][string]$Repository
)

$ErrorActionPreference = 'Stop'

# Each entry names one model; the digest and size are computed here, never typed.
$catalogPath = Join-Path $ModelDir 'models.json'
if (-not (Test-Path $catalogPath)) {
    throw "missing $catalogPath — it lists the models to publish (see models.json.example)"
}

$catalog = Get-Content $catalogPath -Raw | ConvertFrom-Json
$entries = @()
$line = ''

foreach ($model in $catalog.models) {
    $path = Join-Path $ModelDir $model.fileName
    if (-not (Test-Path $path)) {
        throw "missing model file: $path"
    }

    Write-Host "hashing $($model.fileName) ($([math]::Round((Get-Item $path).Length / 1GB, 2)) GB)..."
    $hash = (Get-FileHash -Path $path -Algorithm SHA256).Hash.ToLowerInvariant()
    $size = (Get-Item $path).Length

    # The URL and the digest are written together, from the same run: that pairing
    # is the whole point of the manifest.
    $entries += [ordered]@{
        id            = $model.id
        name          = $model.name
        fileName      = $model.fileName
        downloadUrl   = "https://github.com/$Repository/releases/download/$Tag/$($model.fileName)"
        sha256        = $hash
        sizeBytes     = $size
        contextLength = $model.contextLength
    }
    $line = "  $($model.id): $hash"
    Write-Host $line -ForegroundColor Green
}

$manifest = [ordered]@{
    version = 1
    models  = $entries
}

$outPath = Join-Path $ModelDir 'manifest.json'
# `-Depth 10` keeps the nested model objects as objects instead of flattening them
# into dotted keys.
$manifest | ConvertTo-Json -Depth 10 | Set-Content -Path $outPath -Encoding utf8

Write-Host ''
Write-Host "wrote $outPath" -ForegroundColor Cyan
Write-Host 'Upload the .gguf files AND manifest.json to the same release tag.'
Write-Host 'Verify the digests the app will check against by re-reading the generated file:'
Write-Host ''
Get-Content $outPath -Raw | Write-Host