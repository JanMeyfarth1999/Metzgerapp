$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { throw 'Flutter ist nicht im PATH. Bitte zuerst Flutter installieren / PATH setzen.' }
function Check-Exit([string]$step) { if ($LASTEXITCODE -ne 0) { throw "$step fehlgeschlagen (Exit $LASTEXITCODE)." } }
if (-not (Test-Path 'android\gradle\wrapper\gradle-wrapper.jar')) {
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('metzgerapp-' + [guid]::NewGuid().ToString('N'))
    try {
        flutter create --platforms=android --org de.metzgerapp --project-name metzgerapp --no-pub $tmp
        Check-Exit 'Flutter Android-Grundgeruest'
        # The locally installed SDK provides compatible Gradle wrapper and plugins.
        Copy-Item -Path (Join-Path $tmp 'android\*') -Destination 'android' -Recurse -Force
        Copy-Item -Path 'tool\android_overlay\*' -Destination 'android' -Recurse -Force
        if (Test-Path (Join-Path $tmp '.metadata')) { Copy-Item (Join-Path $tmp '.metadata') '.metadata' -Force }
        if (Test-Path 'android\local.properties') { Remove-Item 'android\local.properties' -Force }
    } finally { if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force } }
}
flutter pub get
Check-Exit 'Abhaengigkeiten'
dart format lib test
Check-Exit 'Dart-Formatierung'
Write-Host 'Projekt vorbereitet. Jetzt: flutter analyze; flutter test; flutter run'
