#!/bin/bash

# Exit on error
set -e

APP_NAME="Logfita"
APP_DIR="${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"

echo "Building $APP_NAME..."

# Create directory structure
mkdir -p "$MACOS_DIR"

# Compile Swift files
swiftc Sources/*.swift -parse-as-library -o "$MACOS_DIR/$APP_NAME"

# Create Info.plist
cat << 'EOF' > "$CONTENTS_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Logfita</string>
    <key>CFBundleIdentifier</key>
    <string>com.logfita.mac</string>
    <key>CFBundleName</key>
    <string>Logfita</string>
    <key>CFBundleVersion</key>
    <string>0.1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>0.1.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSCalendarsUsageDescription</key>
    <string>Logfita needs access to your Calendar to calculate your logged work hours.</string>
    <key>NSCalendarsFullAccessUsageDescription</key>
    <string>Logfita needs full access to your Calendar to calculate your logged work hours.</string>
</dict>
</plist>
EOF

# Code sign the application
echo "Signing $APP_DIR..."
codesign -s - --force "$APP_DIR"

echo "Build successful! You can now run $APP_DIR."
