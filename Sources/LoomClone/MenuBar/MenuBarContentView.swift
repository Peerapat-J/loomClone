import AppKit
import LoomCloneCore
import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        Text(appState.productName)
            .font(.headline)

        Label(appState.recordingState.displayName, systemImage: appState.menuBarSystemImage)

        Divider()

        Label(
            appState.screenRecordingPermissionStatusText,
            systemImage: appState.screenRecordingPermissionSystemImage
        )

        if appState.needsScreenRecordingPermissionAction {
            Text(appState.screenRecordingPermissionDetailText)

            Button {
                appState.requestScreenRecordingPermission()
            } label: {
                Label("Allow Screen Recording...", systemImage: "lock.open")
            }

            Button {
                appState.openScreenRecordingSettings()
            } label: {
                Label("Open Screen Recording Settings", systemImage: "gearshape")
            }
        }

        Divider()

        Button {
            appState.startRecording()
        } label: {
            Label(RecordingCommand.start.displayName, systemImage: "record.circle")
        }
        .disabled(!appState.isCommandEnabled(.start))

        Button {
            appState.pauseRecording()
        } label: {
            Label(RecordingCommand.pause.displayName, systemImage: "pause.circle")
        }
        .disabled(!appState.isCommandEnabled(.pause))

        Button {
            appState.resumeRecording()
        } label: {
            Label(RecordingCommand.resume.displayName, systemImage: "play.circle")
        }
        .disabled(!appState.isCommandEnabled(.resume))

        Button {
            appState.stopRecording()
        } label: {
            Label(RecordingCommand.stop.displayName, systemImage: "stop.circle")
        }
        .disabled(!appState.isCommandEnabled(.stop))

        Button {
            appState.openLastRecording()
        } label: {
            Label(RecordingCommand.openLastRecording.displayName, systemImage: "play.square")
        }
        .disabled(!appState.isCommandEnabled(.openLastRecording))

        Divider()

        Button {
            appState.showSettings()
        } label: {
            Label("Settings", systemImage: "gearshape")
        }

        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
    }
}
