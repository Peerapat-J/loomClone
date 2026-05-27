import XCTest
@testable import LoomCloneCore

final class CoreModelTests: XCTestCase {
    func testAppConfigurationMatchesAppleSiliconMVPBaseline() {
        XCTAssertEqual(AppConfiguration.appName, "LoomClone")
        XCTAssertEqual(AppConfiguration.bundleIdentifier, "dev.peerapat.loomclone")
        XCTAssertEqual(AppConfiguration.minimumMacOSVersion, "15.0")
        XCTAssertEqual(AppConfiguration.storageMode, "Local only")
    }

    func testRecordingStateDisplayNamesAreStable() {
        XCTAssertEqual(RecordingState.idle.displayName, "Idle")
        XCTAssertEqual(RecordingState.recording.displayName, "Recording")
        XCTAssertEqual(RecordingState.paused.displayName, "Paused")
        XCTAssertEqual(RecordingState.allCases.map(\.rawValue), ["idle", "recording", "paused"])
    }

    func testPermissionDisplayNamesMatchMacOSPermissionLabels() {
        XCTAssertEqual(AppPermission.screenRecording.displayName, "Screen Recording")
        XCTAssertEqual(AppPermission.camera.displayName, "Camera")
        XCTAssertEqual(AppPermission.microphone.displayName, "Microphone")
    }

    func testDefaultSettingsStayLocalMVPFriendly() {
        XCTAssertEqual(CameraSettings(), CameraSettings(isEnabled: false, prefersCircularOverlay: true))
        XCTAssertEqual(MicrophoneSettings(), MicrophoneSettings(isEnabled: false, selectedDeviceID: nil))
        XCTAssertEqual(
            OverlaySettings(),
            OverlaySettings(
                isCursorHighlightEnabled: false,
                isPrivacyMaskEnabled: false,
                isPenAnnotationEnabled: false
            )
        )
        XCTAssertEqual(ExportSettings(), ExportSettings(preferredFormat: .mov, shouldRevealAfterExport: true))
    }
}
