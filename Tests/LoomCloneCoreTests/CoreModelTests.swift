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

    func testRecordingCommandAvailabilityFollowsState() {
        XCTAssertTrue(RecordingCommand.start.isEnabled(in: .idle))
        XCTAssertFalse(RecordingCommand.pause.isEnabled(in: .idle))
        XCTAssertFalse(RecordingCommand.resume.isEnabled(in: .idle))
        XCTAssertFalse(RecordingCommand.stop.isEnabled(in: .idle))

        XCTAssertFalse(RecordingCommand.start.isEnabled(in: .recording))
        XCTAssertTrue(RecordingCommand.pause.isEnabled(in: .recording))
        XCTAssertFalse(RecordingCommand.resume.isEnabled(in: .recording))
        XCTAssertTrue(RecordingCommand.stop.isEnabled(in: .recording))

        XCTAssertFalse(RecordingCommand.start.isEnabled(in: .paused))
        XCTAssertFalse(RecordingCommand.pause.isEnabled(in: .paused))
        XCTAssertTrue(RecordingCommand.resume.isEnabled(in: .paused))
        XCTAssertTrue(RecordingCommand.stop.isEnabled(in: .paused))
    }

    func testOpenLastRecordingRequiresIdleStateAndARecording() {
        XCTAssertFalse(RecordingCommand.openLastRecording.isEnabled(in: .idle))
        XCTAssertTrue(RecordingCommand.openLastRecording.isEnabled(in: .idle, hasLastRecording: true))
        XCTAssertFalse(RecordingCommand.openLastRecording.isEnabled(in: .recording, hasLastRecording: true))
        XCTAssertFalse(RecordingCommand.openLastRecording.isEnabled(in: .paused, hasLastRecording: true))
    }

    func testRecordingDurationFormatsElapsedTime() {
        XCTAssertEqual(RecordingDuration(seconds: -20).displayText, "00:00")
        XCTAssertEqual(RecordingDuration(seconds: 0).displayText, "00:00")
        XCTAssertEqual(RecordingDuration(seconds: 65).displayText, "01:05")
        XCTAssertEqual(RecordingDuration(seconds: 3_665).displayText, "1:01:05")
    }

    func testPermissionDisplayNamesMatchMacOSPermissionLabels() {
        XCTAssertEqual(AppPermission.screenRecording.displayName, "Screen Recording")
        XCTAssertEqual(AppPermission.camera.displayName, "Camera")
        XCTAssertEqual(AppPermission.microphone.displayName, "Microphone")
    }

    func testDisplayCaptureTargetUsesLocalizedOrStableFallbackNames() {
        let namedDisplay = DisplayCaptureTarget(
            id: 100,
            name: "Studio Display",
            width: 1_920,
            height: 1_080,
            frame: DisplayCaptureFrame(x: 0, y: 0, width: 1_920, height: 1_080)
        )
        let mainDisplay = DisplayCaptureTarget(
            id: 200,
            name: " ",
            width: 3_456,
            height: 2_234,
            frame: DisplayCaptureFrame(x: 0, y: 0, width: 3_456, height: 2_234),
            isMain: true
        )
        let externalDisplay = DisplayCaptureTarget(
            id: 300,
            width: 2_560,
            height: 1_440,
            frame: DisplayCaptureFrame(x: 3_456, y: 0, width: 2_560, height: 1_440)
        )

        XCTAssertEqual(namedDisplay.name, "Studio Display")
        XCTAssertEqual(mainDisplay.name, "Main Display")
        XCTAssertEqual(externalDisplay.name, "Display 300")
    }

    func testDisplayCaptureTargetFormatsPickerTextAndUsability() {
        let display = DisplayCaptureTarget(
            id: 100,
            name: "Studio Display",
            width: 1_920,
            height: 1_080,
            frame: DisplayCaptureFrame(x: 0, y: 0, width: 1_920, height: 1_080)
        )
        let invalidDisplay = DisplayCaptureTarget(
            id: 101,
            width: 0,
            height: 1_080,
            frame: DisplayCaptureFrame(x: 0, y: 0, width: 0, height: 1_080)
        )

        XCTAssertEqual(display.dimensionsText, "1920 x 1080")
        XCTAssertEqual(display.menuTitle, "Studio Display (1920 x 1080)")
        XCTAssertTrue(display.isUsable)
        XCTAssertFalse(invalidDisplay.isUsable)
    }

    func testDisplayCaptureTargetSortingKeepsMainDisplayFirstAndDropsInvalidDisplays() {
        let rightDisplay = DisplayCaptureTarget(
            id: 300,
            width: 2_560,
            height: 1_440,
            frame: DisplayCaptureFrame(x: 3_456, y: 0, width: 2_560, height: 1_440)
        )
        let invalidDisplay = DisplayCaptureTarget(
            id: 400,
            width: 0,
            height: 1_440,
            frame: DisplayCaptureFrame(x: -2_560, y: 0, width: 0, height: 1_440)
        )
        let mainDisplay = DisplayCaptureTarget(
            id: 200,
            width: 3_456,
            height: 2_234,
            frame: DisplayCaptureFrame(x: 0, y: 0, width: 3_456, height: 2_234),
            isMain: true
        )

        let sortedDisplays = DisplayCaptureTarget.sortedForDisplayPicker([
            rightDisplay,
            invalidDisplay,
            mainDisplay
        ])

        XCTAssertEqual(sortedDisplays.map(\.id), [200, 300])
    }

    func testDisplayCaptureTargetPreferredSelectionPreservesValidChoice() {
        let displays = [
            DisplayCaptureTarget(
                id: 100,
                width: 1_920,
                height: 1_080,
                frame: DisplayCaptureFrame(x: 0, y: 0, width: 1_920, height: 1_080),
                isMain: true
            ),
            DisplayCaptureTarget(
                id: 200,
                width: 2_560,
                height: 1_440,
                frame: DisplayCaptureFrame(x: 1_920, y: 0, width: 2_560, height: 1_440)
            )
        ]

        XCTAssertEqual(
            DisplayCaptureTarget.preferredSelectionID(in: displays, currentSelectionID: 200),
            200
        )
    }

    func testDisplayCaptureTargetPreferredSelectionFallsBackToMainThenFirstThenNil() {
        let secondaryDisplay = DisplayCaptureTarget(
            id: 200,
            width: 2_560,
            height: 1_440,
            frame: DisplayCaptureFrame(x: 1_920, y: 0, width: 2_560, height: 1_440)
        )
        let mainDisplay = DisplayCaptureTarget(
            id: 100,
            width: 1_920,
            height: 1_080,
            frame: DisplayCaptureFrame(x: 0, y: 0, width: 1_920, height: 1_080),
            isMain: true
        )

        XCTAssertEqual(
            DisplayCaptureTarget.preferredSelectionID(
                in: [secondaryDisplay, mainDisplay],
                currentSelectionID: 999
            ),
            100
        )
        XCTAssertEqual(
            DisplayCaptureTarget.preferredSelectionID(
                in: [secondaryDisplay],
                currentSelectionID: nil
            ),
            200
        )
        XCTAssertNil(DisplayCaptureTarget.preferredSelectionID(in: [], currentSelectionID: 100))
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

    func testSaveLocationDefaultsToMoviesSubfolder() {
        let defaultURL = SaveLocationSettings.defaultFolderURL()
        XCTAssertEqual(defaultURL.lastPathComponent, "LoomClone")
        XCTAssertEqual(defaultURL.deletingLastPathComponent().lastPathComponent, "Movies")
        XCTAssertTrue(SaveLocationSettings().usesDefaultFolder)
        XCTAssertNil(SaveLocationSettings().customFolderURL)
    }

    func testSaveLocationAvailabilityDetectsMissingFolderAndFiles() throws {
        let fileManager = FileManager.default
        let tempFolder = fileManager.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileURL = fileManager.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: false)

        defer {
            try? fileManager.removeItem(at: tempFolder)
            try? fileManager.removeItem(at: fileURL)
        }

        XCTAssertEqual(
            SaveLocationSettings.availability(of: tempFolder, fileManager: fileManager),
            .missing
        )

        try fileManager.createDirectory(at: tempFolder, withIntermediateDirectories: true)
        XCTAssertEqual(
            SaveLocationSettings.availability(of: tempFolder, fileManager: fileManager),
            .available
        )

        try Data().write(to: fileURL)
        XCTAssertEqual(
            SaveLocationSettings.availability(of: fileURL, fileManager: fileManager),
            .notDirectory
        )
    }

    func testSaveLocationPreferenceStorePersistsCustomFolder() {
        let suiteName = "LoomCloneCoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let store = SaveLocationPreferenceStore(userDefaults: defaults)
        let customSettings = SaveLocationSettings(customFolderPath: "/tmp/LoomCloneRecordings")

        store.save(customSettings)
        XCTAssertEqual(store.load(), customSettings)

        store.save(SaveLocationSettings())
        XCTAssertEqual(store.load(), SaveLocationSettings())
    }
}
