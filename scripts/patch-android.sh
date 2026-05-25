#!/usr/bin/env bash
# OAuth deep link nexory://oauth/soundcloud + cleartext for gateway HTTP
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$ROOT/android/app/src/main/AndroidManifest.xml"

if [ ! -f "$MANIFEST" ]; then
  echo "WARN: AndroidManifest not found: $MANIFEST"
  exit 0
fi

python3 <<'PY' "$MANIFEST"
import sys
from pathlib import Path

path = Path(sys.argv[1])
xml = path.read_text(encoding="utf-8")

if 'android:scheme="nexory"' not in xml:
    block = """
            <intent-filter android:autoVerify="false">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="nexory" android:host="oauth" android:pathPrefix="/soundcloud" />
            </intent-filter>"""
    marker = '<intent-filter>\n                <action android:name="android.intent.action.MAIN"'
    if marker in xml:
        xml = xml.replace(marker, block + '\n            ' + marker, 1)
    else:
        xml = xml.replace('</activity>', block + '\n        </activity>', 1)
    print('Added nexory:// OAuth intent-filter')

for perm in (
    'android.permission.ACCESS_NETWORK_STATE',
    'android.permission.WAKE_LOCK',
):
    if perm not in xml:
        xml = xml.replace(
            '</manifest>',
            f'    <uses-permission android:name="{perm}" />\n</manifest>',
            1,
        )
        print(f'Added {perm}')

if 'android:usesCleartextTraffic="true"' not in xml:
    xml = xml.replace(
        '<application',
        '<application android:usesCleartextTraffic="true"',
        1,
    )
    print('Enabled cleartext traffic for gateway')

path.write_text(xml, encoding="utf-8")
PY

echo "==> Patched $MANIFEST"
