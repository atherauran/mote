#!/bin/zsh
# Builds Mote, installs it to /Applications and (re)launches it.
set -euo pipefail
cd "$(dirname "$0")"

swift build -c release

APP=/Applications/Mote.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp .build/release/Mote "$APP/Contents/MacOS/Mote"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>Mote</string>
    <key>CFBundleIdentifier</key><string>local.mote.Mote</string>
    <key>CFBundleExecutable</key><string>Mote</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSMinimumSystemVersion</key><string>14.0</string>
    <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST
codesign --force --sign - "$APP"

pkill -x Mote || true
open "$APP"
echo "Installed and launched $APP"
