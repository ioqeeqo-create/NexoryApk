#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

APK_OUT="$ROOT/build/Nexory.apk"

echo "==> npm ci"
npm ci

echo "==> Capacitor Android"
if [ -d android ] && [ ! -f android/gradlew ]; then
  echo "Removing incomplete android/ folder"
  rm -rf android
fi
if [ ! -d android ]; then
  npx cap add android
fi
npx cap sync android

echo "==> App icon (optional)"
if [ -f "$ROOT/resources/icon.png" ]; then
  npx @capacitor/assets generate --android \
    --iconBackgroundColor '#000000' \
    --iconBackgroundColorDark '#000000' \
    --splashBackgroundColor '#06080d' || echo "icon generate skipped"
fi

bash scripts/patch-android.sh

mkdir -p "$ROOT/build"
cd android
chmod +x gradlew

echo "==> Gradle assembleDebug"
./gradlew assembleDebug --no-daemon -q

DEBUG_APK="app/build/outputs/apk/debug/app-debug.apk"
if [ ! -f "$DEBUG_APK" ]; then
  echo "ERROR: APK not found at android/$DEBUG_APK"
  find . -name '*.apk' -type f || true
  exit 1
fi

cp "$DEBUG_APK" "$APK_OUT"
echo "==> Done: $APK_OUT ($(du -h "$APK_OUT" | cut -f1))"
