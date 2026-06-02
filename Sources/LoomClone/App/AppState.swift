import AppKit
import Combine
import CoreGraphics
import Foundation
import LoomCloneCore

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var recordingState: RecordingState = .idle
    @Published private(set) var screenRecordingPermissionState: PermissionState = .unknown
    @Published private(set) var displayDetectionState: DisplayDetectionState = .unknown
    @Published private(set) var availableDisplays: [DisplayCaptureTarget] = []
    @Published private(set) var selectedDisplayID: DisplayCaptureTarget.ID?
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
    private let displayDetector: any DisplayCaptureDetecting
    private let userDefaults: UserDefaults
    private let screenRecordingSettingsURL = URL(
        string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"
    )
    private let hasRequestedScreenRecordingAccessKey = "hasRequestedScreenRecordingAccess"

    init(
        saveLocationStore: SaveLocationPreferenceStore = SaveLocationPreferenceStore(),
        fileManager: FileManager = .default,
        floatingControlPanelController: FloatingControlPanelController = FloatingControlPanelController(),
        displayDetector: any DisplayCaptureDetecting = ScreenCaptureKitDisplayDetector(),
        userDefaults: UserDefaults = .standard
    ) {
        self.saveLocationStore = saveLocationStore
        self.fileManager = fileManager
        self.floatingControlPanelController = floatingControlPanelController
        self.displayDetector = displayDetector
        self.userDefaults = userDefaults
        self.saveLocationSettings = saveLocationStore.load()

        prepareDefaultSaveLocation()
        refreshSaveLocationAvailability()
        refreshScreenRecordingPermission()
        if screenRecordingPermissionState == .granted {
            refreshAvailableDisplays()
        }
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

    var screenRecordingPermissionStatusText: String {
        switch screenRecordingPermissionState {
        case .unknown:
            "Screen Recording: Checking"
        case .notDetermined:
            "Screen Recording: Permission Needed"
        case .granted:
            "Screen Recording: Ready"
        case .denied:
            "Screen Recording: Disabled"
        }
    }

    var screenRecordingPermissionDetailText: String {
        switch screenRecordingPermissionState {
        case .unknown:
            "LoomClone is checking Screen Recording access."
        case .notDetermined:
            "Allow Screen Recording before starting a capture."
        case .granted:
            "Screen Recording permission is enabled."
        case .denied:
            "Enable LoomClone in System Settings > Privacy & Security > Screen Recording."
        }
    }

    var screenRecordingPermissionSystemImage: String {
        switch screenRecordingPermissionState {
        case .unknown:
            "questionmark.circle"
        case .notDetermined:
            "lock"
        case .granted:
            "checkmark.shield"
        case .denied:
            "exclamationmark.triangle"
        }
    }

    var needsScreenRecordingPermissionAction: Bool {
        screenRecordingPermissionState != .granted
    }

    var selectedDisplay: DisplayCaptureTarget? {
        availableDisplays.first { $0.id == selectedDisplayID }
    }

    var hasAvailableDisplays: Bool {
        !availableDisplays.isEmpty
    }

    var selectedDisplaySummary: String {
        selectedDisplay?.menuTitle ?? "No display selected"
    }

    var displayDetectionStatusText: String {
        displayDetectionState.displayName
    }

    var displayDetectionDetailText: String {
        switch displayDetectionState {
        case .unknown:
            "Display detection has not run yet."
        case .loading:
            "LoomClone is checking available displays."
        case .available:
            selectedDisplaySummary
        case .unavailable:
            "No recordable displays were found."
        case .failed(let message):
            "Could not list displays: \(message)"
        }
    }

    var displayDetectionSystemImage: String {
        switch displayDetectionState {
        case .unknown:
            "display"
        case .loading:
            "arrow.clockwise"
        case .available:
            "display.and.arrow.down"
        case .unavailable:
            "display.trianglebadge.exclamationmark"
        case .failed:
            "exclamationmark.triangle"
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

        guard ensureScreenRecordingPermissionBeforeRecording() else {
            return
        }

        guard ensureDisplaySelectedBeforeRecording() else {
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

    func refreshScreenRecordingPermission() {
        if CGPreflightScreenCaptureAccess() {
            screenRecordingPermissionState = .granted
        } else if userDefaults.bool(forKey: hasRequestedScreenRecordingAccessKey) {
            screenRecordingPermissionState = .denied
        } else {
            screenRecordingPermissionState = .notDetermined
        }
    }

    func requestScreenRecordingPermission() {
        guard screenRecordingPermissionState != .granted else {
            return
        }

        userDefaults.set(true, forKey: hasRequestedScreenRecordingAccessKey)
        screenRecordingPermissionState = CGRequestScreenCaptureAccess() ? .granted : .denied

        if screenRecordingPermissionState == .granted {
            refreshAvailableDisplays()
        }
    }

    func openScreenRecordingSettings() {
        if let screenRecordingSettingsURL {
            NSWorkspace.shared.open(screenRecordingSettingsURL)
        } else {
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/System Settings.app"))
        }
    }

    func showSettings() {
        SettingsWindowController.shared.show(appState: self)
    }

    func refreshAvailableDisplays() {
        refreshScreenRecordingPermission()
        guard screenRecordingPermissionState == .granted else {
            availableDisplays = []
            selectedDisplayID = nil
            displayDetectionState = .failed("Screen Recording permission is required before listing displays.")
            return
        }

        displayDetectionState = .loading

        Task {
            await loadAvailableDisplays()
        }
    }

    func selectDisplay(id: DisplayCaptureTarget.ID) {
        guard availableDisplays.contains(where: { $0.id == id }) else {
            return
        }

        selectedDisplayID = id
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

    private func ensureScreenRecordingPermissionBeforeRecording() -> Bool {
        refreshScreenRecordingPermission()
        let initialState = screenRecordingPermissionState

        if initialState == .granted {
            return true
        }

        if initialState == .notDetermined {
            requestScreenRecordingPermission()
            return screenRecordingPermissionState == .granted
        }

        requestScreenRecordingPermission()
        if screenRecordingPermissionState == .granted {
            return true
        }

        showScreenRecordingPermissionAlert()
        return false
    }

    private func ensureDisplaySelectedBeforeRecording() -> Bool {
        if selectedDisplay != nil {
            return true
        }

        refreshAvailableDisplays()
        showDisplayUnavailableAlert()
        return false
    }

    private func loadAvailableDisplays() async {
        do {
            let detectedDisplays = try await displayDetector.availableDisplays()
            applyDetectedDisplays(detectedDisplays)
        } catch {
            availableDisplays = []
            selectedDisplayID = nil
            displayDetectionState = .failed(error.localizedDescription)
        }
    }

    private func applyDetectedDisplays(_ detectedDisplays: [DisplayCaptureTarget]) {
        availableDisplays = detectedDisplays
        selectedDisplayID = DisplayCaptureTarget.preferredSelectionID(
            in: detectedDisplays,
            currentSelectionID: selectedDisplayID
        )
        displayDetectionState = detectedDisplays.isEmpty ? .unavailable : .available
    }

    private func showScreenRecordingPermissionAlert() {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Screen Recording Permission Needed"
        alert.informativeText = """
        Enable Screen Recording for LoomClone in System Settings before starting a capture.

        If macOS asks, quit and reopen LoomClone after enabling the permission.
        """
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Not Now")

        if alert.runModal() == .alertFirstButtonReturn {
            openScreenRecordingSettings()
        }
    }

    private func showDisplayUnavailableAlert() {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "No Display Selected"
        alert.informativeText = """
        LoomClone needs a display before recording can start.

        Check connected displays and try refreshing the display list.
        """
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func prepareDefaultSaveLocation() {
        _ = try? SaveLocationSettings.createDefaultFolderIfNeeded(fileManager: fileManager)
    }
}
