# Project Structure

The initial app code is split by product area so recording work does not grow inside one large file.

```text
Sources/LoomClone/
  App/            App entry point, lifecycle, global app state
  MenuBar/        Menubar item and menu content
  Settings/       Settings UI
  Resources/      Placeholder icon resources

Sources/LoomCloneCore/
  AppConfiguration.swift
  RecordingState.swift
  PermissionModels.swift
  CameraSettings.swift
  MicrophoneSettings.swift
  OverlaySettings.swift
  ExportSettings.swift

Tests/LoomCloneCoreTests/
  CoreModelTests.swift
```

These folders are intentionally lightweight for M00. More abstractions should be added only when the recording pipeline makes them useful.
