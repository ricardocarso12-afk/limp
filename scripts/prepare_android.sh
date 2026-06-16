#!/usr/bin/env bash
set -euo pipefail

MANIFEST="android/app/src/main/AndroidManifest.xml"
GRADLE="android/app/build.gradle"
KOTLIN_GRADLE="android/app/build.gradle.kts"

if [ ! -f "$MANIFEST" ]; then
  echo "AndroidManifest.xml was not found. Run flutter create first."
  exit 1
fi

python3 <<'PY'
from pathlib import Path
p = Path('android/app/src/main/AndroidManifest.xml')
s = p.read_text()
permissions = '''
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
'''
if 'android.permission.CAMERA' not in s:
    s = s.replace('<manifest xmlns:android="http://schemas.android.com/apk/res/android">', '<manifest xmlns:android="http://schemas.android.com/apk/res/android">' + permissions)

# Set app label for generated Android project.
import re
s = re.sub(r'android:label="[^"]*"', 'android:label="T&B Custom Clean"', s)
p.write_text(s)
PY

# Increase minSdk if plugins require it. Works for Groovy and Kotlin Gradle templates.
if [ -f "$GRADLE" ]; then
  sed -i 's/minSdkVersion flutter.minSdkVersion/minSdkVersion 23/g' "$GRADLE" || true
  sed -i 's/minSdkVersion [0-9]\+/minSdkVersion 23/g' "$GRADLE" || true
fi

if [ -f "$KOTLIN_GRADLE" ]; then
  sed -i 's/minSdk = flutter.minSdkVersion/minSdk = 23/g' "$KOTLIN_GRADLE" || true
  sed -i 's/minSdk = [0-9]\+/minSdk = 23/g' "$KOTLIN_GRADLE" || true
fi

echo "Android project prepared for T&B Custom Clean."
