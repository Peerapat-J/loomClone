#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
APP_NAME="LoomClone"
BUNDLE_ID="dev.peerapat.loomclone"
MIN_SYSTEM_VERSION="15.0"
CONFIGURATION="${CONFIGURATION:-Debug}"
PROJECT_NAME="LoomClone.xcodeproj"
SCHEME="LoomClone"
DESTINATION="platform=macOS,arch=arm64"
export MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-$MIN_SYSTEM_VERSION}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/$PROJECT_NAME"
DERIVED_DATA_DIR="${DERIVED_DATA_DIR:-$ROOT_DIR/.derivedData}"
BUILD_PRODUCTS_DIR="$DERIVED_DATA_DIR/Build/Products/$CONFIGURATION"
BUILT_APP_BUNDLE="$BUILD_PRODUCTS_DIR/$APP_NAME.app"
DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
APP_BINARY="$APP_BUNDLE/Contents/MacOS/$APP_NAME"
INFO_PLIST="$APP_BUNDLE/Contents/Info.plist"

stop_existing_app() {
  /usr/bin/pkill -x "$APP_NAME" >/dev/null 2>&1 || true
}

build_project() {
  xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "$DESTINATION" \
    -derivedDataPath "$DERIVED_DATA_DIR" \
    ARCHS=arm64 \
    ONLY_ACTIVE_ARCH=YES \
    MACOSX_DEPLOYMENT_TARGET="$MIN_SYSTEM_VERSION" \
    CODE_SIGNING_ALLOWED="${CODE_SIGNING_ALLOWED:-NO}" \
    build
}

stage_app_bundle() {
  /bin/rm -rf "$APP_BUNDLE"
  /bin/mkdir -p "$DIST_DIR"
  /usr/bin/ditto "$BUILT_APP_BUNDLE" "$APP_BUNDLE"
  verify_packaged_app
}

verify_packaged_app() {
  local archs
  archs="$(/usr/bin/lipo -archs "$APP_BINARY")"
  if [[ "$archs" != "arm64" ]]; then
    echo "expected $APP_NAME to be arm64 only, got: $archs" >&2
    exit 1
  fi

  local minimum_system_version
  minimum_system_version="$(/usr/bin/plutil -extract LSMinimumSystemVersion raw -o - "$INFO_PLIST")"
  if [[ "$minimum_system_version" != "$MIN_SYSTEM_VERSION" ]]; then
    echo "expected LSMinimumSystemVersion $MIN_SYSTEM_VERSION, got: $minimum_system_version" >&2
    exit 1
  fi

  local bundle_identifier
  bundle_identifier="$(/usr/bin/plutil -extract CFBundleIdentifier raw -o - "$INFO_PLIST")"
  if [[ "$bundle_identifier" != "$BUNDLE_ID" ]]; then
    echo "expected CFBundleIdentifier $BUNDLE_ID, got: $bundle_identifier" >&2
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
build_project
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
