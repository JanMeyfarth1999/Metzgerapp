#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
command -v flutter >/dev/null || { echo 'Flutter fehlt im PATH'; exit 1; }
if [[ ! -f android/gradle/wrapper/gradle-wrapper.jar ]]; then
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  flutter create --platforms=android --org de.metzgerapp --project-name metzgerapp --no-pub "$tmp/project"
  cp -a "$tmp/project/android/." android/
  cp -a tool/android_overlay/. android/
  [[ ! -f "$tmp/project/.metadata" ]] || cp "$tmp/project/.metadata" .metadata
  rm -f android/local.properties
fi
flutter pub get
dart format lib test
echo 'Projekt vorbereitet. Jetzt: flutter analyze; flutter test; flutter run'
