# CI/CD

The first automation setup is intentionally small and local-first.

## CI

CI runs on GitHub-hosted `macos-15` runners and builds Apple Silicon artifacts only.

Checks:

- validate the Swift package graph
- run shell syntax checks for project scripts
- run `swift-format lint` when the runner has `swift-format`
- run unit tests with `swift test --arch arm64`
- build with SwiftPM using `swift build --arch arm64`
- build the Xcode package scheme for macOS arm64
- package the local `.app` bundle without launching it
- verify the packaged app binary is `arm64`
- verify the packaged app minimum macOS version is `15.0`

## Release Preview

The release-preview workflow builds a zipped `.app` artifact for manual testing. It can be started manually or by pushing a `v*` tag.

The artifact is unsigned and not notarized. That is acceptable for M00 and personal testing, but proper signing and notarization should be handled before any public release.

## Analytics

The app itself has no product analytics in the MVP.

GitHub Actions provides workflow run history, logs, durations, and artifacts. Those are CI/CD observability signals only; they are not app telemetry.
