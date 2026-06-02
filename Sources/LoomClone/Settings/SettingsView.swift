import AppKit
import LoomCloneCore
import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        Form {
            Section("App") {
                LabeledContent("Mode", value: "Menubar first")
                LabeledContent("Storage", value: appState.storageMode)
                LabeledContent("Minimum macOS", value: appState.minimumSupportedMacOS)
            }

            Section("Save Location") {
                LabeledContent("Selected", value: appState.saveLocationDisplayPath)
                LabeledContent("Active", value: appState.effectiveSaveLocationPath)
                LabeledContent("Status", value: appState.saveLocationStatusText)

                HStack {
                    Button("Choose Folder...") {
                        chooseSaveLocation()
                    }

                    Button("Reset to Default") {
                        appState.resetSaveLocationToDefault()
                    }
                    .disabled(appState.saveLocationSettings.usesDefaultFolder)
                }
            }

            Section("Permissions") {
                LabeledContent("Screen Recording", value: appState.screenRecordingPermissionStatusText)
                Text(appState.screenRecordingPermissionDetailText)

                HStack {
                    Button("Check Again") {
                        appState.refreshScreenRecordingPermission()
                    }

                    Button("Open Screen Recording Settings") {
                        appState.openScreenRecordingSettings()
                    }
                }
            }

            Section("Display") {
                LabeledContent("Status", value: appState.displayDetectionStatusText)
                LabeledContent("Selected", value: appState.selectedDisplaySummary)
                Text(appState.displayDetectionDetailText)

                if appState.hasAvailableDisplays {
                    Picker("Record Display", selection: selectedDisplayIDBinding) {
                        ForEach(appState.availableDisplays) { display in
                            Text(display.menuTitle).tag(Optional(display.id))
                        }
                    }
                    .disabled(appState.recordingState != .idle)
                }

                Button("Refresh Displays") {
                    appState.refreshAvailableDisplays()
                }
            }

            Section("Recorder") {
                Toggle("Microphone", isOn: .constant(false))
                    .disabled(true)
                Toggle("Camera", isOn: .constant(false))
                    .disabled(true)
                Toggle("Cursor Highlight", isOn: .constant(false))
                    .disabled(true)
                Toggle("Blur or Mask", isOn: .constant(false))
                    .disabled(true)
                Picker("Export Quality", selection: .constant("Balanced")) {
                    Text("Small").tag("Small")
                    Text("Balanced").tag("Balanced")
                    Text("High").tag("High")
                }
                .disabled(true)
            }
        }
        .formStyle(.grouped)
        .padding(24)
        .frame(width: 520)
    }

    private func chooseSaveLocation() {
        let panel = NSOpenPanel()
        panel.title = "Choose Save Location"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.directoryURL = URL(fileURLWithPath: appState.effectiveSaveLocationPath, isDirectory: true)

        if panel.runModal() == .OK, let folderURL = panel.url {
            appState.updateSaveLocation(to: folderURL)
        }
    }

    private var selectedDisplayIDBinding: Binding<DisplayCaptureTarget.ID?> {
        Binding {
            appState.selectedDisplayID
        } set: { selectedID in
            if let selectedID {
                appState.selectDisplay(id: selectedID)
            }
        }
    }
}
