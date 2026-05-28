import AppKit
import Combine
import Foundation
import LoomCloneCore

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var recordingState: RecordingState = .idle
    @Published private(set) var saveLocationSettings: SaveLocationSettings
    @Published private(set) var saveLocationAvailability: SaveLocationAvailability = .available
    @Published private(set) var lastRecordingURL: URL?

    let productName = AppConfiguration.appName
    let minimumSupportedMacOS = AppConfiguration.minimumMacOSVersion
    let storageMode = AppConfiguration.storageMode
    let recordingTimer = RecordingTimerModel()

    private let saveLocationStore: SaveLocationPreferenceStore
    private let fileManager: FileManager
    private let floatingControlPanelController: FloatingControlPanelController

    init(
        saveLocationStore: SaveLocationPreferenceStore = SaveLocationPreferenceStore(),
        fileManager: FileManager = .default,
        floatingControlPanelController: FloatingControlPanelController = FloatingControlPanelController()
    ) {
        self.saveLocationStore = saveLocationStore
        self.fileManager = fileManager
        self.floatingControlPanelController = floatingControlPanelController
        self.saveLocationSettings = saveLocationStore.load()

        prepareDefaultSaveLocation()
        refreshSaveLocationAvailability()
    }

    var shouldShowFloatingControlBar: Bool {
        recordingState != .idle
    }

    var menuBarTitle: String {
        productName
    }

    var menuBarSystemImage: String {
        switch recordingState {
        case .idle:
            "record.circle"
        case .recording:
            "record.circle.fill"
        case .paused:
            "pause.circle.fill"
        }
    }

    var saveLocationDisplayPath: String {
        selectedSaveLocationURL.path
    }

    var effectiveSaveLocationPath: String {
        saveLocationSettings.effectiveFolderURL(fileManager: fileManager).path
    }

    var saveLocationStatusText: String {
        if saveLocationSettings.usesDefaultFolder {
            return saveLocationAvailability == .available
                ? "Default folder ready"
                : "Default folder is not ready"
        }

        switch saveLocationAvailability {
        case .available:
            return "Custom folder ready"
        case .missing:
            return "Custom folder is missing; using the default folder"
        case .notDirectory:
            return "Custom path is not a folder; using the default folder"
        case .notWritable:
            return "Custom folder is not writable; using the default folder"
        }
    }

    var canOpenLastRecording: Bool {
        lastRecordingURL != nil
    }

    func isCommandEnabled(_ command: RecordingCommand) -> Bool {
        command.isEnabled(in: recordingState, hasLastRecording: canOpenLastRecording)
    }

    func startRecording() {
        guard isCommandEnabled(.start) else {
            return
        }

        lastRecordingURL = nil
        recordingTimer.reset()
        setRecordingState(.recording)
        recordingTimer.start()
    }

    func pauseRecording() {
        guard isCommandEnabled(.pause) else {
            return
        }

        recordingTimer.pause()
        setRecordingState(.paused)
    }

    func resumeRecording() {
        guard isCommandEnabled(.resume) else {
            return
        }

        setRecordingState(.recording)
        recordingTimer.start()
    }

    func stopRecording() {
        guard isCommandEnabled(.stop) else {
            return
        }

        recordingTimer.pause()
        recordingTimer.reset()
        setRecordingState(.idle)
    }

    func openLastRecording() {
        guard isCommandEnabled(.openLastRecording), let lastRecordingURL else {
            return
        }

        NSWorkspace.shared.open(lastRecordingURL)
    }

    func showSettings() {
        SettingsWindowController.shared.show(appState: self)
    }

    func updateSaveLocation(to folderURL: URL) {
        saveLocationSettings = SaveLocationSettings(customFolderPath: folderURL.standardizedFileURL.path)
        saveLocationStore.save(saveLocationSettings)
        refreshSaveLocationAvailability()
    }

    func resetSaveLocationToDefault() {
        saveLocationSettings = SaveLocationSettings()
        saveLocationStore.save(saveLocationSettings)
        prepareDefaultSaveLocation()
        refreshSaveLocationAvailability()
    }

    func refreshSaveLocationAvailability() {
        if saveLocationSettings.usesDefaultFolder {
            prepareDefaultSaveLocation()
        }

        saveLocationAvailability = SaveLocationSettings.availability(
            of: selectedSaveLocationURL,
            fileManager: fileManager
        )
    }

    private var selectedSaveLocationURL: URL {
        saveLocationSettings.customFolderURL
            ?? SaveLocationSettings.defaultFolderURL(fileManager: fileManager)
    }

    private func setRecordingState(_ state: RecordingState) {
        recordingState = state
        floatingControlPanelController.update(for: self)
    }

    private func prepareDefaultSaveLocation() {
        _ = try? SaveLocationSettings.createDefaultFolderIfNeeded(fileManager: fileManager)
    }
}
