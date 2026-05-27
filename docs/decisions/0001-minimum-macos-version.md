# Decision 0001: Minimum macOS Version

## Decision

The initial minimum supported version is macOS 14.0.

## Rationale

LoomClone depends on native macOS recording APIs and a menubar-first workflow. Starting at macOS 14.0 keeps the first personal MVP simpler while the recording pipeline is still being proven.

## Options Considered

- macOS 13: possible for a menubar SwiftUI app, but it increases the compatibility surface before the recorder exists.
- macOS 14: current baseline for the MVP because it supports the planned SwiftUI, AppKit, ScreenCaptureKit, and AVFoundation direction with less early compatibility work.
- macOS 15 or newer: simpler in some areas, but unnecessarily limits future users before there is a reason.

## Follow-Up

Lowering the target can be revisited after screen recording, microphone recording, webcam overlay, pause/resume, and export are working reliably.
