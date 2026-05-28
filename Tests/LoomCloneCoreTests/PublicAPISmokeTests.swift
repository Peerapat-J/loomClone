import LoomCloneCore
import XCTest

final class PublicAPISmokeTests: XCTestCase {
    func testPublicSettingsInitializersCompileForExternalConsumers() {
        _ = CameraSettings()
        _ = CameraSettings(isEnabled: true, prefersCircularOverlay: false)
        _ = MicrophoneSettings()
        _ = MicrophoneSettings(isEnabled: true, selectedDeviceID: "test-device")
        _ = OverlaySettings()
        _ = OverlaySettings(
            isCursorHighlightEnabled: true,
            isPrivacyMaskEnabled: true,
            isPenAnnotationEnabled: true
        )
        _ = ExportSettings()
        _ = ExportSettings(preferredFormat: .mp4, shouldRevealAfterExport: false)
        _ = RecordingDuration(seconds: 0)
        _ = SaveLocationSettings()
        _ = SaveLocationSettings(customFolderPath: "/tmp")
        _ = SaveLocationPreferenceStore()
    }
}
