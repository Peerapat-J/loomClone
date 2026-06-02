# Project Structure

The initial app code is split by product area so recording work does not grow inside one large file.

```text
LoomClone.xcodeproj/
  xcshareddata/xcschemes/LoomClone.xcscheme

Sources/LoomClone/
  App/            App entry point, lifecycle, global app state
  MenuBar/        Menubar item, menu content, and floating controls
  Settings/       Settings UI
  Resources/      Info.plist, placeholder icon assets, template resources

Sources/LoomCloneCore/
  AppConfiguration.swift
  DisplayCaptureTarget.swift
  RecordingState.swift
  RecordingCommand.swift
  RecordingDuration.swift
  SaveLocationSettings.swift
  PermissionModels.swift
  CameraSettings.swift
  MicrophoneSettings.swift
  OverlaySettings.swift
  ExportSettings.swift

Tests/LoomCloneCoreTests/
  CoreModelTests.swift
```

The native Xcode project has three targets:

- `LoomClone`: macOS app target
- `LoomCloneCore`: static library for shared/testable foundation models
- `LoomCloneCoreTests`: unit tests for `LoomCloneCore`

Display enumeration is split between targets: `ScreenCaptureKitDisplayDetector`
stays in the app target because it imports ScreenCaptureKit/AppKit, while
`DisplayCaptureTarget` stays in `LoomCloneCore` so selection and formatting
logic can be covered by unit tests.

These folders are intentionally lightweight. More abstractions should be added only when the recording pipeline makes them useful.
