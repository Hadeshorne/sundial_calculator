#!/bin/bash
# Build Sundial Calculator as a double-clickable macOS .app bundle
set -e

APP_NAME="Sundial Calculator"
BUNDLE_ID="com.sundial.calculator"
BUILD_DIR=".build/app"
APP_DIR="$BUILD_DIR/$APP_NAME.app"

echo "Building Sundial Calculator..."
swift build -c release 2>&1

echo "Creating app bundle..."
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp .build/release/SundialCalculator "$APP_DIR/Contents/MacOS/SundialCalculator"

cat > "$APP_DIR/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Sundial Calculator</string>
    <key>CFBundleDisplayName</key>
    <string>Sundial Calculator</string>
    <key>CFBundleIdentifier</key>
    <string>com.sundial.calculator</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>SundialCalculator</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticTermination</key>
    <true/>
    <key>NSSupportsSuddenTermination</key>
    <true/>
</dict>
</plist>
PLIST

echo ""
echo "Done! App bundle created at:"
echo "  $APP_DIR"
echo ""
echo "You can now:"
echo "  • Double-click it in Finder"
echo "  • Or run: open \"$APP_DIR\""

# Open it right away
open "$APP_DIR"
