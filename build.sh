#!/bin/bash
set -euo pipefail

APP_NAME="SnipHalo"
BUILD_DIR=".build/release"
APP_BUNDLE="${APP_NAME}.app"

swift build -c release

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$BUILD_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/"
cp Resources/Info.plist "$APP_BUNDLE/Contents/"
cp Resources/AppIcon.icns "$APP_BUNDLE/Contents/Resources/"
cp Resources/StatusBarIconTemplate.png "$APP_BUNDLE/Contents/Resources/"
cp Resources/StatusBarIconTemplate@2x.png "$APP_BUNDLE/Contents/Resources/"

echo "Built: $APP_BUNDLE"
