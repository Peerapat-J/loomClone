#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
APP_NAME="LoomClone"
BUNDLE_ID="dev.peerapat.loomclone"
MIN_SYSTEM_VERSION="15.0"
SWIFT_BUILD_FLAGS=(--arch arm64)
export MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-$MIN_SYSTEM_VERSION}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
APP_CONTENTS="$APP_BUNDLE/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"
APP_BINARY="$APP_MACOS/$APP_NAME"
INFO_PLIST="$APP_CONTENTS/Info.plist"
ICONSET_DIR="$APP_RESOURCES/AppIcon.iconset"
ICON_FILE="$APP_RESOURCES/AppIcon.icns"

stop_existing_app() {
  /usr/bin/pkill -x "$APP_NAME" >/dev/null 2>&1 || true
}

build_package() {
  swift build "${SWIFT_BUILD_FLAGS[@]}"
}

stage_app_bundle() {
  local build_dir
  build_dir="$(swift build "${SWIFT_BUILD_FLAGS[@]}" --show-bin-path)"

  /bin/rm -rf "$APP_BUNDLE"
  /bin/mkdir -p "$APP_MACOS" "$APP_RESOURCES"

  /bin/cp "$build_dir/$APP_NAME" "$APP_BINARY"
  /bin/chmod +x "$APP_BINARY"
  verify_apple_silicon_binary

  if compgen -G "$build_dir/*.bundle" >/dev/null; then
    /bin/cp -R "$build_dir"/*.bundle "$APP_RESOURCES/"
  fi

  /usr/bin/swift "$ROOT_DIR/script/generate_app_icon.swift" "$ICONSET_DIR"
  /usr/bin/iconutil -c icns "$ICONSET_DIR" -o "$ICON_FILE"

  /usr/bin/plutil -create xml1 "$INFO_PLIST"
  /usr/bin/plutil -insert CFBundleExecutable -string "$APP_NAME" "$INFO_PLIST"
  /usr/bin/plutil -insert CFBundleIdentifier -string "$BUNDLE_ID" "$INFO_PLIST"
  /usr/bin/plutil -insert CFBundleName -string "$APP_NAME" "$INFO_PLIST"
  /usr/bin/plutil -insert CFBundleDisplayName -string "$APP_NAME" "$INFO_PLIST"
  /usr/bin/plutil -insert CFBundlePackageType -string APPL "$INFO_PLIST"
  /usr/bin/plutil -insert CFBundleShortVersionString -string "0.1.0" "$INFO_PLIST"
  /usr/bin/plutil -insert CFBundleVersion -string "1" "$INFO_PLIST"
  /usr/bin/plutil -insert CFBundleIconFile -string AppIcon "$INFO_PLIST"
  /usr/bin/plutil -insert LSApplicationCategoryType -string "public.app-category.video" "$INFO_PLIST"
  /usr/bin/plutil -insert LSMinimumSystemVersion -string "$MIN_SYSTEM_VERSION" "$INFO_PLIST"
  /usr/bin/plutil -insert LSUIElement -bool YES "$INFO_PLIST"
  /usr/bin/plutil -insert NSHighResolutionCapable -bool YES "$INFO_PLIST"
  /usr/bin/plutil -insert NSPrincipalClass -string NSApplication "$INFO_PLIST"
  /usr/bin/plutil -insert NSCameraUsageDescription -string "LoomClone uses the camera only when the webcam overlay is enabled." "$INFO_PLIST"
  /usr/bin/plutil -insert NSMicrophoneUsageDescription -string "LoomClone uses the microphone only when microphone recording is enabled." "$INFO_PLIST"
}

verify_apple_silicon_binary() {
  local archs
  archs="$(/usr/bin/lipo -archs "$APP_BINARY")"
  if [[ "$archs" != "arm64" ]]; then
    echo "expected $APP_NAME to be arm64 only, got: $archs" >&2
    exit 1
  fi
}

open_app() {
  /usr/bin/open -n "$APP_BUNDLE"
}

usage() {
  echo "usage: $0 [run|--debug|debug|--logs|logs|--telemetry|telemetry|--verify|verify|--package|package]" >&2
}

stop_existing_app
build_package
stage_app_bundle

case "$MODE" in
  run)
    open_app
    ;;
  --package|package)
    echo "Packaged $APP_BUNDLE"
    ;;
  --debug|debug)
    lldb -- "$APP_BINARY"
    ;;
  --logs|logs)
    open_app
    /usr/bin/log stream --info --style compact --predicate "process == \"$APP_NAME\""
    ;;
  --telemetry|telemetry)
    open_app
    /usr/bin/log stream --info --style compact --predicate "subsystem == \"$BUNDLE_ID\""
    ;;
  --verify|verify)
    open_app
    sleep 2
    /usr/bin/pgrep -x "$APP_NAME" >/dev/null
    ;;
  *)
    usage
    exit 2
    ;;
esac
