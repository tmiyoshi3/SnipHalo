#!/bin/bash
set -euo pipefail

APP_NAME="QuickSmiley"
BUILD_DIR=".build/release"
APP_BUNDLE="${APP_NAME}.app"

swift build -c release

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$BUILD_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/"
cp Resources/Info.plist "$APP_BUNDLE/Contents/"

echo "Built: $APP_BUNDLE"
