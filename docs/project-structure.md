# Project Structure

The initial app code is split by product area so recording work does not grow inside one large file.

```text
Sources/LoomClone/
  App/            App entry point, lifecycle, global app state
  MenuBar/        Menubar item and menu content
  Permissions/    Permission models and later permission request helpers
  Recorder/       Recording state and later ScreenCaptureKit pipeline
  Camera/         Webcam settings and later camera capture
  Microphone/     Microphone settings and later audio capture
  Overlay/        Cursor highlight, privacy mask, and later pen annotation
  Exporter/       Export format and later local conversion
  Settings/       Settings UI
  Resources/      Placeholder icon resources
```

These folders are intentionally lightweight for M00. More abstractions should be added only when the recording pipeline makes them useful.
