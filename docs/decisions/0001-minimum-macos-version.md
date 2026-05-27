# Decision 0001: Minimum macOS Version

## Decision

The initial minimum supported version is macOS 15.0 on Apple Silicon.

## Rationale

LoomClone depends on native macOS recording APIs and a menubar-first workflow. Starting at macOS 15.0 keeps the first personal MVP simpler while the recording pipeline is still being proven.

The first app builds and release-preview artifacts are Apple Silicon only. Universal binaries and Intel support are out of scope for the personal MVP.

## Options Considered

- macOS 13: possible for a menubar SwiftUI app, but it increases the compatibility surface before the recorder exists.
- macOS 14: possible, but not needed because the app is initially personal-use and Apple Silicon only.
- macOS 15: current baseline for the MVP because it keeps the first supported surface smaller while supporting the planned SwiftUI, AppKit, ScreenCaptureKit, and AVFoundation direction.

## Follow-Up

Lowering the target or adding a universal binary can be revisited after screen recording, microphone recording, webcam overlay, pause/resume, and export are working reliably.
